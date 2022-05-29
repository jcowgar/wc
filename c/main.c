#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>

const int BUFSIZE = 1024*8;

int showLines = 0;
int showWords = 0;
int showChars = 0;

typedef struct {
	unsigned long lines;
	unsigned long words;
	unsigned long chars;
} Stats;

void report(Stats *s, char *label) {
	if (showLines == 1) {
		printf(" %7lu", s->lines);
	}
	if (showWords == 1) {
		printf(" %7lu", s->words);
	}
	if (showChars == 1) {
		printf(" %7lu", s->chars);
	}
	printf(" %s\n", label);
}

void word_count(char *fname, Stats *stats) {
	char buf[BUFSIZE];
	FILE *fp;

	int inWord = 0;
	int isWordChar = 0;
	int lines = 0;
	int words = 0;
	int chars = 0;

	char *p, *pe;

	fp = fopen(fname, "r");

	if (fp == NULL) {
		printf("couldn't open %s\n", fname);
		return;
	}

	while (feof(fp) == 0) {
		size_t read = fread(buf, sizeof(char), BUFSIZE, fp);
		p = &buf[0];
		pe = &buf[read];

		chars += read;

		while (p != pe) {
			char b = *p++;
			isWordChar = b != ' ' && !(b >= 9 && b <= 13) && b != 0xa5 && b != 0xa0;

            lines += b == 10;
            words += inWord == 0 && isWordChar == 1;
            inWord = isWordChar;
		}
	}

	stats->lines = lines;
	stats->words = words;
	stats->chars = chars;

	fclose(fp);
}

int parse_args(int argc, char **argv) {
	int argIndex = 1;
	if (argc < 2) {
		printf("usage: wc [-l -w -m] FILE [...FILE]\n");
		return 1;
	}

	for (; argIndex < argc; argIndex++) {
		if (strcmp(argv[argIndex], "-l") == 0) {
			showLines = 1;
		} else if (strcmp(argv[argIndex], "-w") == 0) {
			showWords = 1;
		} else if (strcmp(argv[argIndex], "-m") == 0) {
			showChars = 1;
		} else {
			break;
		}
	}

	if (showLines + showWords + showChars == 0) {
		showLines = showWords = showChars = 1;
	}

	return argIndex;
}


int main(int argc, char **argv) {
	Stats totals;
	totals.lines = 0;
	totals.words = 0;
	totals.chars = 0;

	int argIndex = parse_args(argc, argv);

	for (; argIndex < argc; argIndex++) {
		char *fname = argv[argIndex];

		Stats s;
		s.lines = 0;
		s.words = 0;
		s.chars = 0;

		word_count(fname, &s);

		report(&s, fname);
	}

	return 0;
}
