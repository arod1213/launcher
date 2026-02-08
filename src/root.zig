const std = @import("std");
const Allocator = std.mem.Allocator;
const zigkeys = @import("zigkeys");

const Key = zigkeys.Key;
const Modifier = zigkeys.Modifier;

pub const Msg = enum { daw, browser, terminal, settings, music, interface };
const KC = zigkeys.KeyCommand(Msg);

fn openApp(alloc: Allocator, app_name: []const u8) !void {
    const args = [_][]const u8{
        "open",
        "-a",
        app_name,
    };
    var child = std.process.Child.init(&args, alloc);
    try child.spawn();
    _ = try child.wait();
}

pub fn handle(alloc: Allocator, k: KC) !void {
    const name = switch (k.cmd) {
        .browser => "Brave Browser",
        .daw => "Ableton Live 12 Suite",
        .terminal => "Kitty",
        .settings => "System Settings",
        .music => "Spotify",
        .interface => "NControl",
    };
    try openApp(alloc, name);
}

pub fn run(alloc: Allocator) !void {
    const cmds = [_]KC{
        KC.init(
            Key.init(11, &[_]Modifier{.control}, true),
            .browser,
            false,
            "open browser",
        ),
        KC.init(
            Key.init(2, &[_]Modifier{ .control, .option }, true),
            .daw,
            false,
            "open daw",
        ),
        KC.init(
            Key.init(36, &[_]Modifier{.control}, true),
            .terminal,
            false,
            "open terminal",
        ),
        KC.init(
            Key.init(1, &[_]Modifier{ .control, .option }, true),
            .settings,
            false,
            "open settings",
        ),
        KC.init(
            Key.init(1, &[_]Modifier{.control}, true),
            .music,
            false,
            "open spotify",
        ),
        KC.init(
            Key.init(45, &[_]Modifier{.control}, true),
            .interface,
            false,
            "open audio interface",
        ),
    };
    var settings = zigkeys.Config(Msg).init(&cmds);
    // settings.should_log = true;
    try zigkeys.run(alloc, Msg, &settings, alloc, handle);
}
