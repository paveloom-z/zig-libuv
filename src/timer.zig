const std = @import("std");

const c = @import("c.zig").c;

const Loop = @import("loop.zig").Loop;
const check = @import("error.zig").check;

/// Timer handle
pub const Timer = struct {
    const Self = @This();
    pub const UVHandle = c.uv_timer_t;
    pub const Handle = @import("handle.zig").Handle(UVHandle);
    pub const Callback = c.uv_timer_cb;
    /// A wrapped `libuv`'s timer handle
    handle: Handle,
    /// Initialize the handle
    pub fn init(loop: *Loop) !Self {
        // Prepare a pointer for the handle
        var uv_timer: c.uv_timer_t = undefined;
        // Initialize the handle
        const res = c.uv_timer_init(loop.uv_loop, &uv_timer);
        try check(res);
        // Return the handle
        return Self{
            .handle = Handle{
                .uv_handle = uv_timer,
            },
        };
    }
    /// Start the timer
    ///
    /// `timeout` and `repeat` are in milliseconds.
    pub fn start(self: *Self, cb: Callback, timeout: u64, repeat: u64) !void {
        const res = c.uv_timer_start(&self.handle.uv_handle, cb, timeout, repeat);
        try check(res);
    }
    /// Stop the timer
    pub fn stop(self: *Self) !void {
        const res = c.uv_timer_stop(&self.handle.uv_handle);
        try check(res);
    }
    /// Restart the timer
    pub fn again(self: *Self) !void {
        const res = c.uv_timer_again(&self.handle.uv_handle);
        try check(res);
    }
    /// Set the repeat interval value in milliseconds
    pub fn set_repeat(self: *Self, repeat: u64) void {
        c.uv_timer_set_repeat(&self.handle.uv_handle, repeat);
    }
    /// Get the timer repeat value
    pub fn get_repeat(self: *Self) u64 {
        return c.uv_timer_get_repeat(&self.handle.uv_handle);
    }
    /// Get the timer due value or 0 if it has expired
    ///
    /// The time is relative to `Loop.now`.
    pub fn get_due_in(self: *Self) u64 {
        return c.uv_timer_get_due_in(&self.handle.uv_handle);
    }
};

/// A callback for the test
fn testCallback(handle: ?*c.uv_timer_t) callconv(.C) void {
    _ = handle;
}

test "Timer" {
    // Initialize the loop
    var loop = try Loop.init(std.testing.allocator);
    defer loop.deinit();
    // Initialize a timer
    var timer = try Timer.init(&loop);
    // Start the timer
    try timer.start(testCallback, 0, 0);
    // Run the loop
    try loop.run(Loop.RunMode.DEFAULT);
    // Request to stop the timer
    timer.handle.close(null);
    // Check whether the loop is alive
    try std.testing.expect(loop.isAlive());
    // Run the loop again to accomplish that request
    try loop.run(Loop.RunMode.DEFAULT);
    // Check whether the loop is alive
    try std.testing.expect(!loop.isAlive());
    // Close the loop
    try loop.close();
}
