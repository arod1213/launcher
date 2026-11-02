const std = @import("std");
const Allocator = std.mem.Allocator;
const Io = std.Io;
const zigkeys = @import("zigkeys");

const Plugin = @import("./plugin.zig").Plugin;

const Key = zigkeys.Key;
const Modifier = zigkeys.Modifier;
const KeyCommand = zigkeys.KeyCommand;

fn installPath(alloc: Allocator, home: []const u8) ![]const u8 {
    return try std.fmt.allocPrint(alloc, "{s}/documents/launcher/plugins", .{home});
}

// TODO: this is not type agnostic
// Plugin is defined inside
pub fn commandLoader(comptime T: type) type {
    return struct {
        const KC = KeyCommand(T);

        fn getCommand(alloc: Allocator, install_path: []const u8, entry: Io.Dir.Entry) !KC {
            if (entry.kind != .file) return error.InvalidType;
            if (!std.mem.endsWith(u8, entry.name, ".lua")) return error.InvalidExtension;

            const path = try std.fs.path.join(alloc, &[_][]const u8{ install_path, entry.name });
            const plugin_ptr = try alloc.create(Plugin);
            errdefer alloc.destroy(plugin_ptr);

            plugin_ptr.* = try Plugin.init(alloc, @ptrCast(path), entry.name);
            errdefer plugin_ptr.deinit();

            return try plugin_ptr.getKey(alloc);
        }

        pub fn parseCommands(io: Io, alloc: Allocator, home: []const u8) ![]const KC {
            const install_path = try installPath(alloc, home);
            var dir = try Io.Dir.openDirAbsolute(io, install_path, .{ .iterate = true });
            defer dir.close(io);

            var key_commands = try std.ArrayList(KC).initCapacity(alloc, 5);
            defer key_commands.deinit(alloc);

            var iter = dir.iterate();
            while (try iter.next(io)) |entry| {
                // TODO: fix when file is empty others get corrupted
                const kc = getCommand(alloc, install_path, entry) catch continue;
                try key_commands.append(alloc, kc);
            }

            if (key_commands.items.len == 0) {
                std.log.warn("No plugins loaded from {s}", .{install_path});
                return error.NoPlugins;
            }

            std.log.info("Successfully loaded {} plugin(s)", .{key_commands.items.len});
            return try key_commands.toOwnedSlice(alloc);
        }
    };
}
