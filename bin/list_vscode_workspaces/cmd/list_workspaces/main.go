// list_workspaces/main.go lists recently used VS Code workspaces.
package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io/fs"
	"log"
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

func RemoveFileSchema(path string) string {
	path, _ = strings.CutPrefix(path, "file://")
	return path
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

func CleanPath(homedir, path string) string {
	cleanedPath := RemoveFileSchema(path)
	cleanedPath = TruncateDirPrefix(cleanedPath, homedir, "~")
	return cleanedPath
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
	wsFile, err := getWsCodePath(wsDir)
	if err != nil {
		return none, err
	}

	return WorkspaceEntry{
		WsCodePath: wsFile,
		ModTime:    modTime,
	}, nil
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
		rawPath := entry.WsCodePath
		cleanedPath := CleanPath(homedir, rawPath)

		if *plainFlag {
			fmt.Printf("%s %s (%s)\n", entry.ModTime, cleanedPath, rawPath)
		} else {
			fmt.Println(PrintRofi(cleanedPath, rawPath))
		}
	}
}
