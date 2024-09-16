package uniquelist_test

import (
	"testing"

	"github.com/pushittoprod/list_vscode_workspaces/pkg/uniquelist"
)

var intComparator = func(a, b int) int {
	return a - b
}

func TestInsertRejectsDupes(t *testing.T) {
	ui := uniquelist.NewSortedInserter(intComparator)

	ok := ui.Insert(1)
	if !ok {
		t.Errorf("expected insert to be ok, but it was not: %+v", ui)
	}
	s := ui.S
	if len(s) != 1 || s[0] != 1 {
		t.Errorf("expected slice to look like [1] after insert but got this instead: %+v", s)
	}

	ok = ui.Insert(1)
	if ok {
		t.Errorf("expected duplicate insert to be rejected")
	}
	s = ui.S
	if len(s) != 1 || s[0] != 1 {
		t.Errorf("expected slice to look like [1] after insert but got this instead: %+v", s)
	}
}

func TestInsertIsSorted(t *testing.T) {
	ui := uniquelist.NewSortedInserter(intComparator)

	ui.Insert(3)
	ui.Insert(1)
	s := ui.S
	if len(s) != 2 || s[0] != 1 || s[1] != 3 {
		t.Errorf("expected slice to look like [1 3] but got this instead: %v", s)
	}

	ui.Insert(2)
	s = ui.S
	if len(s) != 3 || s[0] != 1 || s[1] != 2 || s[2] != 3 {
		t.Errorf("expected slice to look like [1 2 3] but got this instead: %v", s)
	}
}

func TestNewSortedInserter(t *testing.T) {
	ui := uniquelist.NewSortedInserter(intComparator)
	ui.Insert(3)
	ui.Insert(1)
	ui.Insert(2)

	s := ui.S
	if len(s) != 3 || s[0] != 1 || s[1] != 2 || s[2] != 3 {
		t.Errorf("expected slice to look like [1 2 3] but got this instead: %v", s)
	}
}
