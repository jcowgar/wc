const std = @import("std");

/// Stats contains the line, word and char count for a call to `count_lines`.
pub const Stats = struct {
    const Self = @This();

    lines: u32,
    words: u32,
    chars: u32,

    pub fn empty() Self {
        return .{ .lines = 0, .words = 0, .chars = 0 };
    }
};

/// Count the number of lines, words and characters in `f`.
pub fn count_lines(f: std.fs.File) !Stats {
    var buf = std.io.bufferedReader(f.reader());
    var r = buf.reader();
    var b: u8 = 1;
    var s = Stats.empty();
    var inWord = false;

    while (true) {
        // TODO handle any non-endOfStream errors
        b = r.readByte() catch {
            break;
        };

        if (b == '\n') {
            inWord = false;
            s.lines += 1;
        } else if (b == ' ' or b == '\t' or b == '\r') {
            inWord = false;
        } else {
            if (!inWord) {
                inWord = true;
                s.words += 1;
            }
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
