const std = @import("std");

const lib = @import("lib.zig");

const Cast = lib.Cast;
const Handle = lib.Handle;
const HandleDecls = lib.HandleDecls;
const Loop = lib.Loop;
const c = lib.c;
const check = lib.check;

/// Signal handle
pub const Signal = extern struct {
    const Self = @This();
    pub const UV = c.uv_signal_t;
    pub const SignalCallback = ?fn (*Self, c_int) callconv(.C) void;
    pub const SignalCallbackUV = c.uv_signal_cb;
    data: ?*anyopaque,
    loop: *Loop,
    type: c.uv_handle_type,
    close_cb: c.uv_close_cb,
    handle_queue: [2]?*anyopaque,
    u: extern union {
        fd: c_int,
        reserved: [4]?*anyopaque,
    },
    next_closing: *Handle,
    flags: c_uint,
    signal_cb: c.uv_signal_cb,
    signum: c_int,
    tree_entry: extern struct {
        rbe_left: [*c]c.struct_uv_signal_s,
        rbe_right: [*c]c.struct_uv_signal_s,
        rbe_parent: [*c]c.struct_uv_signal_s,
        rbe_color: c_int,
    },
    caught_signals: c_uint,
    dispatched_signals: c_uint,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    /// Initialize the handle
    pub fn init(self: *Self, loop: *Loop) !void {
        const res = c.uv_signal_init(loop.toUV(), self.toUV());
        try check(res);
    }
    /// Start the handle with the given callback, watching for the given signal
    pub fn start(self: *Self, signal_cb: SignalCallback, signum: c_int) !void {
        const res = c.uv_signal_start(
            self.toUV(),
            @ptrCast(SignalCallbackUV, signal_cb),
            signum,
        );
        try check(res);
    }
    /// Same functionality as `Self.start` but the signal
    /// handler is reset the moment the signal is received
    pub fn startOneshot(self: *Self, signal_cb: SignalCallback, signum: c_int) !void {
        const res = c.uv_signal_start_oneshot(
            self.toUV(),
            @ptrCast(SignalCallbackUV, signal_cb),
            signum,
        );
        try check(res);
    }
    /// Stop the handle, the callback will no longer be called
    pub fn stop(self: *Self) !void {
        const res = c.uv_signal_stop(self.toUV());
        try check(res);
    }
};
