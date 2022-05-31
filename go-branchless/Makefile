all: wc

wc_pkg_sources := $(wildcard *.go)
wc_bin_sources := $(wildcard cmd/wc/*.go)

wc: $(wc_pkg_sources) $(wc_bin_sources)
	go build -o wc ./cmd/wc/main.go

.PHONY: clean test

test:
	go test ./...

clean:
	rm -f wc
