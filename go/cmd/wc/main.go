package main

import (
	"fmt"
	"os"

	wc "github.com/jcowgar/wc/go"
)

func main() {
	if len(os.Args) <= 1 {
		fmt.Printf("usage: wc FILE [...FILE]\n")
		os.Exit(1)
	}

	for _, fname := range os.Args[1:] {
		stats, err := wc.Count(fname)
		if err != nil {
			fmt.Printf("failed to count %s: %s\n", fname, err)
			continue
		}

		fmt.Printf("%s: %d/%d/%d\n", fname, stats.Lines, stats.Words, stats.Chars)
	}
}
