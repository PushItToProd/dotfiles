package uniquelist_test

import (
	"cmp"
	"slices"
	"testing"

	"github.com/pushittoprod/list_vscode_workspaces/pkg/uniquelist"
)

var intComparator uniquelist.Comparator[int] = func(a, b int) int {
	return a - b
}

func assertSliceEquals[T cmp.Ordered](t *testing.T, actual []T, expected ...T) {
	if slices.Compare(actual, expected) != 0 {
		t.Helper()
		t.Errorf("expected slice to look like %v but got this instead: %v", expected, actual)
	}
}

func TestInsertRejectsDupes(t *testing.T) {
	ui := uniquelist.SortedInserter[int]{
		Cmp: intComparator,
	}

	ok := ui.Insert(1)
	if !ok {
		t.Errorf("expected insert to be ok, but it was not: %+v", ui)
	}
	assertSliceEquals(t, ui.S, 1)

	ok = ui.Insert(1)
	if ok {
		t.Errorf("expected duplicate insert to be rejected")
	}
	assertSliceEquals(t, ui.S, 1)
}

func TestInsertIsSorted(t *testing.T) {
	ui := uniquelist.NewSortedInserter(intComparator)

	ui.Insert(3)
	ui.Insert(1)
	assertSliceEquals(t, ui.S, 1, 3)

	ui.Insert(2)
	assertSliceEquals(t, ui.S, 1, 2, 3)
}

func TestNewSortedInserter(t *testing.T) {
	ui := uniquelist.NewSortedInserter(intComparator)
	ui.Insert(3)
	ui.Insert(1)
	ui.Insert(2)
	assertSliceEquals(t, ui.S, 1, 2, 3)
}
