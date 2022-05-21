package wc

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"unicode"
)

type Stats struct {
	Filename string
	Chars    int
	Words    int
	Lines    int
}

func Count(filename string) (Stats, error) {
	fh, err := os.Open(filename)
	if err != nil {
		return Stats{}, fmt.Errorf("failed to open file: %w", err)
	}
	defer fh.Close()

	r := bufio.NewReader(fh)
	b := []byte{0}
	stats := Stats{}

	inWord := false

	for {
		_, e := r.Read(b)
		if e == io.EOF {
			break
		} else if e != nil {
			return Stats{}, fmt.Errorf("failure during read: %w", e)
		}

		stats.Chars++

		r := rune(b[0])

		if unicode.IsSpace(r) {
			if inWord {
				inWord = false
			} else {
				inWord = true
				stats.Words++
			}
		}
		if r == '\n' {
			stats.Lines++
		}
	}

	return stats, nil
}
