# wc

Word Count implemented in various languages for learning. The word count program
is complex enough to explore the language but simple enough it can be written in
a timely fashion.

In addition the the actual program, the projects attempt to utilize the languages
module, documentation and unit testing systems. Regarding the lanugages module
system, a method of CountFile at minimum should be defined.

The Go application was the first and model (basic spec) for the others.

The purpose is not for an exact replica in each language adhering to a strict
standard, but a base replica to compare languages.

## Original Source

The source for the common unix utility wc is located at:

https://github.com/coreutils/coreutils/blob/master/src/wc.c


## Building

A Makefile should be introduced for each project as one may not remember how
to build, test or production documentation in a given language toolset. Minimum
targets should be the base (default) to build the application, clean, test and
optionally doc to generate documentation.
