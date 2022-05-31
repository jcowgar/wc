package wc

import (
	"fmt"
	"io"
	"os"
	"unsafe"
)

/*
   The idea here is to maintain an array of the first 256 characters indicating
   if it is whitespace (1) or not whitespace (0), and the same for end of line.

   We can then use pointer arithmetic to find a 1 or 0 for the character class
   and use basic math to increment the line and word counters. This enables us
   to have zero branches in our code which in turn allows for significant CPU
   optimization when executing our code. On the base machine, counting our
   648mb sample file time went from 1.8s to 0.3s using this optimization
   technique.
*/

var (
	whitespaceCatalog []int
	eolCatalog        []int

	whitespaceCatalogStart unsafe.Pointer
	eolCatalogStart        unsafe.Pointer
	catalogSize            uintptr
)

func init() {
	whitespaceCatalog = make([]int, 256)
	eolCatalog = make([]int, 256)

	for i := 9; i <= 13; i++ {
		whitespaceCatalog[i] = 1
	}

	whitespaceCatalog[32] = 1
	whitespaceCatalog[0x85] = 1
	whitespaceCatalog[0xA0] = 1

	eolCatalog[10] = 1

	whitespaceCatalogStart = unsafe.Pointer(&whitespaceCatalog[0])
	eolCatalogStart = unsafe.Pointer(&eolCatalog[0])
	catalogSize = unsafe.Sizeof(int(0))
}

// Count returns the Stats for the io.Reader.
func Count(r io.Reader) (Stats, error) {
	const bufferSize int = 16 * 1024

	buf := make([]byte, bufferSize)
	lines := 0
	words := 0
	chars := 0

	wasWhitespace := 1

	for {
		bytesRead, e := r.Read(buf)
		if e != nil {
			if e == io.EOF {
				break
			}

			return Stats{}, fmt.Errorf("failure during read: %w", e)
		}

		chars += bytesRead

		for _, b := range buf[:bytesRead] {
			lines += *(*int)(unsafe.Pointer(uintptr(eolCatalogStart) + catalogSize*uintptr(b)))

			inWhitespace := *(*int)(unsafe.Pointer(uintptr(whitespaceCatalogStart) + catalogSize*uintptr(b)))
			inWord := 1 - inWhitespace
			words += wasWhitespace * inWord

			wasWhitespace = inWhitespace
		}
	}

	return Stats{
		Lines: lines,
		Words: words,
		Chars: chars,
	}, nil
}

// CountFile returns the Stats for filename.
func CountFile(filename string) (Stats, error) {
	fh, err := os.Open(filename)
	if err != nil {
		return Stats{}, fmt.Errorf("failed to open file: %w", err)
	}
	defer fh.Close()

	return Count(fh)
}
