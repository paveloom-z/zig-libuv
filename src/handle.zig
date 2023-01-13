const std = @import("std");

const uv = @import("lib.zig");

const Buf = uv.Buf;
const Cast = uv.Cast;
const c = uv.c;
const utils = uv.utils;

/// Base handle
pub const Handle = extern struct {
    /// Type of a base handle
    const Type = c.uv_handle_type;
    const Self = @This();
    pub const UV = c.uv_handle_t;
    data: ?*anyopaque,
    loop: [*c]c.uv_loop_t,
    type: Type,
    close_cb: c.uv_close_cb,
    handle_queue: [2]?*anyopaque,
    u: extern union {
        fd: c_int,
        reserved: [4]?*anyopaque,
    },
    next_closing: [*c]c.uv_handle_t,
    flags: c_uint,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    /// Returns the size of the given handle type
    pub fn handleSize(@"type": Type) usize {
        return c.uv_handle_size(@"type");
    }
};

/// Base handle declarations
pub const HandleDecls = struct {
    pub const AllocCallback = ?fn (?*Handle, usize, ?*Buf) callconv(.C) void;
    pub const AllocCallbackUV = c.uv_alloc_cb;
    pub const CloseCallback = ?fn (?*Handle) callconv(.C) void;
    pub const CloseCallbackUV = c.uv_close_cb;
    /// Returns `true` if the handle is active, `false` if it’s inactive
    pub fn isActive(handle: anytype) bool {
        return c.uv_is_active(Handle.toUV(handle)) != 0;
    }
    /// Returns `true` if the handle is closing or closed, `false` otherwise
    pub fn isClosing(handle: anytype) bool {
        return c.uv_is_closing(Handle.toUV(handle)) != 0;
    }
    /// Request handle to be closed
    pub fn close(handle: anytype, close_cb: CloseCallback) void {
        c.uv_close(
            Handle.toUV(handle),
            @ptrCast(CloseCallbackUV, close_cb),
        );
    }
    /// Reference the given handle
    pub fn ref(handle: anytype) void {
        return c.uv_ref(Handle.toUV(handle));
    }
    /// Un-reference the given handle
    pub fn unref(handle: anytype) void {
        return c.uv_unref(Handle.toUV(handle));
    }
    /// Returns non-zero if the handle referenced, zero otherwise
    pub fn hasRef(handle: anytype) bool {
        return c.uv_has_ref(Handle.toUV(handle)) != 0;
    }
};

/// Types of a base handle
pub usingnamespace struct {
    pub const UV_ASYNC = c.UV_ASYNC;
    pub const UV_CHECK = c.UV_CHECK;
    pub const UV_FILE = c.UV_FILE;
    pub const UV_FS_EVENT = c.UV_FS_EVENT;
    pub const UV_FS_POLL = c.UV_FS_POLL;
    pub const UV_HANDLE = c.UV_HANDLE;
    pub const UV_HANDLE_TYPE_MAX = c.UV_HANDLE_TYPE_MAX;
    pub const UV_IDLE = c.UV_IDLE;
    pub const UV_NAMED_PIPE = c.UV_NAMED_PIPE;
    pub const UV_POLL = c.UV_POLL;
    pub const UV_PREPARE = c.UV_PREPARE;
    pub const UV_PROCESS = c.UV_PROCESS;
    pub const UV_SIGNAL = c.UV_SIGNAL;
    pub const UV_STREAM = c.UV_STREAM;
    pub const UV_TCP = c.UV_TCP;
    pub const UV_TIMER = c.UV_TIMER;
    pub const UV_TTY = c.UV_TTY;
    pub const UV_UDP = c.UV_UDP;
    pub const UV_UNKNOWN_HANDLE = c.UV_UNKNOWN_HANDLE;
};
