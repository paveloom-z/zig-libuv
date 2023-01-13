const std = @import("std");

const uv = @import("lib.zig");

const Cast = uv.Cast;
const c = uv.c;
const check = uv.check;

/// Base request
pub const Req = extern struct {
    /// Type of a base request
    pub const Type = c.uv_req_type;
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

/// Types of a base request
pub usingnamespace struct {
    pub const UV_CONNECT = c.UV_CONNECT;
    pub const UV_FS = c.UV_FS;
    pub const UV_GETADDRINFO = c.UV_GETADDRINFO;
    pub const UV_GETNAMEINFO = c.UV_GETNAMEINFO;
    pub const UV_RANDOM = c.UV_RANDOM;
    pub const UV_REQ = c.UV_REQ;
    pub const UV_REQ_TYPE_MAX = c.UV_REQ_TYPE_MAX;
    pub const UV_SHUTDOWN = c.UV_SHUTDOWN;
    pub const UV_UDP_SEND = c.UV_UDP_SEND;
    pub const UV_UNKNOWN_REQ = c.UV_UNKNOWN_REQ;
    pub const UV_WORK = c.UV_WORK;
    pub const UV_WRITE = c.UV_WRITE;
};
