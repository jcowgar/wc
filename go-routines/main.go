package wc

import (
	"fmt"
	"io"
	"os"
	"runtime"
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

// Set up the workers

type workerData struct {
	Buf       []byte
	BytesRead uint64
	InWord    bool
}

// countWorker will run as a job to count the data given in the workerData channel.
// It will return its Stats to the statChannel.
func countWorker(wg *sync.WaitGroup, dataChannel <-chan *workerData, stats *Stats) {
	for data := range dataChannel {
		inWord := data.InWord

		var lines, words uint64

		for _, b := range data.Buf[:data.BytesRead] {
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

			case isAnyWhitespace(b):
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

		atomic.AddUint64(&stats.Lines, lines)
		atomic.AddUint64(&stats.Words, words)
		atomic.AddUint64(&stats.Chars, data.BytesRead)
	}

	wg.Done()
}

// Count returns the Stats for the io.Reader.
func Count(r io.Reader) (Stats, error) {
	// Figure out the max maxJobs.
	maxJobs := runtime.GOMAXPROCS(0)
	if maxJobs < 1 {
		maxJobs = 1
	}

	// Track how many jobs we've started.
	var runningJobs int

	// Set up the masterStats.
	masterStats := &Stats{}

	// Set up the channel.
	dataChannel := make(chan *workerData, maxJobs)

	// Create the workerWg.
	workerWg := &sync.WaitGroup{}

	// Track whether the last block started in a word.
	inWord := false

	// Read from the buffer.
	for {
		// See if we need another job.
		if runningJobs < maxJobs {
			workerWg.Add(1)
			go countWorker(workerWg, dataChannel, masterStats)
			runningJobs++
		}

		data := workerData{Buf: make([]byte, bufferSize), InWord: inWord, BytesRead: 0}

		bytesRead, e := r.Read(data.Buf)
		if e != nil {
			if e == io.EOF {
				break
			}

			return Stats{}, fmt.Errorf("failure during read: %w", e)
		}

		data.BytesRead = uint64(bytesRead)
		nextInWord := !isAnyWhitespace(data.Buf[bytesRead-1])

		dataChannel <- &data
		inWord = nextInWord
	}

	// Wait for the workers to finish.
	close(dataChannel)
	workerWg.Wait()

	return *masterStats, nil
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
