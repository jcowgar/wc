mutable struct Stats
    lines
    words
    chars

    Stats() = new(0, 0, 0)
end

function count_words(fname::String)::Stats
    inWord = false
    s = Stats()

    io = open(fname, "r")

    while !eof(io)
        bytes = read(io, 1024 * 16)

        for b in bytes
            s.chars += 1

            if b == 0x0A
                s.lines += 1
                inWord = false
            elseif b <= 0x20 || b == 0xA0 || b == 0x85
                inWord = false
            elseif !inWord
                inWord = true
                s.words += 1
            end
        end
    end

    close(io)

    return s
end

s = count_words("../testdata/mobydick.txt")

show(s)

