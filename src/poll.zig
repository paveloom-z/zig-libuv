const std = @import("std");

const uv = @import("lib.zig");

const Cast = uv.Cast;
const Handle = uv.Handle;
const HandleDecls = uv.HandleDecls;
const Loop = uv.Loop;
const OsSock = uv.OsSock;
const c = uv.c;
const check = uv.check;

/// Poll event types
pub usingnamespace struct {
    pub const DISCONNECT = c.UV_DISCONNECT;
    pub const PRIORITIZED = c.UV_PRIORITIZED;
    pub const READABLE = c.UV_READABLE;
    pub const WRITABLE = c.UV_WRITABLE;
};

/// Poll handle
pub const Poll = extern struct {
    const Self = @This();
    pub const UV = c.uv_poll_t;
    /// Type definition for callback passed to `start`
    pub const PollCallback = ?fn (*Self, c_int, c_int) callconv(.C) void;
    pub const PollCallbackUV = c.uv_poll_cb;
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
    poll_cb: PollCallbackUV,
    io_watcher: c.uv__io_t,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    /// Initialize the handle using a file descriptor
    pub fn init(self: *Self, loop: *Loop, fd: c_int) !void {
        const res = c.uv_poll_init(loop.toUV(), self.toUV(), fd);
        try check(res);
    }
    /// Initialize the handle using a socket descriptor
    pub fn initSocket(self: *Self, loop: *Loop, socket: OsSock) !void {
        const res = c.uv_poll_init_socket(loop.toUV(), self.toUV(), socket);
        try check(res);
    }
    /// Start polling the file descriptor
    pub fn start(self: *Self, events: c_int, cb: PollCallback) !void {
        const res = c.uv_poll_start(
            self.toUV(),
            @ptrCast(PollCallbackUV, events),
            cb,
        );
        try check(res);
    }
    /// Stop polling the file descriptor
    pub fn stop(self: *Self) !void {
        const res = c.uv_poll_stop(self.toUV());
        try check(res);
    }
};
