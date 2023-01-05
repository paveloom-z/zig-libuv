const std = @import("std");

const types = @import("dns/types.zig");

pub const AddrFamily = types.AddrFamily;
pub const AddrInfo = types.AddrInfo;
pub const IPPort = types.IPPort;
pub const IPProtocol = types.IPProtocol;
pub const SockAddr = types.SockAddr;
pub const SockAddrIn = types.SockAddrIn;
pub const SockType = types.SockType;
pub const GetAddrInfo = @import("dns/getaddrinfo.zig").GetAddrInfo;
pub const GetNameInfo = @import("dns/getnameinfo.zig").GetNameInfo;

test {
    // Reference nested container tests
    std.testing.refAllDecls(@This());
}
