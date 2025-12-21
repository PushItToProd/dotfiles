// list_workspaces/main.go lists recently used VS Code workspaces, printing output in a format suitable for use by a
// helper script (namely, rofi_code.zsh or choose_vscode.sh).
package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"io/fs"
	"log"
	"maps"
	"net/url"
	"os"
	"path"
	"path/filepath"
	"regexp"
	"slices"
	"strings"
	"time"
)

var ErrPathNotInJson = errors.New("workspace path not found in workspace.json")
var ErrSkipEntry = errors.New("skipping this entry")
var formatFlag = flag.String("format", "plain", fmt.Sprintf("Must be one of %s", validFormatters))

// findNamedStringSubmatch takes a [regexp.Regexp] re with named capture groups and a string s to match in, and returns
// a map associating each named group with the value that re matched in s.
func findNamedStringSubmatch(re *regexp.Regexp, s string) map[string]string {
	matches := re.FindStringSubmatch(s)
	namedMatches := map[string]string{}
	for i, name := range re.SubexpNames() {
		if name != "" && i < len(matches) && matches[i] != "" {
			namedMatches[name] = matches[i]
		}
	}
	if len(namedMatches) == 0 {
		return nil
	}
	return namedMatches
}

// WorkspaceEntry holds metadata about a VS Code workspace retrieved from workspaceStorage.
type WorkspaceEntry struct {
	// WsCodePath holds the path or URI of the workspace that should be passed to VS Code
	WsCodePath string
	// ModTime holds the file modification time of state.vscdb, used to sort workspaces by most recently used.
	ModTime time.Time
}

func (e WorkspaceEntry) String() string {
	return fmt.Sprintf("%v %v", e.ModTime, e.WsCodePath)
}

// DecodeUrl parses a workspace URL as found in a workspace.json file and returns it in a format suitable for passing to
// the `code` CLI to open the workspace. This means stripping the file:// scheme part and URL decoding any entities.
func DecodeUrl(wsUrl string) (string, error) {
	// In the past, I tried using url.Parse() here, but url.Parse() fails on
	// URLs that contain % entities in the hostname, which is a problem since VS
	// Code uses %2B (+) as a delimiter in the hostname part of certain remote
	// workspaces' URLs. (See also: https://github.com/golang/go/issues/30844)
	// So, I've just given up on proper URL parsing and am instead resorting to
	// stripping off the file:// prefix with string manipulation like a
	// goddamned caveman.
	path, _ := strings.CutPrefix(wsUrl, "file://")

	// Remove URL encoding entities
	decodedPath, err := url.QueryUnescape(path)
	if err != nil {
		log.Printf("failed to decode entities in workspace path: %v: %s", err, wsUrl)
		return wsUrl, err
	}

	return decodedPath, nil
}

// TruncateDirPrefix converts a path like /home/joe/foo/bar/baz to ~/foo/bar/baz, given an invocation like
// TruncateDirPrefix("/home/joe/foo/bar/baz", "/home/joe", "~"). If path and basedir are equal, then no replacement is
// performed.
func TruncateDirPrefix(path string, basedir string, replacement string) (shortPath string, wasReplaced bool) {
	relPath, err := filepath.Rel(basedir, path)
	if err != nil {
		return path, false
	}
	if relPath == "." {
		return path, true
	}
	if replacement == "" {
		return relPath, true
	}
	return filepath.Join(replacement, relPath), true
}

var remoteWorkspaceRegexp = regexp.MustCompile(
	`^vscode-remote://(?<remoteType>[\w-]+)(\+)(?<hostname>[\w.-]+)(?<path>/.*)$`,
)

func MakeFriendlyPathForRemoteWorkspace(workspaceUri string) (friendlyPath string, isRemote bool) {
	// If the given path is a remote workspace, it'll be a URI like
	// vscode-remote://ssh-remote+HOSTNAME/home/user/foo/bar/baz.

	matches := findNamedStringSubmatch(remoteWorkspaceRegexp, workspaceUri)
	if matches == nil || matches["remoteType"] == "" || matches["hostname"] == "" || matches["path"] == "" {
		return "", false
	}

	return fmt.Sprintf("[%s:%s] %s", matches["remoteType"], matches["hostname"], matches["path"]), true
}

