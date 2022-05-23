all: wc

wc: cmd/wc/main.go main.go
	go build -o wc ./cmd/wc/main.go

.PHONY: clean test

test:
	go test ./...

clean:
	rm -f wc
