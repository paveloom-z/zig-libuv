const std = @import("std");

const lib = @import("../lib.zig");

const c = lib.c;
const Loop = lib.Loop;
const check = lib.check;
const misc = lib.misc;
const utils = lib.utils;

/// `getnameinfo` request type
pub const GetNameInfo = struct {
    const Self = @This();
    pub const UV = c.uv_getnameinfo_t;
    pub const Callback = c.uv_getnameinfo_cb;
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
    /// Call `getnameinfo` asynchronously
    pub fn getnameinfo(
        self: *Self,
        loop: *Loop,
        cb: Callback,
        addr: *const c.struct_sockaddr,
        flags: c_int,
    ) !void {
        const res = c.uv_getnameinfo(
            loop.uv_loop,
            utils.toUV(Self, self),
            cb,
            addr,
            flags,
        );
        try check(res);
    }
};

/// A `getnameinfo` callback for the test
pub fn gotNameInfo(
    uv_getaddrinfo: ?*GetNameInfo.UV,
    status: c_int,
    maybe_hostname: ?*const u8,
    maybe_service: ?*const u8,
) callconv(.C) void {
    _ = uv_getaddrinfo;
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
    // Initialize the loop
    var loop = try Loop.init(std.testing.allocator);
    defer loop.deinit();
    // Prepare an address
    var sockaddr: c.sockaddr_in = undefined;
    misc.ip4Addr("127.0.0.1", 80, &sockaddr) catch unreachable;
    // Prepare a request
    var req: GetNameInfo = undefined;
    try req.getnameinfo(&loop, gotNameInfo, @ptrCast(*const c.sockaddr, &sockaddr), 0);
    // Run the loop
    try loop.run(Loop.RunMode.DEFAULT);
    // Close the loop
    try loop.close();
}
