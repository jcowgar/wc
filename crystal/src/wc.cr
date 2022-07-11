require "option_parser"

VERSION = "0.1.0"
BUFFER_SIZE = 1024 * 16

displayLineCount = false
displayWordCount = false
displayCharCount = false
files = [] of String

def report(lines, words, bytes, label)
	print("#{lines} ")
	print("#{words} ")
	print("#{bytes} ")
	print("#{label}\n")
end

OptionParser.parse do |parser|
	parser.banner = "Usage: wc [arguments]"
	parser.on("-l", "--lines", "Output number of lines") { displayLineCount = true }
	parser.on("-w", "--words", "Output number of words") { displayWordCount = true }
	parser.on("-m", "--bytes", "Output number of characters") { displayCharCount = true }
	parser.on("-h", "--help", "Show this help") do
		puts parser
		exit
	end
	parser.invalid_option do |flag|
		STDERR.puts "ERROR: #{flag} is not a valid option."
		STDERR.puts parser
		exit(1)
	end
	parser.unknown_args do |args|
		files = args
	end
end

if !displayLineCount && !displayWordCount && !displayCharCount
	displayLineCount = true
	displayWordCount = true
	displayCharCount = true
end

totalLines = 0
totalWords = 0
totalBytes = 0

files.each do |filename|
	file = File.open(filename, "r")

	lines = 0
	words = 0
	bytes = File.size(filename)

	inWord = false

	begin
		while true
			chars = file.read_string(BUFFER_SIZE)
			chars.each_byte do |b|
				isWordChar = b != 32 && !(b >= 9 && b <= 13) && b != 0x85 && b != 0xA0

				if isWordChar && !inWord
					words += 1
				elsif b == 10
					lines += 1
				end

				inWord = isWordChar
			end
		end
	rescue
	end

	report(lines, words, bytes, filename)

	totalLines += lines
	totalWords += words
	totalBytes += bytes
end

if files.size > 1
	report(totalLines, totalWords, totalBytes, "total")
end
