package uniquelist

import "slices"

type Comparator[T any] func(a, b T) int

// SortedInserter uses binary search to insert elements into a slice in sorted
// order. The slice pointer S must not be nil. If a non-empty slice is provided,
// it must be in sorted order.
type SortedInserter[T any] struct {
	// Cmp should be a comparison function that satisfies the definition in
	// https://pkg.go.dev/slices#BinarySearchFunc.
	Cmp Comparator[T]
	S   *[]T
}

// NewSortedInserter creates a SortedInserter with a new slice of type []T.
func NewSortedInserter[T any](cmp Comparator[T]) SortedInserter[T] {
	return SortedInserter[T]{
		Cmp: cmp,
		S:   new([]T),
	}
}

// Insert adds an element to the slice in sorted order.
func (ui SortedInserter[T]) Insert(e T) bool {
	n, found := slices.BinarySearchFunc(*ui.S, e, func(e, t T) int {
		return ui.Cmp(e, t)
	})
	if found {
		return false
	}

	*ui.S = slices.Insert(*ui.S, n, e)
	return true
}

// TODO: add a Search() method
