const std = @import("std");

const lib = @import("lib.zig");

const Cast = lib.Cast;
const c = lib.c;
const misc = lib.misc;
const utils = lib.utils;

/// Base handle
pub const Handle = extern struct {
    /// Type of a base handle
    const Type = enum(c_int) {
        UV_ASYNC = c.UV_ASYNC,
        UV_CHECK = c.UV_CHECK,
        UV_FILE = c.UV_FILE,
        UV_FS_EVENT = c.UV_FS_EVENT,
        UV_FS_POLL = c.UV_FS_POLL,
        UV_HANDLE = c.UV_HANDLE,
        UV_HANDLE_TYPE_MAX = c.UV_HANDLE_TYPE_MAX,
        UV_IDLE = c.UV_IDLE,
        UV_NAMED_PIPE = c.UV_NAMED_PIPE,
        UV_POLL = c.UV_POLL,
        UV_PREPARE = c.UV_PREPARE,
        UV_PROCESS = c.UV_PROCESS,
        UV_SIGNAL = c.UV_SIGNAL,
        UV_STREAM = c.UV_STREAM,
        UV_TCP = c.UV_TCP,
        UV_TIMER = c.UV_TIMER,
        UV_TTY = c.UV_TTY,
        UV_UDP = c.UV_UDP,
        UV_UNKNOWN_HANDLE = c.UV_UNKNOWN_HANDLE,
    };
    const Self = @This();
    pub const UV = c.uv_handle_t;
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
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
};

/// Base handle declarations
pub const HandleDecls = struct {
    pub const AllocCallback = ?fn (?*Handle, usize, ?*misc.Buf) callconv(.C) void;
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
    /// Returns the size of the given handle type
    pub fn handleSize(@"type": Handle.Type) usize {
        return c.uv_handle_size(@"type");
    }
};
