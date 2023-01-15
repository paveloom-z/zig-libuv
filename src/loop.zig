const std = @import("std");

const uv = @import("lib.zig");

const Cast = uv.Cast;
const Handle = uv.Handle;
const c = uv.c;
const check = uv.check;

/// An event loop
pub const Loop = extern struct {
    pub const RunMode = c.uv_run_mode;
    const Self = @This();
    pub const UV = c.uv_loop_t;
    pub const WalkCallback = ?fn (*Handle, ?*anyopaque) callconv(.C) void;
    pub const WalkCallbackUV = c.uv_walk_cb;
    data: ?*anyopaque,
    active_handles: c_uint,
    handle_queue: [2]?*anyopaque,
    active_reqs: extern union {
        unused: ?*anyopaque,
        count: c_uint,
    },
    internal_fields: ?*anyopaque,
    stop_flag: c_uint,
    flags: c_ulong,
    backend_fd: c_int,
    pending_queue: [2]?*anyopaque,
    watcher_queue: [2]?*anyopaque,
    watchers: [*c][*c]c.uv__io_t,
    nwatchers: c_uint,
    nfds: c_uint,
    wq: [2]?*anyopaque,
    wq_mutex: c.uv_mutex_t,
    wq_async: c.uv_async_t,
    cloexec_lock: c.uv_rwlock_t,
    closing_handles: [*c]c.uv_handle_t,
    process_handles: [2]?*anyopaque,
    prepare_handles: [2]?*anyopaque,
    check_handles: [2]?*anyopaque,
    idle_handles: [2]?*anyopaque,
    async_handles: [2]?*anyopaque,
    async_unused: ?*const fn () callconv(.C) void,
    async_io_watcher: c.uv__io_t,
    async_wfd: c_int,
    timer_heap: extern struct {
        min: ?*anyopaque,
        nelts: c_uint,
    },
    timer_counter: u64,
    time: u64,
    signal_pipefd: [2]c_int,
    signal_io_watcher: c.uv__io_t,
    child_watcher: c.uv_signal_t,
    emfile_fd: c_int,
    inotify_read_watcher: c.uv__io_t,
    inotify_watchers: ?*anyopaque,
    inotify_fd: c_int,
    usingnamespace Cast(Self);
    /// Initialize the loop
    pub fn init(loop: *Self) !void {
        const res = c.uv_loop_init(loop.toUV());
        try check(res);
    }
    /// Return the initialized default loop
    pub fn default() ?*Self {
        return Self.fromUV(c.uv_default_loop());
    }
    /// Run the loop
    pub fn run(self: *Self, run_mode: RunMode) !void {
        const res = c.uv_run(self.toUV(), run_mode);
        try check(res);
    }
    /// Check if the loop is alive
    pub fn isAlive(self: *Self) bool {
        return c.uv_loop_alive(self.toUV()) != 0;
    }
    /// Stop the loop
    pub fn stop(self: *Self) void {
        c.uv_stop(self.toUV());
    }
    /// Walk the list of handles
    pub fn walk(self: *Self, walk_cb: WalkCallback, arg: ?*anyopaque) void {
        c.uv_walk(
            self.toUV(),
            @ptrCast(WalkCallbackUV, walk_cb),
            arg,
        );
    }
    /// Close the loop
    pub fn close(self: *Self) !void {
        const res = c.uv_loop_close(self.toUV());
        try check(res);
    }
};

/// Mode used to run the loop with
pub usingnamespace struct {
    pub const RUN_DEFAULT = c.UV_RUN_DEFAULT;
    pub const RUN_NOWAIT = c.UV_RUN_NOWAIT;
    pub const RUN_ONCE = c.UV_RUN_ONCE;
};

test "Loop" {
    const alloc = std.testing.allocator;
    // Initialize the loop
    var loop = try alloc.create(Loop);
    try Loop.init(loop);
    defer alloc.destroy(loop);
    // Check whether the loop is alive
    try std.testing.expect(!loop.isAlive());
    // Run the loop
    try loop.run(uv.RUN_DEFAULT);
    // Check whether the loop is alive
    try std.testing.expect(!loop.isAlive());
    // Close the loop
    try loop.close();
}

test "Loop (default)" {
    // Assert we can get the default loop
    var loop = Loop.default().?;
    // Check whether the loop is alive
    try std.testing.expect(!loop.isAlive());
    // Run the loop
    try loop.run(uv.RUN_DEFAULT);
    // Check whether the loop is alive
    try std.testing.expect(!loop.isAlive());
    // Close the loop
    try loop.close();
}