// MakeFriendlyPath takes the user's home directory and a path to a VS Code workspace, and performs substitutions on the
// given path to make it more human-readable.
func MakeFriendlyPath(homedir string, path string) string {
	// If the path starts with a slash, it's assume to be local.
	if path[0] == '/' {
		// If the local path starts with the user's home directory, replace the homedir with a tilde.
		if shortPath, wasReplaced := TruncateDirPrefix(path, homedir, "~"); wasReplaced {
			return shortPath
		}
		return path
	}

	if friendlyPath, wasReplaced := MakeFriendlyPathForRemoteWorkspace(path); wasReplaced {
		return friendlyPath
	}

	return path
}

// sortWorkspaceEntryList orders a list of WorkspaceEntries newest to oldest.
func sortWorkspaceEntryList(entries []WorkspaceEntry) {
	slices.SortStableFunc(entries, func(a, b WorkspaceEntry) int {
		// negate so the most recent entries will be at the top
		return -a.ModTime.Compare(b.ModTime)
	})
}

// dedupeWorkspaceEntryList removes any duplicates from the list.
func dedupeWorkspaceEntryList(entries []WorkspaceEntry) []WorkspaceEntry {
	paths := make(map[string]bool)
	return slices.DeleteFunc(entries, func(e WorkspaceEntry) bool {
		if paths[e.WsCodePath] {
			return true
		}
		paths[e.WsCodePath] = true
		return false
	})
}

// WorkspaceJson is used for unmarshaling the workspace.json files for each workspace.
type WorkspaceJson struct {
	Folder        string `json:"folder"`
	Workspace     string `json:"workspace"`
	Configuration struct {
		External string `json:"external"`
	} `json:"configuration"`
}

// CodePath tries to find the workspace file or folder in the unmarshaled workspace.json.
func (wsj WorkspaceJson) CodePath() string {
	paths := []string{
		wsj.Folder,
		wsj.Workspace,
		wsj.Configuration.External,
	}
	for _, path := range paths {
		if path != "" {
			return path
		}
	}
	return ""
}

// WithMessagef wraps an error with a formatted message.
func WithMessagef(err error, format string, a ...any) error {
	fstr := format + ": %w"
	a = append(a, err)
	return fmt.Errorf(fstr, a...)
}

// getWsModTime reads and returns the last modified time of the state.vscdb file for the given workspace directory.
// state.vscdb is a SQLite database that VS Code updates when the workspace is used, so this gives us a way to tell
// which workspaces have been most recently active.
func getWsModTime(wsDir string) (time.Time, error) {
	stateFile := path.Join(wsDir, "state.vscdb")
	stat, err := os.Lstat(stateFile)
	if err != nil {
		err = WithMessagef(err, "failed to stat state file %s", stateFile)
	}

	return stat.ModTime(), err
}

// getWsCodePath parses the workspaceStorage directory's workspace.json and uses WorkspaceJson.CodePath to try to find
// the path/URI of the underlying workspace directory or workspace.json file.
func getWsCodePath(wsDir string) (string, error) {
	wsFile := path.Join(wsDir, "workspace.json")

	wsJsonBytes, err := os.ReadFile(wsFile)
	if err != nil {
		return "", WithMessagef(err, "couldn't read workspace file %s", wsFile)
	}

	var wsJson WorkspaceJson
	err = json.Unmarshal(wsJsonBytes, &wsJson)
	if err != nil {
		return "", WithMessagef(err, "couldn't unmarshal workspace json %s", wsFile)
	}

	path := wsJson.CodePath()
	if path == "" {
		return "", WithMessagef(ErrPathNotInJson, "couldn't find a workspace path in %s", wsFile)
	}
	return path, nil
}

// GetWorkspaceEntry returns a single workspace entry for the given path (or an error if no valid workspace could be
// found.)
func GetWorkspaceEntry(wsStoragePath string, fsEntry fs.DirEntry) (WorkspaceEntry, error) {
	var none WorkspaceEntry

	if !fsEntry.IsDir() {
		return none, ErrSkipEntry
	}

	name := fsEntry.Name()
	wsDir := path.Join(wsStoragePath, name)

	modTime, err := getWsModTime(wsDir)
	if err != nil {
		return none, err
	}

	// read the workspace path from the file
	wsCodePath, err := getWsCodePath(wsDir)
	if err != nil {
		return none, err
	}

	// The code CLI doesn't decode entities in URLs it's given, so we decode
	// them here because they're invalid anywhere we'd use them. (If you run
	// `code file:///foo%20bar/workspace.json` it will attempt to open the
	// literal path `/foo%20bar/workspace.json` instead of `/foo bar/workspace.json`.)
	decodedPath, err := DecodeUrl(wsCodePath)
	if err != nil {
		log.Printf("failed to decode path: %s: %s", err, wsCodePath)
		// If we failed to decode the path, try just using it anyway.
		decodedPath = wsCodePath
	}

	return WorkspaceEntry{
		WsCodePath: decodedPath,
		ModTime:    modTime,
	}, err
}

