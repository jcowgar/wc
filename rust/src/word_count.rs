use std::{fs::File, io::Read, iter::Sum, path::Path, sync::mpsc};
use workerpool::{Pool, Worker};

/// Track the statistics of a single file count.
#[derive(Debug)]
pub struct Stats {
    /// Number of lines counted.
    pub lines: usize,

    /// Number of words counted.
    pub words: usize,

    /// Number of characters counted.
    pub chars: usize,
}

impl Default for Stats {
    fn default() -> Self {
        Stats {
            lines: 0,
            words: 0,
            chars: 0,
        }
    }
}

impl Sum for Stats {
    fn sum<I: Iterator<Item = Self>>(iter: I) -> Self {
        let mut result = Stats::default();

        for s in iter {
            result.lines += s.lines;
            result.words += s.words;
            result.chars += s.chars;
        }

        result
    }
}

impl Worker for Stats {
    type Input = Vec<u8>;
    type Output = Stats;

    fn execute(&mut self, inp: Self::Input) -> Self::Output {
        let chars = inp.len();
        let mut words: usize = 0;
        let mut lines: usize = 0;
        let mut in_word = false;

        for ch in inp {
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

        Stats {
            lines,
            words,
            chars,
        }
    }
}

static BUFFER_SIZE: usize = 16 * 1024;

/// Count the number of lines, words and characters in `fname`.
pub fn count_file(fname: &str) -> std::io::Result<Stats> {
    let n_workers = 6;
    let mut read_size: usize;
    let mut jobs: usize = 0;
    let pool = Pool::<Stats>::new(n_workers);
    let (tx, rx) = mpsc::channel();
    let mut file = match File::open(Path::new(fname)) {
        Err(err) => panic!("couldn't open file: {}", err),
        Ok(value) => value,
    };

    loop {
        let mut buf: Vec<u8> = Vec::with_capacity(BUFFER_SIZE);
        buf.resize(BUFFER_SIZE, 0);

        read_size = match file.read(&mut buf) {
            Ok(r) => r,
            Err(err) => panic!("{}", err),
        };

        pool.execute_to(tx.clone(), buf);

        jobs += 1;

        if read_size < BUFFER_SIZE {
            break;
        }
    }

    let output: Stats = rx.iter().take(jobs).sum();

    Ok(output)
}
