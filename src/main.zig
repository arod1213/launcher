const std = @import("std");
const launcher = @import("launcher");
const posix = std.posix;

fn setupTermios(handle: posix.fd_t) !void {
    var settings = try posix.tcgetattr(handle);
    settings.lflag.ICANON = false;
    settings.lflag.ECHO = false;
    _ = try posix.tcsetattr(handle, posix.TCSA.NOW, settings);
}

pub fn main(init: std.process.Init) !void {
    const home = init.environ_map.get("HOME") orelse @panic("missing HOME");
    const io = init.io;
    // const stdin = std.Io.File.stdin();
    // try setupTermios(stdin.handle);

    const alloc = init.arena.allocator();

    try launcher.run(io, alloc, home);
}
