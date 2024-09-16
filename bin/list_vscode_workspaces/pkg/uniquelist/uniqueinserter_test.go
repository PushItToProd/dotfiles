package uniquelist_test

import (
	"slices"
	"testing"

	"github.com/pushittoprod/list_vscode_workspaces/pkg/uniquelist"
)

var intComparator uniquelist.Comparator[int] = func(a, b int) int {
	return a - b
}

func TestInsertRejectsDupes(t *testing.T) {
	ui := uniquelist.SortedInserter[int]{
		Cmp: intComparator,
	}

	ok := ui.Insert(1)
	if !ok {
		t.Errorf("expected insert to be ok, but it was not: %+v", ui)
	}
	if slices.Compare(ui.S, []int{1}) != 0 {
		t.Errorf("expected slice to look like [1] after insert but got this instead: %+v", ui.S)
	}

	ok = ui.Insert(1)
	if ok {
		t.Errorf("expected duplicate insert to be rejected")
	}
	if slices.Compare(ui.S, []int{1}) != 0 {
		t.Errorf("expected slice to look like [1] after insert but got this instead: %+v", ui.S)
	}
}

func TestInsertIsSorted(t *testing.T) {
	ui := uniquelist.NewSortedInserter(intComparator)

	ui.Insert(3)
	ui.Insert(1)
	if slices.Compare(ui.S, []int{1, 3}) != 0 {
		t.Errorf("expected slice to look like [1 3] but got this instead: %v", ui.S)
	}

	ui.Insert(2)
	if slices.Compare(ui.S, []int{1, 2, 3}) != 0 {
		t.Errorf("expected slice to look like [1 2 3] but got this instead: %v", ui.S)
	}
}

func TestNewSortedInserter(t *testing.T) {
	ui := uniquelist.NewSortedInserter(intComparator)
	ui.Insert(3)
	ui.Insert(1)
	ui.Insert(2)

	if slices.Compare(ui.S, []int{1, 2, 3}) != 0 {
		t.Errorf("expected slice to look like [1 2 3] but got this instead: %v", ui.S)
	}
}
