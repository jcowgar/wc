package wc

type statCounter struct {
	Stats

	inWord bool
}

func (s *statCounter) countByte(b byte) {
	s.Chars++

	switch {
	case b > 32 && b <= 127:
		if !s.inWord {
			s.inWord = true
			s.Words++
		}

	case b == '\n':
		s.inWord = false
		s.Lines++

	case b == 0:
		// Ignore nulls entirely, which will let UTF-16 and UTF-32 work correctly.

	case b <= 32, b == 0x85, b == 0xa0:
		s.inWord = false

	// Leave even though first switch condition is duplicate. This will
	// catch non-standard Unicode situations.
	default:
		if !s.inWord {
			s.inWord = true
			s.Words++
		}
	}
}

func (s *statCounter) countBlock(buf []byte) {
	for _, b := range buf {
		s.countByte(b)
	}
}
