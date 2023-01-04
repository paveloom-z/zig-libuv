const std = @import("std");

const lib = @import("lib.zig");

const Cast = lib.Cast;
const c = lib.c;
const misc = lib.misc;
const utils = lib.utils;

/// Base handle
pub const Handle = extern struct {
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
    pub const AllocCallback = ?fn (anytype, usize, *misc.Buf) callconv(.C) void;
    pub const AllocCallbackUV = c.uv_alloc_cb;
    pub const CloseCallback = ?fn (anytype) callconv(.C) void;
    pub const CloseCallbackUV = c.uv_close_cb;
    /// Request handle to be closed
    pub fn close(handle: anytype, close_cb: CloseCallback) void {
        c.uv_close(
            Handle.toUV(handle),
            @ptrCast(CloseCallbackUV, close_cb),
        );
    }
};
