const std = @import("std");
const Allocator = std.mem.Allocator;

const zigkeys = @import("zigkeys");
const Key = zigkeys.Key;
const Modifier = zigkeys.Modifier;
const KeyCommand = zigkeys.KeyCommand;

const zlua = @import("zlua");
const Lua = zlua.Lua;

pub fn runLuaMain(lua: *Lua) !void {
    const lua_type = lua.getGlobal("main") catch |err| {
        std.log.err("Failed to get 'main': {}", .{err});
        return err;
    };

    if (lua_type != .function) {
        std.log.err("'main' is not a function, it's a {}", .{lua_type});
        return error.NotAFunction;
    }

    // Call the function: 0 args, 0 results, 0 error handler
    lua.protectedCall(.{ .args = 0, .results = 0 }) catch |err| {
        const err_msg = lua.toString(-1) catch "unknown error";
        std.log.err("Lua error: {s}", .{err_msg});
        return err;
    };
}

fn parseModifier(s: []const u8) !Modifier {
    if (std.mem.eql(u8, s, "control")) return .control;
    if (std.mem.eql(u8, s, "shift")) return .shift;
    if (std.mem.eql(u8, s, "command")) return .command;
    if (std.mem.eql(u8, s, "option")) return .option;
    return error.InvalidModifier;
}

pub const Plugin = struct {
    lua: *Lua,
    path: [:0]const u8,
    name: []const u8,

    const T = *Plugin;

    pub fn init(alloc: Allocator, path: [:0]const u8, name: []const u8) !Plugin {
        const lua = try Lua.init(alloc);
        lua.openLibs();

        std.log.info("Loading Lua file: {s}", .{path});
        lua.doFile(path) catch |err| {
            const err_msg = lua.toString(-1) catch "unknown error";
            std.log.err("Lua error in {s}: {s}", .{ path, err_msg });
            lua.pop(1);
            return err;
        };

        return .{
            .lua = lua,
            .path = path,
            .name = name,
        };
    }

    pub fn getKey(self: *Plugin, alloc: Allocator) !KeyCommand(T) {
        const lua_type = self.lua.getGlobal("key") catch |err| {
            std.log.err("Failed to get 'key': {}", .{err});
            return err;
        };

        if (lua_type != .table) {
            std.log.err("'key' is not a table, it's a {}", .{lua_type});
            return error.NotATable;
        }
        defer self.lua.pop(1);

        _ = self.lua.getField(-1, "keycode");
        if (self.lua.typeOf(-1) != .number) {
            return error.InvalidKeycode;
        }
        const keycode: u8 = @intCast(try self.lua.toInteger(-1));
        self.lua.pop(1);

        _ = self.lua.getField(-1, "modifiers");
        var modifiers = try std.ArrayList(Modifier).initCapacity(alloc, 2);
        defer modifiers.deinit(alloc);

        if (self.lua.typeOf(-1) == .table) {
            var i: i32 = 1;
            while (true) : (i += 1) {
                _ = self.lua.rawGetIndex(-1, i);
                if (self.lua.typeOf(-1) == .nil) {
                    self.lua.pop(1);
                    break;
                }

                const mod_str = try self.lua.toString(-1);
                const modifier = try parseModifier(mod_str);
                try modifiers.append(alloc, modifier);
                self.lua.pop(1);
            }
        }
        self.lua.pop(1);

        const key = Key.init(keycode, try modifiers.toOwnedSlice(alloc), true);
        return KeyCommand(T).init(key, self, false, self.name);
    }

    pub fn deinit(self: *Plugin) void {
        self.lua.deinit();
    }

    pub fn execute(self: *Plugin) !void {
        try runLuaMain(self.lua);
    }
};
