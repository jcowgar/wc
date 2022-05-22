lines = 0
words = 0
chars = 0

with open("../testdata/mobydick.txt") as f:
    inWord = False
    byte = f.read(1)
    while byte:
        chars += 1
        if byte == '\n':
            lines += 1
        elif byte >= 'A' and byte <= 'Z' or byte >= 'a' and byte <= 'z':
            if inWord is False:
                inWord = True
                words += 1
        else:
            inWord = False
        byte = f.read(1)

print(lines, words, chars)
