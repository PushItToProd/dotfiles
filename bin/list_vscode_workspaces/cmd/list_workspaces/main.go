// list_workspaces/main.go lists recently used VS Code workspaces.
package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"log"
	"os"
	"path"
	"slices"
	"time"
)

var ErrPathNotInJson = errors.New("workspace path not found in workspace.json")

type WorkspaceEntry struct {
	WorkspacePath string    // path to the underlying workspace
	ModTime       time.Time // last modified time of state.vscdb
}

func (e WorkspaceEntry) String() string {
	return fmt.Sprintf("%v %v", e.ModTime, e.WorkspacePath)
}

func sortWorkspaceEntryList(entries []WorkspaceEntry) {
	slices.SortStableFunc(entries, func(a, b WorkspaceEntry) int {
		// negate so the most recent entries will be at the top
		return -a.ModTime.Compare(b.ModTime)
	})
}

type WorkspaceJson struct {
	Folder        string `json:"folder"`
	Workspace     string `json:"workspace"`
	Configuration struct {
		External string `json:"external"`
	} `json:"configuration"`
}

func WithMessagef(err error, format string, a ...any) error {
	fstr := format + ": %w"
	a = append(a, err)
	return fmt.Errorf(fstr, a...)
}

func getWsModTime(wsDir string) (time.Time, error) {
	stateFile := path.Join(wsDir, "state.vscdb")
	stat, err := os.Lstat(stateFile)
	if err != nil {
		err = WithMessagef(err, "failed to stat state file %s", stateFile)
	}

	return stat.ModTime(), err
}

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

	if wsJson.Folder != "" {
		return wsJson.Folder, nil
	}
	if wsJson.Workspace != "" {
		return wsJson.Workspace, nil
	}
	if wsJson.Configuration.External != "" {
		return wsJson.Configuration.External, nil
	}

	return "", WithMessagef(ErrPathNotInJson, "couldn't find a workspace path in %s", wsFile)
}

func getWorkspaceEntries(wsStoragePath string) ([]WorkspaceEntry, error) {
	entries, err := os.ReadDir(wsStoragePath)
	if err != nil {
		log.Fatalf("failed to read entries in %s: %v", wsStoragePath, err)
	}

	workspaces := make([]WorkspaceEntry, 0, 1000)
	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}

		name := entry.Name()
		wsDir := path.Join(wsStoragePath, name)

		modTime, err := getWsModTime(wsDir)
		if err != nil {
			if errors.Is(err, fs.ErrNotExist) {
				continue
			}
			log.Fatal(err)
		}

		// read the workspace path from the file
		wsFile, err := getWsCodePath(wsDir)
		if err != nil {
			if errors.Is(err, fs.ErrNotExist) || errors.Is(err, ErrPathNotInJson) {
				continue
			}
			log.Fatal(err)
		}

		workspaces = append(workspaces, WorkspaceEntry{
			WorkspacePath: wsFile,
			ModTime:       modTime,
		})
	}

	return workspaces, nil
}

func main() {
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
		fmt.Println(entry)
	}
}
