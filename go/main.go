package wc

import (
	"fmt"
	"io"
	"os"
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
	const bufferSize int = 16 * 1024
	var lines, words, chars int
	var inWord bool

	buf := make([]byte, bufferSize)

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
			switch {
			// Optimize for most likely case (ASCII)
			case b > 32 && b <= 127:
				if !inWord {
					inWord = true
					words++
				}

			case b == '\n':
				inWord = false
				lines++

			case b == 0:
				// Ignore nulls entirely, which will let UTF-16 and UTF-32 work correctly.

			case b <= 32, b == 0x85, b == 0xa0:
				inWord = false

			// Leave even though first switch condition is duplicate. This will
			// catch non-standard Unicode situations.
			default:
				if !inWord {
					inWord = true
					words++
				}
			}
		}
	}

	return Stats{Lines: lines, Words: words, Chars: chars}, nil
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
