using Printf

showLines = false
showWords = false
showChars = false

function count_char(inWord::Bool, b::UInt8)::Tuple{Bool,UInt64,UInt64}
    isWordChar = b != 32 && !(b >= 9 && b <= 13) && b != 0xa5 && b != 0xa0

    lines = b == 10
    words = !inWord && isWordChar
    inWord = isWordChar

    (inWord, lines, words)
end

function count_block(inWord::Bool, block)::Tuple{Bool,UInt64,UInt64}
    lines = 0
    words = 0

    for b in block
        (inWord, rlines, rwords) = count_char(inWord, b)
        lines += rlines
        words += rwords
    end

    (inWord, lines, words)
end

"Tally the number of lines, words and characters in `fname`."
function count_words(fname::String)::Tuple{UInt64,UInt64,UInt64}
    io = open(fname, "r")
    buf::Array{UInt8,1} = zeros(UInt8, 16 * 1024)

    inWord = false
    lines = 0
    words = 0
    chars = 0

    while !eof(io)
        bytesRead = readbytes!(io, buf, sizeof(buf))
        chars += bytesRead

        (inWord, rlines, rwords) = count_block(inWord, buf[1:bytesRead])
        lines += rlines
        words += rwords
    end

    close(io)

    (lines, words, chars)
end

function report(lines, words, chars, label)
    if showLines
        @printf("%7d", lines)
    end
    if showWords
        @printf(" %7d", words)
    end
    if showChars
        @printf(" %7d", chars)
    end

    @printf(" %s\n", label)
end

fileCount = 0
lines = 0
words = 0
chars = 0

for arg in ARGS
    if arg == "-l"
        global showLines = true
        continue
    elseif arg == "-w"
        global showWords = true
        continue
    elseif arg == "-m"
        global showChars = true
        continue
    end

    if showLines == false && showWords == false && showChars == false
        showLines = true
        showWords = true
        showChars = true
    end

    global fileCount += 1
    (rlines, rwords, rchars) = count_words(arg)

    report(rlines, rwords, rchars, arg)

    global lines += rlines
    global words += rwords
    global chars += rchars
end

if fileCount > 1
    report(lines, words, chars, "total")
end
