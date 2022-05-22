class Stats:
    """Represents the number of lines, words and characters counted."""
    lines = 0
    words = 0
    chars = 0


def count(fname, bufsize=1024*4):
    """Count the number of lines, words and characters found in fname."""
    stats = Stats()

    with open(fname) as f:
        inWord = False
        bytes = f.read(bufsize)
        while bytes:
            for byte in bytes:
                stats.chars += 1

                if byte.isalpha():
                    if inWord is False:
                        inWord = True
                        stats.words += 1
                elif byte == '\n':
                    stats.lines += 1
                    inWord = False
                else:
                    inWord = False
            bytes = f.read(bufsize)

    return stats
