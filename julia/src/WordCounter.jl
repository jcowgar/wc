module WordCounter
    export count, Stats

    const BUFFER_SIZE = 16 * 1024

    struct Stats
        "Number of lines counted"
        lines

        "Number of words counted"
        words

        "Number of characters counted"
        chars
    end

    "Count a single chunk of a file"
    function _count_chunk(buf, bytesRead, inWord, lines, words)
        for b in buf[1:bytesRead]
            isWordChar = !(b == 32 || (b >= 9 && b <= 13) || b == 0xa5 || b == 0xa0)

            lines += b == 10
            words += !inWord && isWordChar

            inWord = isWordChar
        end

        (lines, words)
    end

    "Count the number of lines, words and characters in a file."
    function count(fname::String)::Stats
        buf::Array{UInt8} = zeros(UInt8, BUFFER_SIZE)
        inWord::Bool = false

        lines::UInt32 = 0
        words::UInt32 = 0
        chars::UInt32 = 0

        io = open(fname, "r")

        while !eof(io)
            bytesRead = readbytes!(io, buf, BUFFER_SIZE)
            chars += bytesRead

            (lines, words) = _count_chunk(buf, bytesRead, inWord, lines, words)
        end

        close(io)

        return Stats(lines, words, chars)
    end
end