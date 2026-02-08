const std = @import("std");
const launcher = @import("launcher");
const Lua = launcher.Lua;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const lua = try Lua.init(alloc);
    defer lua.deinit();

    // try launcher.run(alloc);

    lua.openLibs();

    // Load and execute the file (runs top-level code)
    lua.doFile("test.lua") catch |err| {
        std.log.err("Failed to load file: {}", .{err});
        return err;
    };

    try launcher.parse.runLuaMain(lua, "test.lua");

    // Get the global 'main' function
    // const lua_type = lua.getGlobal("main") catch |err| {
    //     std.log.err("Failed to get 'main': {}", .{err});
    //     return err;
    // };
    //
    // // Check it's actually a function
    // if (lua_type != .function) {
    //     std.log.err("'main' is not a function, it's a {}", .{lua_type});
    //     return error.NotAFunction;
    // }
    //
    // // Call the function: 0 args, 0 results, 0 error handler
    // lua.protectedCall(.{ .args = 0, .results = 0 }) catch |err| {
    //     // Get error message from stack
    //     const err_msg = lua.toString(-1) catch "unknown error";
    //     std.log.err("Lua error: {s}", .{err_msg});
    //     return err;
    // };

    std.log.info("Successfully called main()", .{});
}
