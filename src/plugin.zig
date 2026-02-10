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

fn readField(comptime T: type, lua: *Lua, field_name: [:0]const u8) !T {
    _ = lua.getField(-1, field_name);
    defer lua.pop(1);
    const info = @typeInfo(T);
    const val: T = blk: switch (info) {
        .bool => {
            if (lua.typeOf(-1) != .boolean) {
                return error.InvalidKeycode;
            }
            break :blk lua.toBoolean(-1);
        },
        .int => {
            if (lua.typeOf(-1) != .number) {
                return error.InvalidKeycode;
            }
            break :blk @intCast(try lua.toInteger(-1));
        },
        .float => {
            if (lua.typeOf(-1) != .number) {
                return error.InvalidKeycode;
            }
            break :blk @floatCast(try lua.toNumber(-1));
        },
        else => @compileLog("unsupported field type"),
    };

    return val;
}

fn parseModifier(s: []const u8) !Modifier {
    if (std.mem.eql(u8, s, "control")) return .{ .control = .either };
    if (std.mem.eql(u8, s, "shift")) return .{ .shift = .either };
    if (std.mem.eql(u8, s, "command")) return .{ .command = .either };
    if (std.mem.eql(u8, s, "option")) return .{ .option = .either };
    if (std.mem.eql(u8, s, "fn")) return .{ .fn_key = {} };
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

        const keycode = try readField(u8, self.lua, "keycode");
        const retrigger = readField(bool, self.lua, "retrigger") catch false;
        const trigger_per_ms = readField(u64, self.lua, "trigger_per_ms") catch null;
        const down = readField(bool, self.lua, "down") catch true;

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

        const key = Key.init(keycode, try modifiers.toOwnedSlice(alloc), down);
        var kc = KeyCommand(T).init(key, self, retrigger, self.name);
        if (trigger_per_ms) |tps| {
            kc.trigger_per_ms = tps;
        }
        return kc;
    }

    pub fn deinit(self: *Plugin) void {
        self.lua.deinit();
    }

    pub fn execute(self: *Plugin) !void {
        try runLuaMain(self.lua);
    }
};
