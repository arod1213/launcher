const std = @import("std");
const launcher = @import("launcher");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    try launcher.run(alloc);
}
