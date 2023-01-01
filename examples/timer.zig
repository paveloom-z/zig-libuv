const std = @import("std");

const libuv = @import("libuv");

/// A callback for the timer
fn timerCallback(maybe_uv_handle: ?*libuv.Timer.UV) callconv(.C) void {
    // Wrap the handle
    const maybe_handle = libuv.Timer.fromUV(maybe_uv_handle);
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
    // Initialize the loop
    var loop = try libuv.Loop.init(std.heap.page_allocator);
    defer loop.deinit();
    // Initialize a timer
    var timer = try libuv.Timer.init(&loop);
    // We use the double `baton` approach here to store user
    // data just for these sweet methods in the callback
    var count: usize = 0;
    timer.data = &count;
    // Count to 10, then say goodbye
    try timer.start(timerCallback, 0, 250);
    // Run the loop
    try loop.run(libuv.Loop.RunMode.DEFAULT);
    // Close the loop
    try loop.close();
}
