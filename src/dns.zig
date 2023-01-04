const std = @import("std");

const types = @import("dns/types.zig");

pub const AddrInfo = types.AddrInfo;
pub const SockAddr = types.SockAddr;
pub const SockAddrIn = types.SockAddrIn;
pub const GetAddrInfo = @import("dns/getaddrinfo.zig").GetAddrInfo;
pub const GetNameInfo = @import("dns/getnameinfo.zig").GetNameInfo;

test {
    // Reference nested container tests
    std.testing.refAllDecls(@This());
}
