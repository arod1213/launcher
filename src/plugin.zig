const std = @import("std");
const Allocator = std.mem.Allocator;
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

pub const Plugin = struct {
    lua: *Lua,
    path: [:0]const u8,

    pub fn init(alloc: Allocator, path: [:0]const u8) !Plugin {
        const lua = try Lua.init(alloc);
        try lua.doFile(path);
        return .{
            .lua = lua,
            .path = path,
        };
    }

    pub fn deinit(self: *Plugin) void {
        self.lua.deinit();
    }

    pub fn execute(self: *Plugin) !void {
        try runLuaMain(self.lua);
    }
};
