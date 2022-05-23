package wc

import (
	"reflect"
	"strings"
	"testing"
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
