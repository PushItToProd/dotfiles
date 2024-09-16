package uniquelist_test

import (
	"cmp"
	"math"
	"testing"

	"github.com/pushittoprod/list_vscode_workspaces/pkg/uniquelist"
)

type myType struct {
	value int
}

func (mt myType) Compare(b uniquelist.Comparable) (int, bool) {
	other, ok := b.(myType)
	if !ok {
		return math.MinInt, false
	}
	return cmp.Compare(mt.value, other.value), true
}

type myOtherType bool

func (mot myOtherType) Compare(b uniquelist.Comparable) (int, bool) {
	return -1, true
}

type myIntType int

func (mit myIntType) Compare(b uniquelist.Comparable) (int, bool) {
	other, ok := b.(myIntType)
	if !ok {
		return -1, false
	}
	return cmp.Compare(mit, other), true
}

func TestUniqueListInsertInt(t *testing.T) {
	ul := uniquelist.UniqueList[myIntType]{}
	ul.Insert(3)
	ul.Insert(1)
	ul.Insert(2)

	if len(ul) != 3 || ul[0] != 1 || ul[1] != 2 || ul[2] != 3 {
		t.Errorf("expected slice to look like [1 2 3], but got %+v instead", ul)
	}
}

func TestUniqueListInsert(t *testing.T) {
	ul := uniquelist.UniqueList[myType]{}
	ok := ul.Insert(myType{1})
	if !ok {
		t.Errorf("expected insertion to be ok, but it wasn't: %+v", ul)
	}
	if len(ul) != 1 {
		t.Errorf("expected length to be 1 after insertion, but got %d instead", len(ul))
	}

	ok = ul.Insert(myType{3})
	if !ok {
		t.Errorf("expected insertion to be ok, but it wasn't: %+v", ul)
	}
	if len(ul) != 2 {
		t.Errorf("expected length to be 2 after insertion, but got %d instead", len(ul))
	}

	if ul[0].value != 1 || ul[1].value != 3 {
		t.Errorf("expected slice to look like {1, 3}, but got %+v instead", ul)
	}

	ok = ul.Insert(myType{2})
	if !ok {
		t.Errorf("expected insertion to be ok, but it wasn't: %+v", ul)
	}
	if ul[0].value != 1 || ul[1].value != 2 || ul[2].value != 3 {
		t.Errorf("expected slice to look like {1, 2, 3}, but got %+v instead", ul)
	}
}

func TestUniqueListInsertRejectsDupes(t *testing.T) {
	ul := uniquelist.UniqueList[myType]{}
	ok := ul.Insert(myType{1})
	if !ok {
		t.Errorf("expected insertion to be ok, but it wasn't: %+v", ul)
	}
	ok = ul.Insert(myType{2})
	if !ok {
		t.Errorf("expected insertion to be ok, but it wasn't: %+v", ul)
	}
	ok = ul.Insert(myType{3})
	if !ok {
		t.Errorf("expected insertion to be ok, but it wasn't: %+v", ul)
	}
	if ul[0].value != 1 || ul[1].value != 2 || ul[2].value != 3 {
		t.Errorf("expected slice to look like {1, 2, 3}, but got %+v instead", ul)
	}

	ok = ul.Insert(myType{1})
	if ok {
		t.Errorf("expected duplicate insertion to not be ok, but it was: %+v", ul)
	}

	if ul[0].value != 1 || ul[1].value != 2 || ul[2].value != 3 {
		t.Errorf("expected slice to look like {1, 2, 3} after rejecting duplicate, but got %+v instead", ul)
	}
}

func TestDoNotInsert(t *testing.T) {
	ul := uniquelist.UniqueList[uniquelist.Comparable]{}
	ul.Insert(myType{1})
	ul.Insert(myType{2})
	ul.Insert(myType{3})
	if len(ul) != 3 {
		t.Errorf("expected slice length to be 3 after initial setup, but got %d instead", len(ul))
	}

	ok := ul.Insert(myOtherType(false))
	if ok {
		t.Errorf("expected insertion to be rejected")
	}
	if len(ul) != 3 {
		t.Errorf("expected slice length to be 3 after rejected insertion, but got %d instead", len(ul))
	}
}
