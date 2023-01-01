const std = @import("std");

const lib = @import("../lib.zig");

const Cast = lib.Cast;
const Loop = lib.Loop;
const c = lib.c;
const check = lib.check;
const misc = lib.misc;

/// `addrinfo` struct
pub const AddrInfo = extern struct {
    const Self = @This();
    pub const UV = c.struct_addrinfo;
    ai_flags: c_int,
    ai_family: c_int,
    ai_socktype: c_int,
    ai_protocol: c_int,
    ai_addrlen: c.socklen_t,
    ai_addr: [*c]c.struct_sockaddr,
    ai_canonname: [*c]u8,
    ai_next: [*c]c.struct_addrinfo,
    usingnamespace Cast(Self);
    /// Free the struct
    pub fn free(self: *Self) void {
        c.uv_freeaddrinfo(self.toUV());
    }
};

/// `getaddrinfo` request type
pub const GetAddrInfo = extern struct {
    const Self = @This();
    pub const UV = c.uv_getaddrinfo_t;
    pub const Callback = c.uv_getaddrinfo_cb;
    data: ?*anyopaque,
    type: c.uv_req_type,
    reserved: [6]?*anyopaque,
    loop: [*c]c.uv_loop_t,
    work_req: c.struct_uv__work,
    cb: c.uv_getaddrinfo_cb,
    hints: [*c]c.struct_addrinfo,
    hostname: [*c]u8,
    service: [*c]u8,
    addrinfo: [*c]c.struct_addrinfo,
    retcode: c_int,
    usingnamespace Cast(Self);
    /// Call `getaddrinfo` asynchronously
    pub fn getaddrinfo(
        self: *Self,
        loop: *Loop,
        cb: Callback,
        node: ?*const u8,
        service: ?*const u8,
        hints: ?*AddrInfo,
    ) !void {
        const res = c.uv_getaddrinfo(
            loop.uv_loop,
            self.toUV(),
            cb,
            node,
            service,
            AddrInfo.toUV(hints),
        );
        try check(res);
    }
};

/// A `getaddrinfo` callback for the test
pub fn gotAddrInfo(
    uv_getaddrinfo: ?*GetAddrInfo.UV,
    status: c_int,
    maybe_uv_res: ?*AddrInfo.UV,
) callconv(.C) void {
    _ = uv_getaddrinfo;
    // Check the status
    check(status) catch unreachable;
    // Cast the pointer to the result to get the sweet methods
    //
    // Also, assert we actually got a matching network address
    const res = AddrInfo.fromUV(maybe_uv_res).?;
    defer res.free();
    // Get the IP4 address
    var buffer = [_]u8{0} ** 11;
    misc.ip4Name(
        @ptrCast(*const c.sockaddr_in, @alignCast(@alignOf(c.sockaddr_in), res.ai_addr)),
        buffer[0..10],
    ) catch unreachable;
    // Check whether the address is correct
    std.debug.assert(std.mem.eql(
        u8,
        "127.0.0.1",
        std.mem.span(@ptrCast([*:0]const u8, &buffer)),
    ));
}

test "`getaddrinfo`" {
    // Initialize the loop
    var loop = try Loop.init(std.testing.allocator);
    defer loop.deinit();
    // Prepare hints
    var hints: AddrInfo = undefined;
    hints.ai_family = c.AF_INET;
    hints.ai_socktype = c.SOCK_STREAM;
    hints.ai_protocol = c.IPPROTO_TCP;
    hints.ai_flags = 0;
    // Prepare a request
    var req: GetAddrInfo = undefined;
    const hostname = @ptrCast(*const u8, "localhost");
    try req.getaddrinfo(&loop, gotAddrInfo, hostname, null, &hints);
    // Run the loop
    try loop.run(Loop.RunMode.DEFAULT);
    // Close the loop
    try loop.close();
}
