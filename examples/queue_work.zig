const std = @import("std");

const uv = @import("libuv");

const alloc = std.heap.c_allocator;
var loop: *uv.Loop = undefined;

const FIB_UNTIL = 25;
var fib_reqs: [FIB_UNTIL]uv.Work = undefined;

const stderr = std.io.getStdErr().writer();
const stdout = std.io.getStdOut().writer();

/// Compute the `i`th Fibonacci number
fn fib(i: usize) usize {
    if (i == 0 or i == 1)
        return 1
    else
        return fib(i - 1) + fib(i - 2);
}

/// Compute a Fibonacci number
fn workFib(req: *uv.Work) callconv(.C) void {
    const i = @ptrCast(*usize, @alignCast(8, req.data)).*;
    if (std.crypto.random.int(usize) % 2 == 0)
        std.time.sleep(1e9)
    else
        std.time.sleep(3e9);
    const number = fib(i);
    stdout.print(
        "Fibonacci #{} is {}\n",
        .{ i, number },
    ) catch {};
}

/// Notify when done computing the Fibonacci number
fn afterWorkFib(req: *uv.Work, status: c_int) callconv(.C) void {
    const i = @ptrCast(*usize, @alignCast(8, req.data)).*;
    uv.check(status) catch |err| {
        if (err == uv.Error.UV_ECANCELED) {
            stderr.print("Computation of #{} cancelled.\n", .{i}) catch {};
            return;
        }
    };
    stdout.print("Done computing #{}\n", .{i}) catch {};
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

/// A callback in case an interrupt happened
fn onInterrupt(handle: *uv.Signal, signum: c_int) callconv(.C) void {
    _ = handle;
    _ = signum;
    // Cancel all requests
    stderr.print("\rCancelling...", .{}) catch {};
    var i: usize = 0;
    while (i < FIB_UNTIL) : (i += 1) {
        fib_reqs[i].cancel() catch {};
    }
    // Try to close the loop
    loop.close() catch |err| {
        if (err == uv.Error.UV_EBUSY) {
            // Request to close each handle
            loop.walk(onWalk, null);
        }
    };
}

/// Run the program
pub fn main() !void {
    // Initialize the loop
    loop = try alloc.create(uv.Loop);
    defer alloc.destroy(loop);
    try uv.Loop.init(loop);
    // Request to compute the Fibonacci numbers
    var data: [FIB_UNTIL]usize = undefined;
    var i: usize = 0;
    while (i < FIB_UNTIL) : (i += 1) {
        data[i] = i;
        fib_reqs[i].data = @ptrCast(*anyopaque, &data[i]);
        try fib_reqs[i].queueWork(loop, workFib, afterWorkFib);
    }
    // Prepare a handler for the interrupt signal
    var sigint = try alloc.create(uv.Signal);
    try sigint.init(loop);
    try sigint.start(onInterrupt, std.os.SIG.INT);
    // Run the loop
    try loop.run(uv.RUN_DEFAULT);
    // Close the loop
    try loop.close();
}
