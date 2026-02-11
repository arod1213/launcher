const std = @import("std");
const launcher = @import("launcher");
const menuczar = @import("menuczar");

// const posix = std.posix;
// fn setupTermios(handle: posix.fd_t) !void {
//     var settings = try posix.tcgetattr(handle);
//     settings.lflag.ICANON = false;
//     settings.lflag.ECHO = false;
//     _ = try posix.tcsetattr(handle, posix.TCSA.NOW, settings);
// }

// const stdin = std.fs.File.stdin();
// try setupTermios(stdin.handle);

fn appLoop() void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    launcher.run(alloc) catch @panic("failed to run app");
}

pub fn main() !void {
    try menuczar.run(.{ .icon = "paperplane" }, appLoop);
}
