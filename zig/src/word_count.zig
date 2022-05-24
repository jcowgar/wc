const std = @import("std");

/// Stats contains the line, word and char count for a call to `count_lines`.
pub const Stats = struct {
    const Self = @This();

    lines: usize,
    words: usize,
    chars: usize,

    pub fn empty() Self {
        return .{ .lines = 0, .words = 0, .chars = 0 };
    }
};

/// Count the number of lines, words and characters in `f`.
pub fn count_lines(f: std.fs.File) !Stats {
    var byteBuf = std.mem.zeroes([16 * 1024]u8);
    var r = f.reader();

    var bytesRead: usize = 0;
    var inWord = false;
    var lines: usize = 0;
    var words: usize = 0;
    var chars: usize = 0;

    while (true) {
        bytesRead = try r.read(&byteBuf);
        if (bytesRead == 0) {
            break;
        }

        chars += bytesRead;

        for (byteBuf[0..bytesRead]) |b| {
            switch (b) {
                33...127 => {
                    if (!inWord) {
                        inWord = true;
                        words += 1;
                    }
                },
                10 => {
                    inWord = false;
                    lines += 1;
                },
                1...9, 11...32 => {
                    inWord = false;
                },
                0 => {},
                else => {
                    if (!inWord) {
                        inWord = true;
                        words += 1;
                    }
                },
            }
        }
    }

    var s = Stats.empty();
    s.lines = lines;
    s.words = words;
    s.chars = chars;

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
