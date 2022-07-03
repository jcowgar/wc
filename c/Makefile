all: wc

wc: main.c
	gcc -std=c99 -pedantic -Wall -O3 -o wc main.c

.PHONY: clean

clean:
	rm wc
