// list_workspaces/main.go lists recently used VS Code workspaces.
package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io/fs"
	"log"
	"net/url"
	"os"
	"path"
	"path/filepath"
	"slices"
	"strings"
	"time"
)

var ErrPathNotInJson = errors.New("workspace path not found in workspace.json")
var ErrSkipEntry = errors.New("skipping this entry")
var plainFlag = flag.Bool("plain", false, "If provided, print output to stdout in a plaintext format instead of rofi row format.")

type WorkspaceEntry struct {
	WsCodePath string    // path to the underlying workspace - i.e. where the code actually resides
	ModTime    time.Time // last modified time of state.vscdb
}

func (e WorkspaceEntry) String() string {
	return fmt.Sprintf("%v %v", e.ModTime, e.WsCodePath)
}

// DecodeUrl parses a workspace URL as found in a workspace.json file and
// returns it in a format suitable for passing to the `code` CLI to open the
// workspace. This means stripping the file:// scheme part and URL decoding
// any entities.
func DecodeUrl(wsUrl string) (string, error) {
	// In the past, I tried using url.Parse() here, but url.Parse() fails on
	// URLs that contain % entities in the hostname, which is a problem since VS
	// Code uses %2B as a delimiter in the hostname part of certain remote
	// workspaces' URLs. (See also: https://github.com/golang/go/issues/30844)
	// So, I've just given up on proper URL parsing and am instead resorting to
	// stripping off the file:// prefix with string manipulation like a
	// goddamned caveman.
	path, _ := strings.CutPrefix(wsUrl, "file://")

	// TODO: truncate vscode-remote:// workspace URLs. XXX for that matter,
	// should we even bother returning remote workspaces? Will they actually
	// work from the CLI?

	// Remove URL encoding entities
	decodedPath, err := url.QueryUnescape(path)
	if err != nil {
		log.Printf("failed to decode entities in workspace path: %v: %s", err, wsUrl)
		return wsUrl, err
	}

	return decodedPath, nil
}

// TruncateDirPrefix converts a path like /home/joe/foo/bar/baz to ~/foo/bar/baz,
// given an invocation like TruncateDirPrefix("/home/joe/foo/bar/baz", "/home/joe", "~")
func TruncateDirPrefix(path string, basedir string, replacement string) string {
	relPath, err := filepath.Rel(basedir, path)
	if err != nil {
		return path
	}
	if replacement == "" {
		return relPath
	}
	return filepath.Join("~", relPath)
}

// sortWorkspaceEntryList orders a list of WorkspaceEntries newest to oldest.
func sortWorkspaceEntryList(entries []WorkspaceEntry) {
	slices.SortStableFunc(entries, func(a, b WorkspaceEntry) int {
		// negate so the most recent entries will be at the top
		return -a.ModTime.Compare(b.ModTime)
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

// CodePath tries to find the workspace file or folder in the unmarshaled
// workspace.json.
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

// getWsModTime returns the last modified time of the state file for the given
// workspace directory.
func getWsModTime(wsDir string) (time.Time, error) {
	stateFile := path.Join(wsDir, "state.vscdb")
	stat, err := os.Lstat(stateFile)
	if err != nil {
		err = WithMessagef(err, "failed to stat state file %s", stateFile)
	}

	return stat.ModTime(), err
}

// getWsCodePath attempts to locate the underlying directory.
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

// getWsEntry returns a single workspace entry for the given path (or an error
// if no valid workspace could be found.)
func getWsEntry(wsStoragePath string, entry fs.DirEntry) (WorkspaceEntry, error) {
	var none WorkspaceEntry
	if !entry.IsDir() {
		return none, ErrSkipEntry
	}

	name := entry.Name()
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

// getWorkspaceEntries searches the given directory path for VS Code workspaces
// and returns a slice of WorkspaceEntry structs.
func getWorkspaceEntries(wsStoragePath string) ([]WorkspaceEntry, error) {
	entries, err := os.ReadDir(wsStoragePath)
	if err != nil {
		log.Fatalf("failed to read entries in %s: %v", wsStoragePath, err)
	}

	workspaces := make([]WorkspaceEntry, 0, 1000)
	for _, entry := range entries {
		wsEntry, err := getWsEntry(wsStoragePath, entry)
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

func PrintRofi(cleanedPath, rawPath string) string {
	// https://davatorium.github.io/rofi/1.7.5/rofi-script.5/#parsing-row-options
	return fmt.Sprintf("%s\000info\x1f%s\n", cleanedPath, rawPath)
}

func main() {
	flag.Parse()

	homedir, err := os.UserHomeDir()
	if err != nil {
		log.Fatalf("failed to get homedir: %v", err)
	}

	wsStoragePath := path.Join(homedir, ".config/Code/User/workspaceStorage")
	wsEntries, err := getWorkspaceEntries(wsStoragePath)
	if err != nil {
		log.Fatalf("error getting workspaces: %v", err)
	}

	sortWorkspaceEntryList(wsEntries)

	for _, entry := range wsEntries {
		if entry.WsCodePath == "" {
			continue
		}

		rawPath := entry.WsCodePath
		friendlyPath := TruncateDirPrefix(rawPath, homedir, "~")

		if *plainFlag {
			fmt.Printf("%s %s (%s)\n", entry.ModTime, friendlyPath, rawPath)
		} else {
			fmt.Println(PrintRofi(friendlyPath, rawPath))
		}
	}
}
