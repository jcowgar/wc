using Printf

showLines = false
showWords = false
showChars = false

mutable struct Stats
    lines
    words
    chars

    Stats() = new(0, 0, 0)
end

function count_words(fname::String)::Stats
    inWord = false
    io = open(fname, "r")
    buf::Array{UInt8,1} = zeros(UInt8, 16 * 1024)

    chars = 0
    words = 0
    lines = 0

    while !eof(io)
        bytesRead = readbytes!(io, buf, sizeof(buf))
        chars += bytesRead

        for b in buf[1:bytesRead]
            if b > 32 && b <= 127
                if !inWord
                    inWord = true
                    words += 1
                end
            elseif b == 0x0A
                lines += 1
                inWord = false
            elseif b == 0
                # Ignore NULLs
            elseif b <= 0x20 || b == 0xA0 || b == 0x85
                inWord = false
            elseif !inWord
                inWord = true
                words += 1
            end
        end
    end

    close(io)

    s = Stats()
    s.lines = lines
    s.words = words
    s.chars = chars

    return s
end

function report(s, label)
    if showLines
        @printf("%7d", s.lines)
    end
    if showWords
        @printf(" %7d", s.words)
    end
    if showChars
        @printf(" %7d", s.chars)
    end

    @printf(" %s\n", label)
end

total = Stats()
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
    s = count_words(arg)

    report(s, arg)

    total.lines += s.lines
    total.words += s.words
    total.chars += s.chars
end

if fileCount > 1
    report(total, "total")
end


