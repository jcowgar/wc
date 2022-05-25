package wc

import (
	"bufio"
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

// CountSlice gets stats from a slice and increments the given Stats
// in a thread-safe way.
//
// isAlreadyInWord will not count the first word it encounters before any whitespace.
//
// into is a reference to the Stats that will be updated.
func CountSlice(data []byte, isAlreadyInWord bool, into *Stats) {
	var lines, words uint64

	inWord := isAlreadyInWord

	for _, thisByte := range data {
		switch {
		// Optimize for most likely case (ASCII)
		case thisByte > 32 && thisByte <= 127:
			if !inWord {
				inWord = true
				words++
			}

		case isAnyWhitespace(thisByte):
			if thisByte == '\n' {
				lines++
			}

			inWord = false

		case thisByte == 0:
			// Ignore nulls entirely, which will let UTF-16 and UTF-32 work correctly.

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
	bytesRead := len(data)
	atomic.AddUint64(&into.Lines, lines)
	atomic.AddUint64(&into.Words, words)
	atomic.AddUint64(&into.Chars, uint64(bytesRead))
}

// Set up the workers.
type workerData struct {
	Buf       []byte
	BytesRead uint64
	InWord    bool
}

// countWorker will run as a job to count the given data and
// increment the values in the given stats. It gets its data
// through the dataChannel and returns it for reuse through
// the returnChannel.
func countWorker(
	waitGroup *sync.WaitGroup,
	dataChannel chan *workerData,
	returnChannel chan *workerData,
	stats *Stats,
) {
	for data := range dataChannel {
		CountSlice(data.Buf[:data.BytesRead], data.InWord, stats)

		// Return the workerData
		returnChannel <- data
	}

	// ... and we're done.
	waitGroup.Done()
}

// Count returns the Stats for the io.Reader.
func Count(source io.Reader) (Stats, error) {
	// Set up the masterStats.
	masterStats := &Stats{}

	// Number of cores.
	maxJobs := runtime.GOMAXPROCS(0)
	if maxJobs < 1 {
		maxJobs = 1
	}

	// Buffer the source.
	bufSource := bufio.NewReaderSize(source, bufferSize*maxJobs)

	// Configure the jobs.
	workerWg := &sync.WaitGroup{}

	dataChannel := make(chan *workerData, maxJobs)
	returnChannel := make(chan *workerData, maxJobs)

	runningJobs := 0

	// Track whether the last block started in a word.
	inWord := false

	// Read the data in blocks and ship them off
	// to new or existing workers. We will reuse workerData
	// through the channels for performance.
	for {
		// Create or fetch the workerData, and start a new job if needed.
		var data workerData

		if runningJobs < maxJobs {
			// We need a new job and new data.
			data = workerData{Buf: make([]byte, bufferSize), BytesRead: 0, InWord: inWord}

			// Start the worker.
			workerWg.Add(1)
			go countWorker(workerWg, dataChannel, returnChannel, masterStats)

			runningJobs++
		} else {
			// Fetch data for reuse.
			data = *<-returnChannel
		}

		// Read a block.
		bytesRead, err := bufSource.Read(data.Buf)
		if err != nil {
			if err == io.EOF {
				// We're done.
				break
			}

			// Something else has gone wrong.
			return Stats{}, fmt.Errorf("failure during read: %w", err)
		}

		// Fill in data properties.
		data.BytesRead = uint64(bytesRead)
		data.InWord = inWord

		// Save the inWord value for the next block.
		inWord = !isAnyWhitespace(data.Buf[bytesRead-1])

		// Ship off the data.
		dataChannel <- &data
	}

	// Wait for the workers to finish.
	close(dataChannel)
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
