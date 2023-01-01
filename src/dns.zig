const std = @import("std");

const getaddrinfo = @import("dns/getaddrinfo.zig");
const getnameinfo = @import("dns/getnameinfo.zig");

pub const AddrInfo = getaddrinfo.AddrInfo;
pub const GetAddrInfo = getaddrinfo.GetAddrInfo;
pub const GetNameInfo = getnameinfo.GetNameInfo;

test {
    // Reference nested container tests
    std.testing.refAllDecls(@This());
}
