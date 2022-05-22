import * as fs from 'fs'

class Stats {
	public lines: number
	public words: number
	public chars: number

	constructor() {
		this.lines = 0
		this.words = 0
		this.chars = 0
	}
}

async function main() {
	console.log(await word_count('../testdata/mobydick.txt'))
}

function word_count(fname: string): Promise<Stats> {
	return new Promise((res, rej) => {
		const stats = new Stats()
		let inWord = false;

		const rs = fs.createReadStream(fname)
		rs.on('error', rej)
		rs.on('data', (chunk) => {
			const s = chunk.toString()

			for (let i = 0; i < s.length; i++) {
				const ch = s[i];

				stats.chars++

				if (ch >= 'A' && ch <= 'Z' || ch >= 'a' && ch <= 'z') {
					if (!inWord) {
						inWord = true
						stats.words++
					}
				} else if (ch == '\n') {
					inWord = false
					stats.lines++
				} else {
					inWord = false
				}
			}
		})
		rs.on('end', () => {
			res(stats)
		})
	})
}

main()
