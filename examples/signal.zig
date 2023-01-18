const std = @import("std");

const uv = @import("libuv");

const alloc = std.heap.c_allocator;

const stdout = std.io.getStdOut().writer();

/// Create a new event loop
fn createLoop() !*uv.Loop {
    var loop = try alloc.create(uv.Loop);
    try uv.Loop.init(loop);
    return loop;
}

/// A callback to call for each handle
fn onWalk(maybe_handle: ?*uv.Handle, arg: ?*anyopaque) callconv(.C) void {
    _ = arg;
    // If the handle is still there
    if (maybe_handle) |handle| {
        // If the handle isn't being closed already
        if (!handle.isClosing()) {
            // Request to close the handle
            handle.close(null);
        }
    }
}

/// A callback for the `SIGINT` signal
fn onInterrupt(handle: *uv.Signal, signum: c_int) callconv(.C) void {
    _ = signum;
    stdout.print("\r", .{}) catch {};
    // Try to close the loop
    handle.loop.close() catch |err| {
        if (err == uv.Error.UV_EBUSY) {
            // Request to close each handle
            handle.loop.walk(onWalk, null);
        }
    };
}

/// A callback for the `SIGUSR1` signal
fn onUserSignal(handle: *uv.Signal, signum: c_int) callconv(.C) void {
    stdout.print("Signal received: {}\n", .{signum}) catch {};
    handle.close(null);
}

/// A callback for the first worker
fn thread1Worker(data: ?*anyopaque) callconv(.C) void {
    _ = data;
    // Create a loop
    var loop = createLoop() catch unreachable;
    defer alloc.destroy(loop);
    // Prepare a handler for the interrupt signal
    var sigint: uv.Signal = undefined;
    sigint.init(loop) catch {};
    sigint.start(onInterrupt, uv.SIGINT) catch {};
    // Start two signal handlers in one loop
    var sig1a: uv.Signal = undefined;
    var sig1b: uv.Signal = undefined;
    sig1a.init(loop) catch {};
    sig1a.start(onUserSignal, uv.SIGUSR1) catch {};
    sig1b.init(loop) catch {};
    sig1b.start(onUserSignal, uv.SIGUSR1) catch {};
    // Run the loop
    loop.run(uv.RUN_DEFAULT) catch {};
    // Close the loop
    loop.close() catch {};
}

/// A callback for the second worker
fn thread2Worker(data: ?*anyopaque) callconv(.C) void {
    _ = data;
    // Create two loops
    var loop_1 = createLoop() catch unreachable;
    var loop_2 = createLoop() catch unreachable;
    defer alloc.destroy(loop_1);
    defer alloc.destroy(loop_2);
    // Prepare handlers for the interrupt signal
    var siginta: uv.Signal = undefined;
    var sigintb: uv.Signal = undefined;
    siginta.init(loop_1) catch {};
    siginta.start(onInterrupt, uv.SIGINT) catch {};
    sigintb.init(loop_2) catch {};
    sigintb.start(onInterrupt, uv.SIGINT) catch {};
    // Start two signal handlers in each loop
    var sig1a: uv.Signal = undefined;
    var sig1b: uv.Signal = undefined;
    sig1a.init(loop_1) catch {};
    sig1a.start(onUserSignal, uv.SIGUSR1) catch {};
    sig1b.init(loop_2) catch {};
    sig1b.start(onUserSignal, uv.SIGUSR1) catch {};
    // Run the loops
    while (true) {
        loop_1.run(uv.RUN_NOWAIT) catch {};
        loop_2.run(uv.RUN_NOWAIT) catch {};
        if (!loop_1.isAlive() and !loop_2.isAlive()) break;
    }
    // Close the loops
    loop_1.close() catch {};
    loop_2.close() catch {};
}

/// Run the program
pub fn main() !void {
    // Print the ID of the process
    try stdout.print("PID {}\n", .{std.os.linux.getpid()});
    // Spawn a couple of workers
    var thread1: uv.Thread = undefined;
    var thread2: uv.Thread = undefined;
    try thread1.create(thread1Worker, null);
    try thread2.create(thread2Worker, null);
    // Wait for them to finish
    try thread1.join();
    try thread2.join();
}
