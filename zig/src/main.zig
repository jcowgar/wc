const std = @import("std");
const wc = @import("word_count.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

var showLines: bool = false;
var showWords: bool = false;
var showChars: bool = false;

const stdout = std.io.getStdOut().writer();

pub fn main() anyerror!void {
    defer std.debug.assert(!gpa.deinit());
    const allocator = gpa.allocator();

    var files = try parseArgs(allocator);

    var totals = wc.Stats.empty();

    for (files) |fname| {
        var f = try std.fs.cwd().openFile(fname, .{});
        defer f.close();

        var s = try wc.count_lines(f);

        try report(s, fname);

        totals.lines += s.lines;
        totals.words += s.words;
        totals.chars += s.chars;
    }

    if (files.len > 1) {
        try report(totals, "total");
    }
}

fn parseArgs(allocator: std.mem.Allocator) ![]const []const u8 {
    var files = std.ArrayList([]u8).init(allocator);

    var args = try std.process.argsAlloc(allocator);
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

    return files.toOwnedSlice();
}

fn report(s: wc.Stats, label: []const u8) !void {
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
