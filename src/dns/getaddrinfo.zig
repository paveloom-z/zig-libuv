const std = @import("std");

const lib = @import("../lib.zig");

const Cast = lib.Cast;
const Loop = lib.Loop;
const c = lib.c;
const check = lib.check;
const dns = lib.dns;
const misc = lib.misc;

/// `getaddrinfo` request type
pub const GetAddrInfo = extern struct {
    const Self = @This();
    pub const UV = c.uv_getaddrinfo_t;
    pub const Callback = ?fn (?*GetAddrInfo, c_int, ?*dns.AddrInfo) callconv(.C) void;
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
        hints: ?*dns.AddrInfo,
    ) !void {
        const res = c.uv_getaddrinfo(
            loop.toUV(),
            self.toUV(),
            @ptrCast(c.uv_getaddrinfo_cb, cb),
            node,
            service,
            dns.AddrInfo.toUV(hints),
        );
        try check(res);
    }
};

/// A `getaddrinfo` callback for the test
fn gotAddrInfo(
    uv_getaddrinfo: ?*GetAddrInfo,
    status: c_int,
    maybe_uv_res: ?*dns.AddrInfo,
) callconv(.C) void {
    _ = uv_getaddrinfo;
    // Check the status
    check(status) catch unreachable;
    // Assert we actually got a matching network address
    const res = maybe_uv_res.?;
    defer res.free();
    // Get the IP4 address
    var buffer = [_]u8{0} ** 11;
    misc.ip4Name(res.ai_addr.asIn(), buffer[0..10]) catch unreachable;
    // Check whether the address is correct
    std.debug.assert(std.mem.eql(
        u8,
        "127.0.0.1",
        std.mem.span(@ptrCast([*:0]const u8, &buffer)),
    ));
}

test "`getaddrinfo`" {
    const alloc = std.testing.allocator;
    // Initialize the loop
    var loop = try alloc.create(Loop);
    try Loop.init(loop);
    defer alloc.destroy(loop);
    // Prepare hints
    var hints: dns.AddrInfo = undefined;
    hints.ai_family = c.AF_INET;
    hints.ai_socktype = c.SOCK_STREAM;
    hints.ai_protocol = c.IPPROTO_TCP;
    hints.ai_flags = 0;
    // Prepare a request
    var req: GetAddrInfo = undefined;
    const hostname = @ptrCast(*const u8, "localhost");
    try req.getaddrinfo(loop, gotAddrInfo, hostname, null, &hints);
    // Run the loop
    try loop.run(Loop.RunMode.DEFAULT);
    // Close the loop
    try loop.close();
}
