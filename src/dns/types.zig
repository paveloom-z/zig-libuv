const std = @import("std");

const lib = @import("../lib.zig");

const Cast = lib.Cast;
const c = lib.c;

/// `addrinfo` struct
pub const AddrInfo = extern struct {
    const Self = @This();
    pub const UV = c.struct_addrinfo;
    ai_flags: c_int,
    ai_family: c_int,
    ai_socktype: c_int,
    ai_protocol: c_int,
    ai_addrlen: c.socklen_t,
    ai_addr: *SockAddr,
    ai_canonname: [*c]u8,
    ai_next: *Self,
    usingnamespace Cast(Self);
    /// Free the struct
    pub fn free(self: *Self) void {
        c.uv_freeaddrinfo(self.toUV());
    }
};

/// `sockaddr` struct
pub const SockAddr = extern struct {
    const Self = @This();
    pub const UV = c.struct_sockaddr;
    sa_family: c.sa_family_t,
    sa_data: [14]u8,
    usingnamespace Cast(Self);
    /// Cast `*Self` to `*const SockAddrIn`
    pub fn asIn(self: *Self) *const SockAddrIn {
        return @ptrCast(*const SockAddrIn, @alignCast(@alignOf(SockAddrIn), self));
    }
};

/// `sockaddr_in` struct
pub const SockAddrIn = extern struct {
    const Self = @This();
    pub const UV = c.struct_sockaddr_in;
    sin_family: c.sa_family_t,
    sin_port: c.in_port_t,
    sin_addr: c.struct_in_addr,
    sin_zero: [8]u8,
    usingnamespace Cast(Self);
    /// Cast `*Self` to `*const SockAddr`
    pub fn asAddr(self: *Self) *const SockAddr {
        return @ptrCast(*const SockAddr, self);
    }
};
