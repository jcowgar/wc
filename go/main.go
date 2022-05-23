package wc

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"unicode"
)

// Stats tracks the Character, Word and Line count.
type Stats struct {
	// Chars is the number of characters counted.
	Chars int

	// Words is the number of words counted. A single word is
	// defined by one or more Unicode Letter characters separated
	// by a non Unicode Letter character.
	Words int

	// Lines is the number of lines counted. Lines is computed
	// by the number of Newline (\n) characters.
	Lines int
}

// Count returns the Stats for the io.Reader.
func Count(r io.Reader) (Stats, error) {
	const bufferSize int = 4 * 1024

	r = bufio.NewReader(r)
	b := make([]byte, bufferSize, bufferSize)

	stats := Stats{}

	inWord := false

	for {
		bytesRead, e := r.Read(b)
		if e == io.EOF {
			break
		} else if e != nil {
			return Stats{}, fmt.Errorf("failure during read: %w", e)
		}

		for byteIndex := 0; byteIndex < bytesRead; byteIndex++ {
		stats.Chars++

			r := rune(b[byteIndex])

		switch {
		case r == '\n':
			stats.Lines++
			inWord = false

		case unicode.IsSpace(r):
			inWord = false

		default:
			if !inWord {
				inWord = true
				stats.Words++
			}
		}
	}
	}

	return stats, nil
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
