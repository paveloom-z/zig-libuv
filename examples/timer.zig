const std = @import("std");

const libuv = @import("libuv");

/// A callback for the timer
fn timerCallback(maybe_handle: ?*libuv.Timer.UVHandle) callconv(.C) void {
    if (maybe_handle) |handle| {
        if (handle.data) |handle_data| {
            const timer = @ptrCast(*align(1) libuv.Timer, handle_data);
            if (timer.data) |timer_data| {
                const count = @ptrCast(*align(1) usize, timer_data);
                count.* += 1;
                std.debug.print("{}!\n", .{count.*});
                if (count.* == 10) {
                    std.debug.print("Goodbye!\n", .{});
                    timer.handle.close(null);
                }
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
    // We use the double `baton` approach here to store user
    // data just for these sweet methods in the callback
    var count: usize = 0;
    timer.data = &count;
    timer.handle.set_data(&timer);
    // Count to 10, then say goodbye
    try timer.start(timerCallback, 0, 250);
    // Run the loop
    try loop.run(libuv.Loop.RunMode.DEFAULT);
    // Close the loop
    try loop.close();
}
