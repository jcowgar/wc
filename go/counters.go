package wc

import (
	"fmt"
	"io"
	"os"
)

// Count returns the Stats for the io.Reader.
func Count(r io.Reader) (Stats, error) {
	const bufferSize int = 16 * 1024

	buf := make([]byte, bufferSize)
	stats := statCounter{}

	for {
		bytesRead, e := r.Read(buf)
		if e != nil {
			if e == io.EOF {
				break
			}

			return Stats{}, fmt.Errorf("failure during read: %w", e)
		}

		stats.countBlock(buf[:bytesRead])
	}

	return Stats{
		Lines: stats.Lines,
		Words: stats.Words,
		Chars: stats.Chars,
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
