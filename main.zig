const std = @import("std");
const wlr = @import("wlr.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var arg_iter = try std.process.argsWithAllocator(allocator);
    defer arg_iter.deinit();

    _ = arg_iter.next().?;

    const input = arg_iter.next() orelse {
        std.debug.print("Usage: ./transliterate-zig \"input\"\n", .{});
        return;
    };

    try wlr.SDK.startRuntime(.{
        .app_type = .Executable,
        .layout_dir = "/Applications/Wolfram.app/Contents",
    });

    const head = try wlr.Expr.symbol("Transliterate");
    const arg = try wlr.Expr.string(input);
    const normal = try head.construct(.{arg});
    const res = try normal.eval();

    const buffer = try res.stringData();
    defer wlr.release(buffer);
    std.debug.print("{s}\n", .{buffer});
}
