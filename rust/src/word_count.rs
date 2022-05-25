use std::{fs::File, io::Read, iter::Sum, path::Path, sync::mpsc};
use workerpool::{Pool, Worker};

fn is_space(v:u8) -> bool {
    (v > 0 && v <= 32) || v == 0x85 || v == 0xA0
}

pub struct JobData {
    buf: Vec<u8>,
    in_word: bool,
    return_channel: mpsc::Sender<Vec<u8>>,
}

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
    type Input = JobData;
    type Output = Stats;

    fn execute(&mut self, job_data: Self::Input) -> Self::Output {
        let chars = job_data.buf.len();
        let mut words: usize = 0;
        let mut lines: usize = 0;
        let mut in_word = job_data.in_word;

        for ch in &job_data.buf {
            if ch > &32 && ch <= &127 {
                if !in_word {
                    in_word = true;
                    words += 1;
                }
            } else if is_space(*ch) {
                if ch == &10 {
                    lines += 1;
                }

                in_word = false;
            } else if ch == &0 {
                // ignore
            } else if !in_word {
                in_word = true;
                words += 1;
            }
        }

        job_data.return_channel.send(job_data.buf).unwrap_or_else(|e| panic!("send job data back failed: {}", e));

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
    let (tx_job_data, rx_job_data) = mpsc::channel();
    let mut file = File::open(Path::new(fname))
        .unwrap_or_else(|e| panic!("couldn't open file: {}", e));

    let mut in_word = false;

    loop {
        let mut buf = match rx_job_data.try_recv() {
            Err(_) => vec![0; BUFFER_SIZE],
            Ok(v) => v,
        };

        read_size = file.read(&mut buf).unwrap_or_else(|e| panic!("{}", e));
        if read_size < BUFFER_SIZE {
            buf.truncate(read_size);
        }

        let rd = JobData{buf, in_word, return_channel: tx_job_data.clone()};
        in_word = !is_space(rd.buf[read_size - 1]);

        pool.execute_to(tx.clone(), rd);

        jobs += 1;

        if read_size < BUFFER_SIZE {
            break;
        }
    }

    let output: Stats = rx.iter().take(jobs).sum();

    Ok(output)
}
