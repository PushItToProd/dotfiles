package uniquelist

import "slices"

type Comparator[T any] func(a, b T) int

// SortedInserter uses binary search to insert elements into a slice in sorted order.
type SortedInserter[T any] struct {
	// Cmp should be a comparison function that satifies the definition in
	// https://pkg.go.dev/slices#BinarySearchFunc.
	Cmp Comparator[T]
	S   *[]T
}

func NewSortedInserter[T any](cmp Comparator[T]) SortedInserter[T] {
	return SortedInserter[T]{
		Cmp: cmp,
		S:   new([]T),
	}
}

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
