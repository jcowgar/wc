package wc

// Stats tracks the Character, Word and Line count.
type Stats struct {
	// Chars is the number of characters counted.
	Chars int

	// Words is the number of words counted. A single word is
	// defined by one or more Unicode Letter characters separated
	// by a non Unicode Letter character.
	Words int

	// Lines is the number of lines counted. Lines is computed
	// by the number of Newline (\n) characters.
	Lines int
}
