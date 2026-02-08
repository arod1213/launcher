const std = @import("std");
const Allocator = std.mem.Allocator;
const zigkeys = @import("zigkeys");

const Key = zigkeys.Key;
const Modifier = zigkeys.Modifier;

pub const Msg = enum { daw, browser, terminal, settings, music, interface };
const KC = zigkeys.KeyCommand(Msg);

const zlua = @import("zlua");
const Lua = zlua.Lua;

pub fn runLuaMain(lua: *Lua, file_name: [:0]const u8) !void {
    try lua.doFile(file_name);

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

pub fn readCommands(alloc: Allocator) ![]KC {
    var buf: [256]u8 = undefined;

    const cwd = std.fs.cwd();
    var file = try cwd.openFile("./config.json", .{ .mode = .read_only });
    const bytes = try file.readAll(&buf);
    var lines = std.mem.splitAny(u8, buf[0..bytes], "\n");

    var list = try std.ArrayList(KC).initCapacity(alloc, 5);
    defer list.deinit(alloc);
    while (lines.next()) |line| {
        std.log.info("reading {s}", .{line});
        const t = std.json.parseFromSlice(KC, alloc, line, .{}) catch |e| {
            std.log.info("failed to parse {any}", .{e});
            continue;
        };
        try list.append(alloc, t.value);
    }
    return try list.toOwnedSlice(alloc);
}
