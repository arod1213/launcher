const std = @import("std");
const Allocator = std.mem.Allocator;
const zigkeys = @import("zigkeys");

const Plugin = @import("./plugin.zig").Plugin;

const Key = zigkeys.Key;
const Modifier = zigkeys.Modifier;
const KeyCommand = zigkeys.KeyCommand;

fn installPath(alloc: Allocator) ![]const u8 {
    const home = std.posix.getenv("HOME") orelse return error.NoHomeDir;
    return try std.fmt.allocPrint(alloc, "{s}/documents/launcher/plugins", .{home});
}

// TODO: this is not type agnostic
// Plugin is defined inside
pub fn commandLoader(comptime T: type) type {
    return struct {
        const KC = KeyCommand(T);

        fn getCommand(alloc: Allocator, install_path: []const u8, entry: std.fs.Dir.Entry) !KC {
            if (entry.kind != .file) return error.InvalidType;
            if (!std.mem.endsWith(u8, entry.name, ".lua")) return error.InvalidExtension;

            const path = try std.fs.path.join(alloc, &[_][]const u8{ install_path, entry.name });
            const plugin_ptr = try alloc.create(Plugin);
            errdefer alloc.destroy(plugin_ptr);

            plugin_ptr.* = try Plugin.init(alloc, @ptrCast(path), entry.name);
            errdefer plugin_ptr.deinit();

            return try plugin_ptr.getKey(alloc);
        }

        pub fn parseCommands(alloc: Allocator) ![]const KC {
            const install_path = try installPath(alloc);
            var dir = try std.fs.openDirAbsolute(install_path, .{ .iterate = true });
            defer dir.close();

            var key_commands = try std.ArrayList(KC).initCapacity(alloc, 5);
            defer key_commands.deinit(alloc);

            var iter = dir.iterate();
            while (try iter.next()) |entry| {
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
