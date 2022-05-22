zig-out/bin/wc: src/main.zig src/word_count.zig build.zig
	zig build -Drelease-fast=true

.PHONY: clean test

clean:
	rm -rf zig-cache zig-out

test:
	zig test ./src/word_count.zig
