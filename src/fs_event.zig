const std = @import("std");

const uv = @import("lib.zig");

const Cast = uv.Cast;
const Handle = uv.Handle;
const HandleDecls = uv.HandleDecls;
const Loop = uv.Loop;
const c = uv.c;
const check = uv.check;

/// Event handle type
pub const FsEvent = extern struct {
    const Self = @This();
    pub const UV = c.uv_fs_event_t;
    /// Callback passed to `eventStart` which will be
    /// called repeatedly after the handle is started
    pub const FsEventCallback = ?fn (
        *Self,
        [*c]const u8,
        c_int,
        c_int,
    ) callconv(.C) void;
    pub const FsEventCallbackUV = c.uv_fs_event_cb;
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
    path: [*c]u8,
    cb: FsEventCallbackUV,
    watchers: [2]?*anyopaque,
    wd: c_int,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    /// Initialize the handle
    pub fn init(self: *Self, loop: *Loop) !void {
        const res = c.uv_fs_event_init(loop.toUV(), self.toUV());
        try check(res);
    }
    /// Start the handle with the given callback,
    /// which will watch the specified path for changes
    pub fn start(
        self: *Self,
        cb: FsEventCallback,
        path: [*c]const u8,
        flags: c_uint,
    ) !void {
        const res = c.uv_fs_event_start(
            self.toUV(),
            @ptrCast(FsEventCallbackUV, cb),
            path,
            flags,
        );
        try check(res);
    }
    /// Stop the handle, the callback will no longer be called
    pub fn stop(self: *Self) !void {
        const res = c.uv_fs_event_stop(self.toUV());
        try check(res);
    }
    /// Get the path being monitored by the handle
    pub fn getpath(self: *Self, buffer: [*c]u8, size: [*c]usize) !void {
        const res = c.uv_fs_event_getpath(self.toUV(), buffer, size);
        try check(res);
    }
};

/// Event types that event handles monitor
pub usingnamespace struct {
    pub const CHANGE = c.UV_CHANGE;
    pub const RENAME = c.UV_RENAME;
};

/// Flags that can be passed to `FsEvent.start`
/// to control its behavior
pub usingnamespace struct {
    pub const FS_EVENT_RECURSIVE = c.UV_FS_EVENT_RECURSIVE;
    pub const FS_EVENT_STAT = c.UV_FS_EVENT_STAT;
    pub const FS_EVENT_WATCH_ENTRY = c.UV_FS_EVENT_WATCH_ENTRY;
};
