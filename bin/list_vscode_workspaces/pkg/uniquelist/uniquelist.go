package uniquelist

import (
	"math"
	"slices"
)

var DoNotInsert = math.MinInt

type Comparable interface {
	// Compare shuld be a comparison function that determines whether 
	Compare(other Comparable) (cmp int, ok bool)
}

type UniqueList[T Comparable] []T

// Insert inserts an element into the UniqueList if it's not already present
func (ul *UniqueList[T]) Insert(elem T) bool {
	var shouldInsert bool = true
	index, found := slices.BinarySearchFunc(*ul, elem, func(e, t T) int {
		n, ok := e.Compare(t)
		if !ok {
			shouldInsert = false
			return DoNotInsert
		}
		return n
	})
	if found || !shouldInsert {
		return false
	}
	*ul = slices.Insert(*ul, index, elem)
	return true
}
