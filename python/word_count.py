class Stats:
    """Represents the number of lines, words and characters counted."""
    lines = 0
    words = 0
    chars = 0


def count_words(fname):
    """Count the number of lines, words and characters found in fname."""
    stats = Stats()

    with open(fname) as f:
        inWord = False
        byte = f.read(1)
        while byte:
            stats.chars += 1
            if byte == '\n':
                stats.lines += 1
            elif byte >= 'A' and byte <= 'Z' or byte >= 'a' and byte <= 'z':
                if inWord is False:
                    inWord = True
                    stats.words += 1
            else:
                inWord = False
            byte = f.read(1)

    return stats
