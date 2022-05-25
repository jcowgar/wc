use clap::Parser;

mod word_count;

#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct Args {
    /// Output number of lines
    #[clap(short = 'l', long = "lines")]
    show_lines: bool,

    /// Output number of words
    #[clap(short = 'w', long = "words")]
    show_words: bool,

    /// Output number of characters
    #[clap(short = 'm', long = "characters")]
    show_chars: bool,

    /// Files to count
    #[clap()]
    files: Vec<String>,
}

fn main() {
    let mut args = Args::parse();

    if !args.show_lines && !args.show_words && !args.show_chars {
        args.show_lines = true;
        args.show_words = true;
        args.show_chars = true;
    }

    let mut total_stats = word_count::Stats {
        lines: 0,
        words: 0,
        chars: 0,
    };

    for fname in &args.files {
        match word_count::count_file(fname) {
            Err(err) => panic!("count_file failed: {}", err),
            Ok(stats) => {
                total_stats.lines += stats.lines;
                total_stats.words += stats.words;
                total_stats.chars += stats.chars;

                report_stats(&args, stats, fname);
            }
        }
    }

    if args.files.len() > 1 {
        report_stats(&args, total_stats, "total");
    }
}

fn report_stats(args: &Args, stats: word_count::Stats, label: &str) {
    if args.show_lines {
        print!(" {:7}", stats.lines)
    }

    if args.show_words {
        print!(" {:7}", stats.words)
    }

    if args.show_chars {
        print!(" {:7}", stats.chars)
    }

    println!(" {}", label);
}
