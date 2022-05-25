use std::{fs::File, io::Read, path::Path};

/// Track the statistics of a single file count.
pub struct Stats {
    /// Number of lines counted.
    pub lines: usize,

    /// Number of words counted.
    pub words: usize,

    /// Number of characters counted.
    pub chars: usize,
}

static BUFFER_SIZE: usize = 16 * 1024;

/// Count the number of lines, words and characters in `fname`.
pub fn count_file(fname: &str) -> std::io::Result<Stats> {
    let path = Path::new(fname);

    let mut file = match File::open(path) {
        Err(err) => panic!("couldn't open {}: {}", fname, err),
        Ok(file) => file,
    };

    let mut lines = 0;
    let mut words = 0;
    let mut chars = 0;
    let mut buf = vec![0; BUFFER_SIZE];

    let mut in_word = false;
    let mut read_size = match file.read(&mut buf) {
        Ok(r) => r,
        Err(err) => panic!("{}", err),
    };

    while read_size > 0 {
        chars += read_size;

        for i in 0..read_size {
            let ch = buf[i];

            if ch > 32 && ch <= 127 {
                if !in_word {
                    in_word = true;
                    words += 1;
                }
            } else if ch == 0 {
                // ignore
            } else if ch <= 32 {
                if ch == 10 {
                    lines += 1;
                }

                in_word = false;
            } else if !in_word {
                in_word = true;
                words += 1;
            }
        }

        read_size = match file.read(&mut buf) {
            Ok(r) => r,
            Err(err) => panic!("{}", err),
        };
    }

    Ok(Stats {
        lines,
        words,
        chars,
    })
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
