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

let showLines = false
let showWords = false
let showChars = false

async function main() {
	const files = parseArgs()

	for (let f of files) {
		const stats = await word_count(f)
		showReport(stats, f)
	}
}

function parseArgs(): string[] {
	const args = require('yargs')
		.scriptName('wc')
		.usage('$0 [args] FILE [...FILE]')
		.option('lines', {
			alias: 'l',
			type: 'boolean',
			describe: 'Show line count',
		})
		.option('words', {
			alias: 'w',
			type: 'boolean',
			describe: 'Show word count',
		})
		.option('chars', {
			alias: 'm',
			type: 'boolean',
			describe: 'Show character count',
		})
		.argv

	showLines = args.lines === true
	showWords = args.words === true
	showChars = args.chars === true

	if (!showLines && !showWords && !showChars) {
		showLines = showWords = showChars = true
	}

	return args._
}

function showReport(stats: Stats, label: string) {
	const p = (n: number) => process.stdout.write(`${n}`.padStart(8))

	if (showLines) {
		p(stats.lines)
	}
	if (showWords) {
		p(stats.words)
	}
	if (showChars) {
		p(stats.chars)
	}

	process.stdout.write(` ${label}\n`)
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
