const std = @import("std");

const lib = @import("lib.zig");

const Cast = lib.Cast;
const c = lib.c;
const check = lib.check;

/// Base request
pub const Req = extern struct {
    /// Type of a base request
    pub const Type = enum(c_int) {
        UV_CONNECT = c.UV_CONNECT,
        UV_FS = c.UV_FS,
        UV_GETADDRINFO = c.UV_GETADDRINFO,
        UV_GETNAMEINFO = c.UV_GETNAMEINFO,
        UV_RANDOM = c.UV_RANDOM,
        UV_REQ = c.UV_REQ,
        UV_REQ_TYPE_MAX = c.UV_REQ_TYPE_MAX,
        UV_SHUTDOWN = c.UV_SHUTDOWN,
        UV_UDP_SEND = c.UV_UDP_SEND,
        UV_UNKNOWN_REQ = c.UV_UNKNOWN_REQ,
        UV_WORK = c.UV_WORK,
        UV_WRITE = c.UV_WRITE,
    };
    const Self = @This();
    pub const UV = c.uv_req_t;
    data: ?*anyopaque,
    type: Type,
    reserved: [6]?*anyopaque,
    usingnamespace Cast(Self);
    usingnamespace ReqDecls;
};

/// Base request decls
pub const ReqDecls = struct {
    /// Cancel a pending request
    pub fn cancel(self: anytype) !void {
        const res = c.uv_cancel(Req.toUV(self));
        try check(res);
    }
    /// Cancel a pending request
    pub fn reqSize(@"type": Req.Type) usize {
        return c.uv_req_size(@"type");
    }
};
