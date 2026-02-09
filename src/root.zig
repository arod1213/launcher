const std = @import("std");
const Allocator = std.mem.Allocator;
const zigkeys = @import("zigkeys");

const Plugin = @import("./plugin.zig").Plugin;

const Key = zigkeys.Key;
const Modifier = zigkeys.Modifier;

const T = *Plugin;
const KC = zigkeys.KeyCommand(T);

const setup = @import("./setup.zig");

fn handle(_: anytype, k: KC) !void {
    // std.log.info("TRIGGERING {s}", k.cmd.name);
    try k.cmd.execute();
}

pub fn run(alloc: Allocator) !void {
    const loader = setup.commandLoader(T);
    const kcs = try loader.parseCommands(alloc);
    var settings = zigkeys.Config(T).init(kcs);
    // settings.should_log = true;
    try zigkeys.run(alloc, T, &settings, null, handle);
}
