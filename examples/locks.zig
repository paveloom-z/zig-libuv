const std = @import("std");

const uv = @import("uv");

var blocker: uv.Barrier = undefined;
var numlock: uv.RWLock = undefined;
var shared_num: usize = undefined;

const stdout = std.io.getStdOut().writer();

/// Read from the shared number
fn reader(n: ?*anyopaque) callconv(.C) void {
    const num = @ptrCast(*usize, @alignCast(8, n.?)).*;
    var i: usize = 0;
    while (i < 20) : (i += 1) {
        numlock.rdLock();
        stdout.print("Reader {}: acquired lock\n", .{num}) catch {};
        stdout.print(
            "Reader {}: shared num = {}\n",
            .{ num, shared_num },
        ) catch {};
        numlock.rdUnlock();
        stdout.print("Reader {}: released lock\n", .{num}) catch {};
    }
    _ = blocker.wait() catch {};
}

// Write to the shared number
fn writer(n: ?*anyopaque) callconv(.C) void {
    const num = @ptrCast(*usize, @alignCast(8, n.?)).*;
    var i: usize = 0;
    while (i < 20) : (i += 1) {
        numlock.wrLock();
        stdout.print("Writer {}: acquired lock\n", .{num}) catch {};
        shared_num += 1;
        stdout.print(
            "Writer {}: incremented shared num = {}\n",
            .{ num, shared_num },
        ) catch {};
        numlock.wrUnlock();
        stdout.print("Writer {}: released lock\n", .{num}) catch {};
    }
    _ = blocker.wait() catch {};
}

/// Run the program
pub fn main() !void {
    // Prepare a barrier
    try blocker.init(4);
    // Prepare a shared number and a read-write lock
    shared_num = 0;
    try numlock.init();
    // Create threads
    var threads: [3]uv.Thread = undefined;
    var thread_nums = [_]usize{ 1, 2, 1 };
    try threads[0].create(reader, &thread_nums[0]);
    try threads[1].create(reader, &thread_nums[1]);
    try threads[2].create(writer, &thread_nums[2]);
    // Synchronize the threads one last time
    _ = try blocker.wait();
    for (threads) |*thread| {
        try thread.join();
    }
    // Cleanup
    blocker.destroy();
    numlock.destroy();
}
