use std::{fs::File, io::Read, iter::Sum, path::Path, sync::mpsc};
use workerpool::{Pool, Worker};

/// Track the statistics of a single file count.
#[derive(Debug, Default)]
pub struct Stats {
    /// Number of lines counted.
    pub lines: usize,

    /// Number of words counted.
    pub words: usize,

    /// Number of characters counted.
    pub chars: usize,
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

        Stats { lines, words, chars }
    }
}

static BUFFER_SIZE: usize = 16 * 1024;

/// Count the number of lines, words and characters in `fname`.
pub fn count_file(fname: &str) -> std::io::Result<Stats> {
    let n_workers = 16;
    let mut read_size: usize;
    let mut jobs: usize = 0;
    let pool = Pool::<Stats>::new(n_workers);
    let (tx, rx) = mpsc::channel();
    let mut file = File::open(Path::new(fname))
        .unwrap_or_else(|e| panic!("couldn't open file: {}", e));

    loop {
        let mut buf = vec![0; BUFFER_SIZE];
        read_size = file.read(&mut buf).unwrap_or_else(|e| panic!("{}", e));
        if read_size < BUFFER_SIZE {
            buf.truncate(read_size);
        }
        pool.execute_to(tx.clone(), buf);

        jobs += 1;

        if read_size < BUFFER_SIZE {
            break;
        }
    }

    let output: Stats = rx.iter().take(jobs).sum();

    Ok(output)
}
