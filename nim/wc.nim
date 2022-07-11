import std/parseopt
import std/streams
import std/os

const
    BUFFER_SIZE = 1024 * 32

var
    displayLines = false
    displayWords = false
    displayChars = false
    files: seq[string]

var p = initOptParser(commandLineParams())
while true:
    p.next()

    case p.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
        case p.key
        of "l": displayLines = true
        of "w": displayWords = true
        of "m": displayChars = true
    of cmdArgument:
        add(files, p.key)

var
    totalLines = 0
    totalWords = 0
    totalChars = 0

for file in files:
    var strm = openFileStream(file)

    if not isNil(strm):
        var isWordChar = false
        var inWord = false

        var lines = 0
        var words = 0
        var chars = 0

        var buf: array[BUFFER_SIZE, char]

        while not strm.atEnd():
            let readLen = strm.readData(addr(buf), BUFFER_SIZE)
            chars += readLen

            for b in buf[0 .. readLen - 1]:
                isWordChar = b != ' ' and not (b >= '\t' and b <= '\n')
                lines += int(b == '\n')
                words += int(not inWord and isWordChar)
                inWord = isWordChar

        echo lines, " ", words, " ", chars, " ", file

        totalLines += lines
        totalWords += words
        totalChars += chars

if files.len > 1:
    echo totalLines, " ", totalWords, " ", totalChars, " total"

