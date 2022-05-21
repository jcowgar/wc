all: target/release/wc

target/release/wc: src/main.rs src/word_count.rs
	cargo build --release

.PHONY: clean test

test:
	cargo test

clean:
	rm -rf target
