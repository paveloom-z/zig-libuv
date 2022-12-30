const std = @import("std");

const c = @import("c.zig").c;

const check = @import("error.zig").check;

/// An event loop
pub const Loop = struct {
    const Self = @This();
    /// Mode used to run the loop with
    pub const RunMode = enum(c_uint) {
        DEFAULT = c.UV_RUN_DEFAULT,
        ONCE = c.UV_RUN_ONCE,
        NOWAIT = c.UV_RUN_NOWAIT,
    };
    /// A wrapped `libuv`'s event loop
    uv_loop: *c.uv_loop_t,
    /// An allocator
    allocator: std.mem.Allocator,
    /// Initialize the loop
    pub fn init(allocator: std.mem.Allocator) !Self {
        // Allocate the memory for the loop
        var uv_loop = try allocator.create(c.uv_loop_t);
        // Initialize the loop
        const res = c.uv_loop_init(uv_loop);
        try check(res);
        // Return the loop
        return Self{
            .uv_loop = uv_loop,
            .allocator = allocator,
        };
    }
    /// Close the loop
    pub fn close(self: *Self) !void {
        const res = c.uv_loop_close(self.uv_loop);
        try check(res);
    }
    /// Run the loop
    pub fn run(self: *Self, run_mode: RunMode) !void {
        const res = c.uv_run(self.uv_loop, @enumToInt(run_mode));
        try check(res);
    }
    /// Check if the loop is alive
    pub fn isAlive(self: *Self) bool {
        return c.uv_loop_alive(self.uv_loop) != 0;
    }
    /// Stop the loop
    pub fn stop(self: *Self) void {
        c.uv_stop(self.uv_loop);
    }
    /// Free the memory allocated to the loop
    pub fn deinit(self: *Self) void {
        // Free the memory
        self.allocator.destroy(self.uv_loop);
        self.* = undefined;
    }
};

// Test an empty loop for memory leaks
test "Loop" {
    // Initialize the loop
    var loop = try Loop.init(std.testing.allocator);
    defer loop.deinit();
    // Check whether the loop is alive
    try std.testing.expect(!loop.isAlive());
    // Run the loop
    try loop.run(Loop.RunMode.DEFAULT);
    // Check whether the loop is alive
    try std.testing.expect(!loop.isAlive());
    // Close the loop
    try loop.close();
}
