package uniquelist

import "slices"

type Comparator[T any] func(a, b T) int

// SortedInserter uses binary search to insert elements into a slice in sorted
// order.
type SortedInserter[T any] struct {
	// Cmp should be a comparison function that satisfies the definition in
	// https://pkg.go.dev/slices#BinarySearchFunc.
	Cmp Comparator[T]
	// S is the underlying slice. If a non-empty slice is provided, it must be
	// sorted.
	S []T
	// AllowDuplicates decides whether or not duplicates should be allowed.
	AllowDuplicates bool
}

// NewSortedInserter creates a SortedInserter with a new slice of type []T. You
// can generally omit the type argument to this function since it can be
// inferred from the type of cmp.
func NewSortedInserter[T any](cmp Comparator[T]) SortedInserter[T] {
	return SortedInserter[T]{
		Cmp: cmp,
		S:   []T{},
	}
}

// Insert adds an element to the slice in sorted order. It returns true if the
// element was added successfully or false if it was rejected for being a
// duplicate entry.
func (ui *SortedInserter[T]) Insert(e T) bool {
	n, found := slices.BinarySearchFunc(ui.S, e, func(e, t T) int {
		return ui.Cmp(e, t)
	})
	if found && !ui.AllowDuplicates {
		return false
	}

	ui.S = slices.Insert(ui.S, n, e)
	return true
}

// TODO: add a Search() method
