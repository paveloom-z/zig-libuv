const std = @import("std");

const uv = @import("lib.zig");

const Cast = uv.Cast;
const Handle = uv.Handle;
const HandleDecls = uv.HandleDecls;
const Loop = uv.Loop;
const c = uv.c;
const check = uv.check;

/// Check handle
pub const Check = extern struct {
    const Self = @This();
    pub const UV = c.uv_check_t;
    /// Type definition for callback passed to `start`
    pub const CheckCallback = ?fn (*Self) callconv(.C) void;
    pub const CheckCallbackUV = c.uv_check_cb;
    data: ?*anyopaque,
    loop: ?*Loop,
    type: Handle.Type,
    close_cb: Handle.CloseCallbackUV,
    handle_queue: [2]?*anyopaque,
    u: extern union {
        fd: c_int,
        reserved: [4]?*anyopaque,
    },
    next_closing: ?*Handle,
    flags: c_uint,
    check_cb: CheckCallbackUV,
    queue: [2]?*anyopaque,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    /// Initialize the handle
    pub fn init(self: *Self, loop: *Loop) void {
        _ = c.uv_check_init(loop.toUV(), self.toUV());
    }
    /// Start the handle with the given callback
    pub fn start(self: *Self, cb: CheckCallback) !void {
        const res = c.uv_check_start(
            self.toUV(),
            @ptrCast(CheckCallbackUV, cb),
        );
        try check(res);
    }
    /// Stop the handle
    pub fn stop(self: *Self) !void {
        _ = c.uv_check_stop(self.toUV());
    }
};
