package uniquelist

import "slices"

// SortedInserter uses binary search to insert elements into a slice in sorted order.
type SortedInserter[T any] struct {
	Cmp        func(a, b T) (int, bool)
	S          *[]T
	AllowDupes bool
}

func (ui SortedInserter[T]) Insert(e T) bool {
	shouldInsert := true
	n, found := slices.BinarySearchFunc(*ui.S, e, func(e, t T) int {
		n, ok := ui.Cmp(e, t)
		shouldInsert = ok
		return n
	})
	_ = shouldInsert
	if found {
		return false
	}

	*ui.S = slices.Insert(*ui.S, n, e)
	return true
}

// TODO: add a Search() method
