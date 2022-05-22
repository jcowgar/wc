import unittest
import word_count


class TestWordCount(unittest.TestCase):
    def test_word_count(self):
        s = word_count.count("../testdata/mobydick.txt")
        self.assertEqual(s.lines, 15603)
        self.assertEqual(s.words, 112151)
        self.assertEqual(s.chars, 643210)


if __name__ == '__main__':
    unittest.main()
