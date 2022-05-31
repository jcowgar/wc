using Printf

showLines = false
showWords = false
showChars = false

function count_words(fname::String)::Tuple{UInt64,UInt64,UInt64}
    inWord = false
    io = open(fname, "r")
    buf::Array{UInt8,1} = zeros(UInt8, 16 * 1024)

    chars::UInt64 = 0
    words::UInt64 = 0
    lines::UInt64 = 0

    while !eof(io)
        bytesRead = readbytes!(io, buf, sizeof(buf))
        chars += bytesRead

        @inbounds for b in buf[1:bytesRead]
            isWordChar = b != 32 && !(b >= 9 && b <= 13) && b != 0xa5 && b != 0xa0

            lines += b == 10
            words += !inWord && isWordChar
            inWord = isWordChar
        end
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

# total = Stats()
fileCount = 0

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

    # total.lines += s.lines
    # total.words += s.words
    # total.chars += s.chars
end

# if fileCount > 1
#     report(total, "total")
# end
