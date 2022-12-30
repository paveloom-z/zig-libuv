const std = @import("std");

const libuv = @import("libuv");

/// A callback for the timer
fn timerCallback(maybe_handle: ?*libuv.Timer.UVHandle) callconv(.C) void {
    if (maybe_handle) |handle| {
        if (handle.data) |data| {
            const count = @ptrCast(*align(1) usize, data);
            count.* += 1;
            std.debug.print("{}!\n", .{count.*});
            if (count.* == 10) {
                std.debug.print("Goodbye!\n", .{});
                libuv.c.uv_close(libuv.Timer.Handle.toBase(handle), null);
            }
        }
    }
}

/// Run the program
pub fn main() !void {
    // Initialize the loop
    var loop = try libuv.Loop.init(std.heap.page_allocator);
    defer loop.deinit();
    // Initialize a timer
    var timer = try libuv.Timer.init(&loop);
    var count: usize = 0;
    timer.handle.set_data(&count);
    // Count to 10, then say goodbye
    try timer.start(timerCallback, 0, 1000);
    // Run the loop
    try loop.run(libuv.Loop.RunMode.DEFAULT);
    // Close the loop
    try loop.close();
}
