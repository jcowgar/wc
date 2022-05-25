package wc

import (
	"fmt"
	"reflect"
	"strings"
	"testing"

	"gotest.tools/v3/assert"
)

func TestCount(t *testing.T) {
	tests := []struct {
		name    string
		text    string
		want    Stats
		wantErr bool
	}{
		{"2 simple words.", "Hello World", Stats{Lines: 0, Words: 2, Chars: 11}, false},
		{
			"4 simple words, 2 lines.",
			"Hello World\nGoodbye World",
			Stats{Lines: 1, Words: 4, Chars: 25},
			false,
		},
		{
			"1 word with punctuation",
			"Hello.World",
			Stats{Lines: 0, Words: 1, Chars: 11},
			false,
		},
	}
	for _, tt := range tests {
		tt := tt

		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			r := strings.NewReader(tt.text)

			got, err := Count(r)
			if (err != nil) != tt.wantErr {
				t.Errorf("Count() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("Count() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestCountFile(t *testing.T) {
	if testing.Short() {
		t.Skip("skipping test count file in short mode.")
	}

	tests := []struct {
		name     string
		filename string
		want     Stats
		wantErr  bool
	}{
		{
			"moby dick",
			"../testdata/mobydick.txt",
			Stats{Lines: 15603, Words: 115314, Chars: 643210},
			false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := CountFile(tt.filename)
			if (err != nil) != tt.wantErr {
				t.Errorf("CountFile() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("CountFile() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestCountSlice(t *testing.T) {
	type args struct {
		data            []byte
		isAlreadyInWord bool
		into            Stats
	}
	tests := []struct {
		name   string
		args   args
		expect Stats
	}{
		{"Two words", args{[]byte("this that"), false, Stats{}}, Stats{Lines: 0, Words: 2, Chars: 9}},
		{"Two lines", args{[]byte("this that\nand the other\n"), false, Stats{}}, Stats{Lines: 2, Words: 5, Chars: 24}},
		{"Starting in word", args{[]byte("a word"), true, Stats{}}, Stats{Lines: 0, Words: 1, Chars: 6}},
		{"Unicode", args{[]byte("ü wórd"), false, Stats{}}, Stats{Lines: 0, Words: 2, Chars: uint64(len("ü wórd"))}},
		{"Tab", args{[]byte("a\tword"), false, Stats{}}, Stats{Lines: 0, Words: 2, Chars: uint64(len("a word"))}},
		{"Non-breaking space", args{
			[]byte("a" + string(rune(0xA0)) + "word"),
			false,
			Stats{},
		}, Stats{Lines: 0, Words: 2, Chars: uint64(len("a" + string(rune(0xA0)) + "word"))}},
		{"Breaking space", args{
			[]byte("a" + string(rune(0x85)) + "word"),
			false,
			Stats{},
		}, Stats{Lines: 0, Words: 2, Chars: uint64(len("a" + string(rune(0x85)) + "word"))}},
	}
	for _, tt := range tests {
		tt := tt
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			CountSlice(tt.args.data, tt.args.isAlreadyInWord, &tt.args.into)
			assert.DeepEqual(t, tt.expect, tt.args.into)
		})
	}
}

func BenchmarkCountFile(b *testing.B) {
	for i := 0; i < 1; i++ {
		if _, err := CountFile("../testdata/md-1000.txt"); err != nil {
			fmt.Println(err)
			return
		}
	}
}

func BenchmarkCountSlice(b *testing.B) {
	stats := Stats{}

	for i := 0; i < b.N; i++ {
		CountSlice([]byte("Some long string\nthat spans two lines\nor more\n"), false, &stats)
	}
}
