const std = @import("std");

const c = @import("c.zig").c;

const Loop = @import("loop.zig").Loop;
const check = @import("error.zig").check;
const misc = @import("misc.zig");

/// `addrinfo` struct
pub const AddrInfo = struct {
    const Self = @This();
    pub const UVAddrInfo = c.struct_addrinfo;
    /// A `libuv`'s `addrinfo` struct
    uv_addrinfo: *UVAddrInfo,
    /// Free the struct
    pub fn free(self: *Self) void {
        c.uv_freeaddrinfo(self.uv_addrinfo);
    }
};

/// `getaddrinfo` request type
pub const GetAddrInfo = struct {
    const Self = @This();
    pub const UVGetAddrInfo = c.uv_getaddrinfo_t;
    pub const Callback = c.uv_getaddrinfo_cb;
    /// A `libuv`'s `getaddrinfo` request type
    req: UVGetAddrInfo,
    /// Call `getaddrinfo` asynchronously
    pub fn getaddrinfo(
        self: *Self,
        loop: *Loop,
        cb: Callback,
        node: ?*const u8,
        service: ?*const u8,
        hints: ?*AddrInfo.UVAddrInfo,
    ) !void {
        const res = c.uv_getaddrinfo(loop.uv_loop, &self.req, cb, node, service, hints);
        try check(res);
    }
};

/// `getnameinfo` request type
pub const GetNameInfo = struct {
    const Self = @This();
    const Callback = c.uv_getnameinfo_cb;
    /// A `libuv`'s `getnamerinfo` request type
    req: c.uv_getnameinfo_t,
};

/// A `getaddrinfo` callback for the test
pub fn gotAddrInfo(
    uv_getaddrinfo: ?*GetAddrInfo.UVGetAddrInfo,
    status: c_int,
    res: ?*AddrInfo.UVAddrInfo,
) callconv(.C) void {
    _ = uv_getaddrinfo;
    // Check the status
    check(status) catch unreachable;
    // Assert we got a matching network address
    const addrinfo = res.?;
    // Get the IP4 name
    var buffer = [_]u8{0} ** 11;
    misc.ip4Name(
        @ptrCast(*const c.sockaddr_in, @alignCast(@alignOf(c.sockaddr_in), addrinfo.ai_addr)),
        buffer[0..10],
    ) catch unreachable;
    // Check whether it's actually an IP4 `localhost` address
    std.debug.assert(std.mem.eql(
        u8,
        "127.0.0.1",
        std.mem.span(@ptrCast([*:0]const u8, &buffer)),
    ));
    // Free the memory initialized for the linked list
    c.uv_freeaddrinfo(res);
}

test "`getaddrinfo`" {
    // Initialize the loop
    var loop = try Loop.init(std.testing.allocator);
    defer loop.deinit();
    // Prepare hints
    var hints: AddrInfo.UVAddrInfo = undefined;
    hints.ai_family = c.AF_INET;
    hints.ai_socktype = c.SOCK_STREAM;
    hints.ai_protocol = c.IPPROTO_TCP;
    hints.ai_flags = 0;
    // Prepare a request
    var req: GetAddrInfo = undefined;
    const node = @ptrCast(*const u8, "localhost");
    try req.getaddrinfo(&loop, gotAddrInfo, node, null, &hints);
    // Run the loop
    try loop.run(Loop.RunMode.DEFAULT);
    // Close the loop
    try loop.close();
}
