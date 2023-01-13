const std = @import("std");

const lib = @import("lib.zig");

const Cast = lib.Cast;
const c = lib.c;
const check = lib.check;
const dns = lib.dns;

/// Buffer data type
pub const Buf = extern struct {
    const Self = @This();
    pub const UV = c.uv_buf_t;
    base: [*c]u8,
    len: usize,
    usingnamespace Cast(Self);
};

/// Cross platform representation of a file handle
pub const File = c.uv_file;

/// Cross platform representation of a socket handle
pub const OsSock = c.uv_os_sock_t;

/// Abstract representation of a file descriptor
pub const OsFd = c.uv_os_fd_t;

/// Convert a binary structure containing an IPv4 address to a string
pub fn ip4Name(src: *const dns.SockAddrIn, slice: []u8) !void {
    const res = c.uv_ip4_name(src.toConstUV(), slice.ptr, slice.len);
    try check(res);
}

/// Convert a string containing an IPv4 addresses to a binary structure
pub fn ip4Addr(ip: []const u8, port: c_int, addr: *dns.SockAddrIn) !void {
    const res = c.uv_ip4_addr(@ptrCast(*const u8, ip), port, addr.toUV());
    try check(res);
}
