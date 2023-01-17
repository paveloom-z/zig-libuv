const std = @import("std");

const uv = @import("lib.zig");

const Cast = uv.Cast;
const Handle = uv.Handle;
const HandleDecls = uv.HandleDecls;
const Loop = uv.Loop;
const c = uv.c;
const check = uv.check;

/// Async handle
pub const Async = extern struct {
    const Self = @This();
    pub const UV = c.uv_async_t;
    /// Type definition for callback passed to `init`
    pub const AsyncCallback = ?fn (*Self) callconv(.C) void;
    pub const AsyncCallbackUV = c.uv_async_cb;
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
    async_cb: AsyncCallbackUV,
    queue: [2]?*anyopaque,
    pending: c_int,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    /// Initialize the handle
    pub fn init(self: *Self, loop: *Loop, async_cb: AsyncCallback) !void {
        const res = c.uv_async_init(
            loop.toUV(),
            self.toUV(),
            @ptrCast(AsyncCallbackUV, async_cb),
        );
        try check(res);
    }
    /// Wake up the event loop and call the async handle’s callback
    pub fn send(self: *Self) !void {
        const res = c.uv_async_send(self.toUV());
        try check(res);
    }
};
