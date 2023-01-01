const std = @import("std");

const c = @import("c.zig").c;

const check = @import("error.zig").check;

/// Convert a binary structure containing an IPv4 address into a buffer
pub fn ip4Name(src: *const c.struct_sockaddr_in, slice: []u8) !void {
    const res = c.uv_ip4_name(src, slice.ptr, slice.len);
    try check(res);
}
