const std = @import("std");

const lib = @import("lib.zig");

const c = lib.c;
const check = lib.check;

/// Convert a binary structure containing an IPv4 address to a string
pub fn ip4Name(src: *const c.struct_sockaddr_in, slice: []u8) !void {
    const res = c.uv_ip4_name(src, slice.ptr, slice.len);
    try check(res);
}

/// Convert a string containing an IPv4 addresses to a binary structure
pub fn ip4Addr(ip: []const u8, port: c_int, addr: *c.sockaddr_in) !void {
    const res = c.uv_ip4_addr(@ptrCast(*const u8, ip), port, addr);
    try check(res);
}
