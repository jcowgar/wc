use std::{
    char,
    fs::File,
    io::{BufReader, Read},
    path::Path,
};

/// Track the statistics of a single file count.
pub struct Stats {
    /// Number of lines counted.
    pub lines: i32,

    /// Number of words counted.
    pub words: i32,

    /// Number of characters counted.
    pub chars: i32,
}

/// Count the number of lines, words and characters in `fname`.
pub fn count_file(fname: &str) -> std::io::Result<Stats> {
    let path = Path::new(fname);

    let file = match File::open(path) {
        Err(err) => panic!("couldn't open {}: {}", fname, err),
        Ok(file) => file,
    };

    let mut stats = Stats {
        lines: 0,
        words: 0,
        chars: 0,
    };

    let mut in_word = false;
    let reader = BufReader::new(file);
    for value in reader.bytes() {
        let ch = match value {
            Err(err) => panic!("could not read: {}", err),
            Ok(b) => b as char,
        };

        stats.chars += 1;

        match ch {
            'A'..='Z' | 'a'..='z' => {
                if !in_word {
                    in_word = true;
                    stats.words += 1;
                }
            }
            '\n' => {
                stats.lines += 1;
                in_word = false;
            }
            _ => in_word = false,
        }
    }

    Ok(stats)
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_count_file() {
        let s = match count_file("../testdata/mobydick.txt") {
            Err(err) => panic!("counting mobydick test data failed: {}", err),
            Ok(s) => s,
        };

        assert_eq!(s.lines, 15603, "lines should be 15603 but is {}", s.lines);
        assert_eq!(s.words, 112151, "words should be 112151 but is {}", s.words);
        assert_eq!(s.chars, 643210, "chars should be 643210 but is {}", s.chars);
    }
}
