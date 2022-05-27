import System.Environment
import System.IO
import Control.Monad

countLetters :: String -> Char -> Int
countLetters str c = length $ filter (== c) str

count :: Handle -> Int -> Int -> Int -> IO (Int, Int, Int)
count handle chars words lines = do
	eof <- hIsEOF handle
	if eof
		then return (chars - 1, words, lines - 1)
		else do
			line <- hGetLine handle
			count handle (chars + (length line) + 1) (words + (countLetters line ' ')) (lines + 1)

main = do
	args <- getArgs
	fh <- openFile (args !! 0) ReadMode
	hSetBuffering fh $ BlockBuffering (Just (16 * 1024))
	(chars, words, lines) <- count fh 0 0 0
	putStrLn $ show lines ++ " " ++ show words ++ " " ++ show chars

