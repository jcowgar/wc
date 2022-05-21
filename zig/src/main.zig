const std = @import("std");

const Stats = struct {
    lines: u32,
    words: u32,
    chars: u32,
};

pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();

    var f = try std.fs.cwd().openFile("../testdata/mobydick.txt", .{});
    var s = try count_lines(f);
    try stdout.print(" {d} {d} {d}!\n", .{ s.lines, s.words, s.chars });
}

pub fn count_lines(f: std.fs.File) !Stats {
    var r2 = f.reader();
    var buf = std.io.bufferedReader(r2);
    var r = buf.reader();
    var b: u8 = 1;
    var s = Stats{ .lines = 0, .words = 0, .chars = 0 };

    while (true) {
        b = r.readByte() catch {
            break;
        };

        if (b == '\n') {
            s.lines += 1;
        }

        s.chars += 1;
    }

    return s;
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
