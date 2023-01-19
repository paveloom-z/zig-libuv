const std = @import("std");

const uv = @import("uv");

const alloc = std.heap.c_allocator;
var loop: *uv.Loop = undefined;

const stderr = std.io.getStdErr().writer();
const stdout = std.io.getStdOut().writer();

/// A callback called on change
fn onChange(
    handle: *uv.FsEvent,
    maybe_filename: ?[*:0]const u8,
    events: c_int,
    status: c_int,
) callconv(.C) void {
    _ = status;
    // Get the path
    var path = [_]u8{0} ** 1024;
    var size: usize = 1023;
    handle.getpath(&path, &size) catch |err| {
        stderr.print("Couldn't get the path of the file, got {}.\n", .{err}) catch {};
        return;
    };
    stdout.print("Change detected in {s}: ", .{path}) catch {};
    if (events & uv.RENAME != 0)
        stdout.print("renamed", .{}) catch {};
    if (events & uv.CHANGE != 0)
        stdout.print("changed", .{}) catch {};
    stdout.print(
        " {s}\n",
        .{if (maybe_filename) |filename| filename else ""},
    ) catch {};
}

/// A callback to call when closing the handle
fn onClose(handle: *uv.Handle) callconv(.C) void {
    // Free the memory
    alloc.destroy(handle);
}

/// A callback to call for each handle
fn onWalk(handle: *uv.Handle, arg: ?*anyopaque) callconv(.C) void {
    _ = arg;
    // If the handle isn't being closed already
    if (!handle.isClosing()) {
        // Request to close the handle
        handle.close(onClose);
    }
}

/// Cleanup the loop
fn cleanupLoop(running: bool) callconv(.C) void {
    // Close the loop
    loop.close() catch |err| {
        if (err == uv.Error.UV_EBUSY) {
            // Request to close each handle
            loop.walk(onWalk, null);
            // If the loop wasn't running at the entry,
            // run it now to cleanup everything
            if (!running) {
                loop.run(uv.RUN_DEFAULT) catch {};
                loop.close() catch {};
            }
        }
    };
}

/// A callback in case an interrupt happened
fn onInterrupt(handle: *uv.Signal, signum: c_int) callconv(.C) void {
    _ = signum;
    _ = handle;
    // Note that we execute this function here and
    // after that in the `defer` statement below
    cleanupLoop(true);
}

/// Run the program
pub fn main() !void {
    // Initialize the loop
    loop = try alloc.create(uv.Loop);
    defer {
        cleanupLoop(false);
        alloc.destroy(loop);
    }
    try uv.Loop.init(loop);
    // Prepare an arguments iterator
    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();
    var args_count: usize = 0;
    // For each argument
    while (args.next()) |path| {
        args_count += 1;
        if (args_count > 1) {
            // Put on a recursive watch
            var fs_event_req = try alloc.create(uv.FsEvent);
            try fs_event_req.init(loop);
            fs_event_req.start(onChange, path, uv.FS_EVENT_RECURSIVE) catch {
                stderr.print("No such file or directory: {s}.\n", .{path}) catch {};
                return;
            };
        }
    }
    // If there weren't enough arguments
    if (args_count <= 1) {
        // Print the help message
        try stderr.print(
            \\Please provide files or directories as arguments.
            \\
        ,
            .{},
        );
    } else {
        // Prepare a handler for the interrupt signal
        var sigint = try alloc.create(uv.Signal);
        try sigint.init(loop);
        try sigint.start(onInterrupt, std.os.SIG.INT);
        // Run the loop
        try loop.run(uv.RUN_DEFAULT);
    }
}
