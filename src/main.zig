const std = @import("std");
const snake = @import("./snake.zig");

pub fn main() !void {
    std.debug.print("Hello", .{});
    try snake.playGame();
}
