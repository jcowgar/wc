package main

import (
	"flag"
	"fmt"
	"os"
	"strings"

	wc "github.com/jcowgar/wc/go"
)

var (
	displayLineCount bool
	displayWordCount bool
	displayCharCount bool
)

func main() {
	flag.BoolVar(&displayLineCount, "l", false, "Output number of lines")
	flag.BoolVar(&displayWordCount, "w", false, "Output number of words")
	flag.BoolVar(&displayCharCount, "m", false, "Output number of characters")
	showHelp := flag.Bool("h", false, "Display help")
	flag.Parse()

	if *showHelp {
		usage(0)
	} else if len(flag.Args()) < 1 {
		usage(1)
	} else if !displayLineCount && !displayWordCount && !displayCharCount {
		displayLineCount = true
		displayWordCount = true
		displayCharCount = true
	}

	totalStats := wc.Stats{}

	for _, fname := range flag.Args() {
		stats, err := wc.CountFile(fname)
		if err != nil {
			fmt.Printf("failed to count %s: %s\n", fname, err)
			continue
		}

		reportStats(stats, fname)

		totalStats.Chars += stats.Chars
		totalStats.Words += stats.Words
		totalStats.Lines += stats.Lines
	}

	if len(flag.Args()) > 1 {
		reportStats(totalStats, "total")
	}
}

func usage(exitCode int) {
	fmt.Fprintf(os.Stderr, "usage: wc FILE [...FILE]\n\n")
	flag.PrintDefaults()

	os.Exit(exitCode)
}

func reportStats(stats wc.Stats, label string) {
	parts := []string{}

	if displayLineCount {
		parts = append(parts, fmt.Sprintf("%7d", stats.Lines))
	}

	if displayWordCount {
		parts = append(parts, fmt.Sprintf("%7d", stats.Words))
	}

	if displayCharCount {
		parts = append(parts, fmt.Sprintf("%7d", stats.Chars))
	}

	fmt.Printf(" %s %s\n", strings.Join(parts, " "), label)
}
