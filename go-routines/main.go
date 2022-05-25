package wc

import (
	"fmt"
	"io"
	"os"
	"sync"
	"sync/atomic"
)

const bufferSize int = 16 * 1024

// Stats tracks the Character, Word and Line count.
type Stats struct {
	// Chars is the number of characters counted.
	Chars uint64

	// Words is the number of words counted. A single word is
	// defined by one or more Unicode Letter characters separated
	// by a non Unicode Letter character.
	Words uint64

	// Lines is the number of lines counted. Lines is computed
	// by the number of Newline (\n) characters.
	Lines uint64
}

// isAnyWhitespace will test the byte to see if it is any whitespace.
func isAnyWhitespace(b byte) bool {
	return (b > 0 && b <= 32) || b == 0xA0 || b == 0x85
}

// Set up the workers.
type workerData struct {
	Buf       []byte
	BytesRead uint64
	InWord    bool
}

// countWorker will run as a job to count the given data and
// increment the values in the given stats.
func countWorker(waitGroup *sync.WaitGroup, data *workerData, stats *Stats) {
	inWord := data.InWord

	var lines, words uint64

	for _, thisByte := range data.Buf[:data.BytesRead] {
		switch {
		// Optimize for most likely case (ASCII)
		case thisByte > 32 && thisByte <= 127:
			if !inWord {
				inWord = true
				words++
			}

		case thisByte == '\n':
			inWord = false
			lines++

		case thisByte == 0:
			// Ignore nulls entirely, which will let UTF-16 and UTF-32 work correctly.

		case isAnyWhitespace(thisByte):
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

	// Increment the stats.
	atomic.AddUint64(&stats.Lines, lines)
	atomic.AddUint64(&stats.Words, words)
	atomic.AddUint64(&stats.Chars, data.BytesRead)

	// ... and we're done.
	waitGroup.Done()
}

// Count returns the Stats for the io.Reader.
func Count(source io.Reader) (Stats, error) {
	// Set up the masterStats.
	masterStats := &Stats{}

	// Create the workerWg.
	workerWg := &sync.WaitGroup{}

	// Track whether the last block started in a word.
	inWord := false

	// Read from the buffer.
	for {
		// Set up the workerData.
		data := workerData{Buf: make([]byte, bufferSize), InWord: inWord, BytesRead: 0}

		// Read a block.
		bytesRead, err := source.Read(data.Buf)
		if err != nil {
			if err == io.EOF {
				// We're done.
				break
			}

			// Something else has gone wrong.
			return Stats{}, fmt.Errorf("failure during read: %w", err)
		}

		// Record the values
		data.BytesRead = uint64(bytesRead)
		nextInWord := !isAnyWhitespace(data.Buf[bytesRead-1])

		// Start the worker.
		workerWg.Add(1)

		go countWorker(workerWg, &data, masterStats)

		// Save the inWord value for the next block.
		inWord = nextInWord
	}

	// Wait for the workers to finish.
	workerWg.Wait()

	return *masterStats, nil
}

// CountFile returns the Stats for filename.
func CountFile(filename string) (Stats, error) {
	file, err := os.Open(filename)
	if err != nil {
		return Stats{}, fmt.Errorf("failed to open file: %w", err)
	}
	defer file.Close()

	return Count(file)
}
