const std = @import("std");

const lib = @import("../lib.zig");

const Cast = lib.Cast;
const Loop = lib.Loop;
const c = lib.c;
const check = lib.check;
const dns = lib.dns;
const misc = lib.misc;

/// `getnameinfo` request type
pub const GetNameInfo = struct {
    const Self = @This();
    pub const UV = c.uv_getnameinfo_t;
    pub const Callback = ?fn (*Self, c_int, *const u8, *const u8) callconv(.C) void;
    pub const CallbackUV = c.uv_getnameinfo_cb;
    data: ?*anyopaque,
    type: c.uv_req_type,
    reserved: [6]?*anyopaque,
    loop: [*c]c.uv_loop_t,
    work_req: c.struct_uv__work,
    getnameinfo_cb: c.uv_getnameinfo_cb,
    storage: c.struct_sockaddr_storage,
    flags: c_int,
    host: [1025]u8,
    service: [32]u8,
    retcode: c_int,
    usingnamespace Cast(Self);
    /// Call `getnameinfo` asynchronously
    pub fn getnameinfo(
        self: *Self,
        loop: *Loop,
        cb: Callback,
        addr: *const dns.SockAddr,
        flags: c_int,
    ) !void {
        const res = c.uv_getnameinfo(
            loop.toUV(),
            self.toUV(),
            @ptrCast(CallbackUV, cb),
            addr.toConstUV(),
            flags,
        );
        try check(res);
    }
};

/// A `getnameinfo` callback for the test
fn gotNameInfo(
    maybe_getnameinfo: ?*GetNameInfo,
    status: c_int,
    maybe_hostname: ?*const u8,
    maybe_service: ?*const u8,
) callconv(.C) void {
    _ = maybe_getnameinfo;
    // Check the status
    check(status) catch unreachable;
    // Assert we actually got a match
    const hostname = maybe_hostname.?;
    const service = maybe_service.?;
    // Check whether the hostname is correct
    std.debug.assert(std.mem.eql(
        u8,
        "localhost",
        std.mem.span(@ptrCast([*:0]const u8, hostname)),
    ));
    // Check whether the service is correct
    std.debug.assert(std.mem.eql(
        u8,
        "http",
        std.mem.span(@ptrCast([*:0]const u8, service)),
    ));
}

test "`getnameinfo`" {
    const alloc = std.testing.allocator;
    // Initialize the loop
    var loop = try alloc.create(Loop);
    try Loop.init(loop);
    defer alloc.destroy(loop);
    // Prepare an address
    var sockaddr_in: dns.SockAddrIn = undefined;
    misc.ip4Addr("127.0.0.1", 80, &sockaddr_in) catch unreachable;
    // Prepare a request
    var req: GetNameInfo = undefined;
    try req.getnameinfo(loop, gotNameInfo, sockaddr_in.asAddr(), 0);
    // Run the loop
    try loop.run(.DEFAULT);
    // Close the loop
    try loop.close();
}
