const std = @import("std");

const lib = @import("lib.zig");

const Cast = lib.Cast;
const HandleDecls = lib.HandleDecls;
const Loop = lib.Loop;
const c = lib.c;
const check = lib.check;

/// Timer handle
pub const Timer = struct {
    const Self = @This();
    pub const UV = c.uv_timer_t;
    pub const TimerCallback = c.uv_timer_cb;
    data: ?*anyopaque,
    loop: [*c]c.uv_loop_t,
    type: c.uv_handle_type,
    close_cb: c.uv_close_cb,
    handle_queue: [2]?*anyopaque,
    u: extern union {
        fd: c_int,
        reserved: [4]?*anyopaque,
    },
    next_closing: [*c]c.uv_handle_t,
    flags: c_uint,
    timer_cb: c.uv_timer_cb,
    heap_node: [3]?*anyopaque,
    timeout: u64,
    repeat: u64,
    start_id: u64,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    /// Initialize the handle
    pub fn init(loop: *Loop) !Self {
        // Prepare a pointer for the handle
        var self: Self = undefined;
        // Initialize the handle
        const res = c.uv_timer_init(loop.toUV(), self.toUV());
        try check(res);
        // Return the handle
        return self;
    }
    /// Start the timer
    ///
    /// `timeout` and `repeat` are in milliseconds.
    pub fn start(self: *Self, cb: TimerCallback, timeout: u64, repeat: u64) !void {
        const res = c.uv_timer_start(self.toUV(), cb, timeout, repeat);
        try check(res);
    }
    /// Stop the timer
    pub fn stop(self: *Self) !void {
        const res = c.uv_timer_stop(self.toUV());
        try check(res);
    }
    /// Restart the timer
    pub fn again(self: *Self) !void {
        const res = c.uv_timer_again(self.toUV());
        try check(res);
    }
    /// Set the repeat interval value in milliseconds
    pub fn set_repeat(self: *Self, repeat: u64) void {
        c.uv_timer_set_repeat(self.toUV(), repeat);
    }
    /// Get the timer repeat value
    pub fn get_repeat(self: *Self) u64 {
        return c.uv_timer_get_repeat(self.toUV());
    }
    /// Get the timer due value or 0 if it has expired
    ///
    /// The time is relative to `Loop.now`.
    pub fn get_due_in(self: *Self) u64 {
        return c.uv_timer_get_due_in(self.toUV());
    }
};

/// A callback for the test
fn testCallback(handle: ?*Timer.UV) callconv(.C) void {
    _ = handle;
}

test "Timer" {
    const alloc = std.testing.allocator;
    // Initialize the loop
    var loop = try alloc.create(Loop);
    try Loop.init(loop);
    defer alloc.destroy(loop);
    // Initialize a timer
    var timer = try Timer.init(loop);
    // Start the timer
    try timer.start(testCallback, 0, 0);
    // Run the loop
    try loop.run(Loop.RunMode.DEFAULT);
    // Request to stop the timer
    timer.close(null);
    // Check whether the loop is alive
    try std.testing.expect(loop.isAlive());
    // Run the loop again to accomplish that request
    try loop.run(Loop.RunMode.DEFAULT);
    // Check whether the loop is alive
    try std.testing.expect(!loop.isAlive());
    // Close the loop
    try loop.close();
}
