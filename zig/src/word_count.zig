const std = @import("std");

/// Stats contains the line, word and char count for a call to `count_lines`.
pub const Stats = struct {
    const Self = @This();

    lines: u64,
    words: u64,
    chars: u64,

    pub fn empty() Self {
        return .{ .lines = 0, .words = 0, .chars = 0 };
    }
};

/// Count the number of lines, words and characters in `f`.
pub fn count_lines(f: std.fs.File) !Stats {
    var byteBuf = std.mem.zeroes([16 * 1024]u8);
    var s = Stats.empty();
    var r = f.reader();
    var inWord = false;
    var bytesRead: u64 = 0;

    while (true) {
        bytesRead = try r.read(&byteBuf);
        if (bytesRead == 0) {
            break;
        }

        s.chars += bytesRead;

        for (byteBuf[0..bytesRead]) |b| {
            if (b == '\n') {
                inWord = false;
                s.lines += 1;
            } else if (b <= 32) {
                inWord = false;
            } else if (!inWord) {
                inWord = true;
                s.words += 1;
            }
        }
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
