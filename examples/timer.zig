const std = @import("std");

const uv = @import("libuv");

/// A callback for the timer
fn timerCallback(maybe_handle: ?*uv.Timer) callconv(.C) void {
    // Assert we actually got a handle
    const handle = maybe_handle.?;
    // Assert this handle has the data
    const data = handle.data.?;
    // Cast the pointer
    const count = @ptrCast(*align(1) usize, data);
    // Do the logic
    count.* += 1;
    std.debug.print("{}!\n", .{count.*});
    if (count.* == 10) {
        std.debug.print("Goodbye!\n", .{});
        handle.close(null);
    }
}

/// Run the program
pub fn main() !void {
    const alloc = std.heap.c_allocator;
    // Initialize the loop
    var loop = try alloc.create(uv.Loop);
    defer alloc.destroy(loop);
    try uv.Loop.init(loop);
    // Initialize a timer
    var timer: uv.Timer = undefined;
    try timer.init(loop);
    // We use the double `baton` approach here to store user
    // data just for these sweet methods in the callback
    var count: usize = 0;
    timer.data = &count;
    // Count to 10, then say goodbye
    try timer.start(timerCallback, 0, 250);
    // Run the loop
    try loop.run(uv.RUN_DEFAULT);
    // Close the loop
    try loop.close();
}
