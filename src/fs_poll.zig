const std = @import("std");

const uv = @import("lib.zig");

const Cast = uv.Cast;
const Fs = uv.Fs;
const Handle = uv.Handle;
const HandleDecls = uv.HandleDecls;
const Loop = uv.Loop;
const c = uv.c;
const check = uv.check;

/// FS Poll handle
pub const FsPoll = extern struct {
    const Self = @This();
    pub const UV = c.uv_fs_poll_t;
    /// Callback passed to `start` which will be called
    /// repeatedly after the handle is started, when any change
    /// happens to the monitored path
    pub const FsPollCallback = ?*const fn (
        *Self,
        c_int,
        *const Fs.Stat,
        *const Fs.Stat,
    ) callconv(.C) void;
    pub const FsPollCallbackUV = c.uv_fs_poll_cb;
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
    poll_ctx: ?*anyopaque,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    /// Initialize the handle
    pub fn init(self: *Self, loop: *Loop) !void {
        const res = c.uv_fs_poll_init(loop.toUV(), self.toUV());
        try check(res);
    }
    /// Check the file at path for changes every interval milliseconds
    pub fn start(
        self: *Self,
        poll_cb: FsPollCallback,
        path: [*c]const u8,
        interval: c_uint,
    ) !void {
        const res = c.uv_fs_poll_start(
            self,
            @ptrCast(FsPollCallback, poll_cb),
            path,
            interval,
        );
        try check(res);
    }
    /// Stop the handle, the callback will no longer be called
    pub fn stop(self: *Self) !void {
        const res = c.uv_fs_poll_stop(self.toUV());
        try check(res);
    }
    /// Get the path being monitored by the handle
    pub fn getPath(self: *Self, buffer: [*]u8, size: *usize) !void {
        const res = c.uv_fs_poll_getpath(self.toUV(), buffer, size);
        try check(res);
    }
};
