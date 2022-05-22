import argparse
import word_count


showLines = False
showWords = False
showChars = False


def report(s, label):
    values = ['']

    if showLines is True:
        values.append('{:-7}'.format(s.lines))
    if showWords is True:
        values.append('{:-7}'.format(s.words))
    if showChars is True:
        values.append('{:-7}'.format(s.chars))
    values.append(label)

    print(*values)


def parse_arguments():
    global showLines, showWords, showChars

    parser = argparse.ArgumentParser(
        description='Count the number of lines, words and characters in a file'
    )
    parser.add_argument('-l', help='Show the number of lines',
                        dest='showLines',
                        action=argparse.BooleanOptionalAction)
    parser.add_argument('-w', help='Show the number of words',
                        dest='showWords',
                        action=argparse.BooleanOptionalAction)
    parser.add_argument('-m', help='Show the number of characters',
                        dest='showChars',
                        action=argparse.BooleanOptionalAction)
    parser.add_argument('rest', nargs=argparse.REMAINDER)
    args = parser.parse_args()

    showLines = args.showLines is True
    showWords = args.showWords is True
    showChars = args.showChars is True

    if showLines is False and showWords is False and showChars is False:
        showLines = True
        showWords = True
        showChars = True

    return args.rest


def main():
    files = parse_arguments()
    stats = word_count.Stats()

    for f in files:
        s = word_count.count_words(f)
        report(s, f)

        stats.lines += s.lines
        stats.words += s.words
        stats.chars += s.chars

    if len(files) > 1:
        report(stats, "total")


main()