// GetWorkspaceEntries searches the given directory path for VS Code workspaces
// and returns a slice of WorkspaceEntry structs.
func GetWorkspaceEntries(wsStoragePath string) ([]WorkspaceEntry, error) {
	entries, err := os.ReadDir(wsStoragePath)
	if err != nil {
		log.Fatalf("failed to read entries in %s: %v", wsStoragePath, err)
	}

	workspaces := make([]WorkspaceEntry, 0, len(entries))
	for _, entry := range entries {
		wsEntry, err := GetWorkspaceEntry(wsStoragePath, entry)
		if errors.Is(err, ErrSkipEntry) {
			continue
		}
		if err != nil {
			log.Printf("error processing %s: %v\n", entry.Name(), err)
			continue
		}
		workspaces = append(workspaces, wsEntry)
	}

	return workspaces, nil
}

// isDirectory takes the path to a file and returns whether it's a directory.
func isDirectory(path string) (bool, error) {
	fileInfo, err := os.Stat(path)
	if err != nil {
		return false, err // Return error if the path doesn't exist or is inaccessible
	}
	return fileInfo.IsDir(), nil // Return the result of IsDir()
}

// FindWorkspaceStorage finds the path to the VS Code workspaceStorage directory using the default paths on Linux and
// macOS.
func FindWorkspaceStorage(homedir string) (string, error) {
	subdirs := []string{
		".config/Code/User/workspaceStorage",
		"./Library/Application Support/Code/User/workspaceStorage",
	}

	var errs []error
	for _, subdirpath := range subdirs {
		fullpath := path.Join(homedir, subdirpath)
		isDir, err := isDirectory(fullpath)
		if err != nil {
			errs = append(errs, err)
			continue
		}
		if isDir {
			return fullpath, nil
		}
	}
	if errs == nil {
		return "", errors.New("couldn't find workspaceStorage")
	}
	return "", errors.Join(errs...)
}

// OutputEntry is an extension of WorkspaceEntry with an extra FriendlyPath field that contains the path to display to
// the user.
type OutputEntry struct {
	WorkspaceEntry
	FriendlyPath string
}

// OutputFormatter is a function type used to render an OutputEntry for display.
type OutputFormatter func(io.Writer, OutputEntry) error

var formatters = map[string]OutputFormatter{
	"rofi":   FormatRofi,
	"plain":  FormatPlain,
	"choose": FormatChoose,
}

var validFormatters = strings.Join(slices.Collect(maps.Keys(formatters)), ", ")

func FormatRofi(w io.Writer, entry OutputEntry) error {
	_, err := fmt.Fprintf(w, "%s\000info\x1f%s\n", entry.FriendlyPath, entry.WsCodePath)
	return err
}

func FormatPlain(w io.Writer, entry OutputEntry) error {
	_, err := fmt.Fprintf(w, "%s|%s|%s\n", entry.ModTime, entry.FriendlyPath, entry.WsCodePath)
	return err
}

func FormatChoose(w io.Writer, entry OutputEntry) error {
	_, err := fmt.Fprintf(w, "%s | %s\n", entry.WsCodePath, entry.FriendlyPath)
	return err
}

func main() {
	flag.Parse()

	formatter, ok := formatters[*formatFlag]
	if !ok {
		log.Fatalf("invalid format: %v (expected one of %s)", *formatFlag, validFormatters)
	}

	homedir, err := os.UserHomeDir()
	if err != nil {
		log.Fatalf("failed to get homedir: %v", err)
	}

	wsStoragePath, err := FindWorkspaceStorage(homedir)
	if err != nil {
		log.Fatalf("%v", err)
	}
	wsEntries, err := GetWorkspaceEntries(wsStoragePath)
	if err != nil {
		log.Fatalf("error getting workspaces: %v", err)
	}

	sortWorkspaceEntryList(wsEntries)
	wsEntries = dedupeWorkspaceEntryList(wsEntries)

	for _, entry := range wsEntries {
		workspacePath := entry.WsCodePath
		if workspacePath == "" {
			continue
		}

		friendlyPath := MakeFriendlyPath(homedir, workspacePath)
		outputEntry := OutputEntry{entry, friendlyPath}
		formatter(os.Stdout, outputEntry)
	}
}
