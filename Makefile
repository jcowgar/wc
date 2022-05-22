all: warn

.PHONY: warn clean

warn:
	@echo "Top level makefile does nothing. It does"
	@echo "have two targets which 'may' be of interest."
	@echo "testdata/md-10.txt is mobydick.txt 10x"
	@echo "testdata/md-100.txt is mobydick.txt 100x"
	@echo "It will use hard drive space. Please do"
	@echo "not commit these to the repo."
	@echo ""
	@echo "You can run make bigdata to generate both."
	@echo ""
	@echo "for the insane, there is also bigbigdata which"
	@echo "is mobydick 1000x".

bigdata: testdata/md-10.txt testdata/md-100.txt

bigbigdata: testdata/md-1000.txt

testdata/md-10.txt: testdata/mobydick.txt
	cat testdata/mobydick.txt \
		testdata/mobydick.txt \
		testdata/mobydick.txt \
		testdata/mobydick.txt \
		testdata/mobydick.txt \
		testdata/mobydick.txt \
		testdata/mobydick.txt \
		testdata/mobydick.txt \
		testdata/mobydick.txt \
		testdata/mobydick.txt > testdata/md-10.txt

testdata/md-100.txt: testdata/md-10.txt
	cat testdata/md-10.txt \
		testdata/md-10.txt \
		testdata/md-10.txt \
		testdata/md-10.txt \
		testdata/md-10.txt \
		testdata/md-10.txt \
		testdata/md-10.txt \
		testdata/md-10.txt \
		testdata/md-10.txt \
		testdata/md-10.txt > testdata/md-100.txt

testdata/md-1000.txt: testdata/md-100.txt
	cat testdata/md-100.txt \
		testdata/md-100.txt \
		testdata/md-100.txt \
		testdata/md-100.txt \
		testdata/md-100.txt \
		testdata/md-100.txt \
		testdata/md-100.txt \
		testdata/md-100.txt \
		testdata/md-100.txt \
		testdata/md-100.txt > testdata/md-1000.txt

clean:
	rm -f testdata/md-10.txt testdata/md-100.txt testdata/md-1000.txt

