const std = @import("std");

const uv = @import("libuv");

const alloc = std.heap.c_allocator;
var loop: *uv.Loop = undefined;

var counter: usize = 0;

const stdout = std.io.getStdOut().writer();

/// A callback to call for each handle
fn onWalk(handle: *uv.Handle, arg: ?*anyopaque) callconv(.C) void {
    _ = arg;
    // If the handle isn't being closed already
    if (!handle.isClosing()) {
        // Request to close the handle
        handle.close(null);
    }
}

/// A callback for the idle handle
fn idleCb(handle: *uv.Idle) callconv(.C) void {
    _ = handle;
    stdout.print("Idle callback\n", .{}) catch {};
    counter += 1;
    if (counter >= 5) {
        // Request to close each handle
        loop.walk(onWalk, null);
        stdout.print("Closing...\n", .{}) catch {};
    }
}

/// A callback for the prepare handle
fn prepCb(handle: *uv.Prepare) callconv(.C) void {
    _ = handle;
    stdout.print("Prep callback\n", .{}) catch {};
}

/// Run the program
pub fn main() !void {
    // Initialize the loop
    loop = try alloc.create(uv.Loop);
    defer alloc.destroy(loop);
    try uv.Loop.init(loop);
    // Request a couple of functions to
    // be run before each loop iteration
    var idler: uv.Idle = undefined;
    var prep: uv.Prepare = undefined;
    idler.init(loop);
    prep.init(loop);
    try idler.start(idleCb);
    try prep.start(prepCb);
    // Run the loop
    try loop.run(uv.RUN_DEFAULT);
    // Close the loop
    try loop.close();
}
