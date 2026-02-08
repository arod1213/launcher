const std = @import("std");
const Allocator = std.mem.Allocator;
const zigkeys = @import("zigkeys");

const Plugin = @import("./plugin.zig").Plugin;

const Key = zigkeys.Key;
const Modifier = zigkeys.Modifier;

const T = *Plugin;
const KC = zigkeys.KeyCommand(T);

fn handle(_: anytype, k: KC) !void {
    try k.cmd.execute();
}

fn installPath(alloc: Allocator) ![]const u8 {
    const home = std.posix.getenv("HOME") orelse return error.NoHomeDir;
    return try std.fmt.allocPrint(alloc, "{s}/documents/launcher/plugins", .{home});
}

fn loadKeyCommands(alloc: Allocator) ![]const KC {
    const install_path = try installPath(alloc);
    var dir = try std.fs.openDirAbsolute(install_path, .{ .iterate = true });
    defer dir.close();

    var key_commands = try std.ArrayList(KC).initCapacity(alloc, 5);
    defer key_commands.deinit(alloc);

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.endsWith(u8, entry.name, ".lua")) continue;

        const path = try std.fs.path.join(alloc, &[_][]const u8{ install_path, entry.name });
        const plugin_ptr = try alloc.create(Plugin);
        plugin_ptr.* = try Plugin.init(alloc, @ptrCast(path), entry.name);

        const kc = plugin_ptr.getKey(alloc) catch |err| {
            std.log.err("Failed to get key command from '{s}': {}", .{ entry.name, err });
            plugin_ptr.deinit();
            continue;
        };
        // std.log.info("key {f} for {s}", .{ kc.key, kc.use });

        try key_commands.append(alloc, kc);
    }

    if (key_commands.items.len == 0) {
        std.log.warn("No plugins loaded from {s}", .{install_path});
        return error.NoPlugins;
    }

    std.log.info("Successfully loaded {} plugin(s)", .{key_commands.items.len});
    return try key_commands.toOwnedSlice(alloc);
}

pub fn run(alloc: Allocator) !void {
    const kcs = try loadKeyCommands(alloc);
    var settings = zigkeys.Config(T).init(kcs);
    // settings.should_log = true;
    try zigkeys.run(alloc, T, &settings, null, handle);
}
