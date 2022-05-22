#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>

const int BUFSIZE = 1024*4;

int showLines = 0;
int showWords = 0;
int showChars = 0;

struct Stats {
	unsigned long lines;
	unsigned long words;
	unsigned long chars;
};

void report(struct Stats *s, char *label) {
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

void word_count(char *fname, struct Stats *stats) {
	char buf[BUFSIZE];
	FILE *fp;

	int inWord = 0;
	int index = 0;

	fp = fopen(fname, "r");

	if (fp == NULL) {
		printf("couldn't open %s\n", fname);
		return;
	}

	while (feof(fp) == 0) {
		size_t read = fread(buf, sizeof(char), BUFSIZE, fp);

		for (index = 0; index < read; index++) {
			char ch = buf[index];

			stats->chars++;

			if (isalpha(ch)) {
				if (inWord == 0) {
					inWord = 1;
					stats->words++;
				}
			} else if (ch == '\n') {
				inWord = 0;
				stats->lines++;
			} else {
				inWord = 0;
			}
		}
	}

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
	struct Stats totals;
	totals.lines = 0;
	totals.words = 0;
	totals.chars = 0;

	int argIndex = parse_args(argc, argv);

	for (; argIndex < argc; argIndex++) {
		char *fname = argv[argIndex];

		struct Stats s;
		s.lines = 0;
		s.words = 0;
		s.chars = 0;

		word_count(fname, &s);

		report(&s, fname);
	}

	return 0;
}

