const std = @import("std");
const argsParser = @import("args");

const Stats = struct {
    lines: u32,
    words: u32,
    chars: u32,
};

var showLines: bool = false;
var showWords: bool = false;
var showChars: bool = false;

const stdout = std.io.getStdOut().writer();

pub fn main() anyerror!void {
    var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_instance.deinit();
    const arena = arena_instance.allocator();

    var files = std.ArrayList([]u8).init(arena);
    defer files.deinit();

    var args = try std.process.argsAlloc(arena);
    var argCount: u32 = 0;

    for (args) |arg| {
        if (std.mem.eql(u8, arg, "-l")) {
            showLines = true;
        } else if (std.mem.eql(u8, arg, "-w")) {
            showWords = true;
        } else if (std.mem.eql(u8, arg, "-m")) {
            showChars = true;
        } else if (argCount > 0) {
            try files.append(arg);
        }

        argCount += 1;
    }

    if (!showLines and !showWords and !showChars) {
        showLines = true;
        showWords = true;
        showChars = true;
    }

    var totals = Stats{ .lines = 0, .words = 0, .chars = 0 };

    for (files.items) |fname| {
        var f = try std.fs.cwd().openFile(fname, .{});
        defer f.close();

        var s = try count_lines(f);

        try report(s, fname);

        totals.lines += s.lines;
        totals.words += s.words;
        totals.chars += s.chars;
    }

    if (files.items.len > 1) {
        try report(totals, "total");
    }
}

pub fn report(s: Stats, label: []const u8) !void {
    if (showLines) {
        try stdout.print(" {d}", .{s.lines});
    }

    if (showWords) {
        try stdout.print(" {d}", .{s.words});
    }

    if (showChars) {
        try stdout.print(" {d}", .{s.chars});
    }

    try stdout.print(" {s}\n", .{label});
}

pub fn count_lines(f: std.fs.File) !Stats {
    var buf = std.io.bufferedReader(f.reader());
    var r = buf.reader();
    var b: u8 = 1;
    var s = Stats{ .lines = 0, .words = 0, .chars = 0 };
    var inWord = false;

    while (true) {
        // TODO handle any non-endOfStream errors
        b = r.readByte() catch {
            break;
        };

        if (b == '\n') {
            inWord = false;
            s.lines += 1;
        } else if ((b >= 'a' and b <= 'z') or (b >= 'A' and b <= 'Z')) {
            if (!inWord) {
                inWord = true;
                s.words += 1;
            }
        } else {
            inWord = false;
        }

        s.chars += 1;
    }

    return s;
}

test "mobydick.txt" {
    var f = try std.fs.cwd().openFile("../testdata/mobydick.txt", .{});
    defer f.close();

    var s = try count_lines(f);

    try std.testing.expect(s.lines == 15603);
    try std.testing.expect(s.words == 112151);
    try std.testing.expect(s.chars == 643210);
}
