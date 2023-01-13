const std = @import("std");

const uv = @import("../lib.zig");

const AddrInfo = uv.AddrInfo;
const Cast = uv.Cast;
const Loop = uv.Loop;
const c = uv.c;
const check = uv.check;
const ip4Name = uv.ip4Name;

/// `getaddrinfo` request type
pub const GetAddrInfo = extern struct {
    const Self = @This();
    pub const UV = c.uv_getaddrinfo_t;
    pub const Callback = ?fn (?*GetAddrInfo, c_int, ?*AddrInfo) callconv(.C) void;
    pub const CallbackUV = c.uv_getaddrinfo_cb;
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
        node: ?[*:0]const u8,
        service: ?[*:0]const u8,
        hints: ?*uv.AddrInfo,
    ) !void {
        const res = c.uv_getaddrinfo(
            loop.toUV(),
            self.toUV(),
            @ptrCast(CallbackUV, cb),
            node,
            service,
            uv.AddrInfo.toUV(hints),
        );
        try check(res);
    }
};

/// A `getaddrinfo` callback for the test
fn gotAddrInfo(
    maybe_getaddrinfo: ?*GetAddrInfo,
    status: c_int,
    maybe_res: ?*uv.AddrInfo,
) callconv(.C) void {
    _ = maybe_getaddrinfo;
    // Check the status
    check(status) catch unreachable;
    // Assert we actually got a matching network address
    const res = maybe_res.?;
    defer res.free();
    // Get the IP4 address
    var buffer = [_]u8{0} ** 11;
    ip4Name(res.ai_addr.asIn(), buffer[0..10]) catch unreachable;
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
    var hints: uv.AddrInfo = undefined;
    hints.ai_family = uv.AF_INET;
    hints.ai_socktype = uv.SOCK_STREAM;
    hints.ai_protocol = uv.IPPROTO_TCP;
    hints.ai_flags = 0;
    // Prepare a request
    var req: GetAddrInfo = undefined;
    const hostname = "localhost";
    try req.getaddrinfo(loop, gotAddrInfo, hostname, null, &hints);
    // Run the loop
    try loop.run(uv.RUN_DEFAULT);
    // Close the loop
    try loop.close();
}
