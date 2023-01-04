const std = @import("std");

const lib = @import("lib.zig");

const Cast = lib.Cast;
const Connect = lib.Connect;
const HandleDecls = lib.HandleDecls;
const Loop = lib.Loop;
const StreamDecls = lib.StreamDecls;
const c = lib.c;
const check = lib.check;
const dns = lib.dns;
const misc = lib.misc;

/// TCP handle
pub const TCP = extern struct {
    const Self = @This();
    pub const UV = c.uv_tcp_t;
    data: ?*anyopaque,
    loop: [*c]c.uv_loop_t,
    type: c.uv_handle_type,
    close_cb: c.uv_close_cb,
    handle_queue: [2]?*anyopaque,
    u: extern union {
        fd: c_int,
        reserved: [4]?*anyopaque,
    },
    next_closing: [*c]c.uv_handle_t,
    flags: c_uint,
    write_queue_size: usize,
    alloc_cb: c.uv_alloc_cb,
    read_cb: c.uv_read_cb,
    connect_req: [*c]c.uv_connect_t,
    shutdown_req: [*c]c.uv_shutdown_t,
    io_watcher: c.uv__io_t,
    write_queue: [2]?*anyopaque,
    write_completed_queue: [2]?*anyopaque,
    connection_cb: c.uv_connection_cb,
    delayed_error: c_int,
    accepted_fd: c_int,
    queued_fds: ?*anyopaque,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    usingnamespace StreamDecls;
    /// Initialize the handle
    pub fn init(loop: *Loop) !Self {
        // Prepare a pointer for the handle
        var self: Self = undefined;
        // Initialize the handle
        const res = c.uv_tcp_init(loop.toUV(), self.toUV());
        try check(res);
        // Return the handle
        return self;
    }
    /// Initialize the handle with the specified flags
    pub fn initEx(loop: *Loop, flags: c_uint) !Self {
        // Prepare a pointer for the handle
        var self: Self = undefined;
        // Initialize the handle
        const res = c.uv_tcp_init_ex(loop.toUV(), self.toUV(), flags);
        try check(res);
        // Return the handle
        return self;
    }
    /// Open an existing file descriptor or SOCKET as a TCP handle
    pub fn open(self: *Self, sock: misc.OsSock) !void {
        const res = c.uv_tcp_open(self.toUV(), sock);
        try check(res);
    }
    /// Enable TCP_NODELAY, which disables Nagle’s algorithm
    pub fn noDelay(self: *Self, enable: c_int) !void {
        const res = c.uv_tcp_nodelay(self.toUV(), enable);
        try check(res);
    }
    /// Enable / disable TCP keep-alive
    pub fn keepAlive(self: *Self, enable: c_int, delay: c_uint) !void {
        const res = c.uv_tcp_keepalive(self.toUV(), enable, delay);
        try check(res);
    }
    /// Enable / disable simultaneous asynchronous accept requests
    /// that are queued by the operating system when listening for
    /// new TCP connections
    pub fn simultaneousAccepts(self: *Self, enable: c_int) !void {
        const res = c.uv_tcp_simultaneous_accepts(self.toUV(), enable);
        try check(res);
    }
    /// Bind the handle to an address and port
    pub fn bind(self: *Self, addr: *const dns.SockAddr, flags: c_uint) !void {
        const res = c.uv_tcp_bind(self.toUV(), addr.toUV(), flags);
        try check(res);
    }
    /// Get the current address to which the handle is bound
    pub fn getSockName(self: *Self, name: *dns.SockAddr, namelen: *c_int) !void {
        const res = c.uv_tcp_getsockname(self.toUV(), name.toUV(), namelen);
        try check(res);
    }
    /// Get the address of the peer connected to the handle
    pub fn getPeerName(self: *Self, name: *dns.SockAddr, namelen: *c_int) !void {
        const res = c.uv_tcp_getpeername(self.toUV(), name.toUV(), namelen);
        try check(res);
    }
    /// Establish an IPv4 or IPv6 TCP connection
    pub fn connect(
        self: *Self,
        req: *Connect,
        addr: *const dns.SockAddr,
        cb: Self.ConnectionCallback,
    ) !void {
        const res = c.uv_tcp_connect(req.toUV(), self.toUV(), addr.toUV(), cb);
        try check(res);
    }
    /// Reset a TCP connection by sending a RST packet
    pub fn closeReset(self: *Self, close_cb: Self.CloseCallback) !void {
        const res = c.uv_tcp_close_reset(self.toUV(), close_cb);
        try check(res);
    }
    /// Create a pair of connected sockets with the specified properties
    pub fn socketPair(
        @"type": c_int,
        protocol: c_int,
        socket_vector: *misc.OsSock,
        flags0: c_int,
        flags1: c_int,
    ) !void {
        const res = c.uv_socketpair(@"type", protocol, socket_vector, flags0, flags1);
        try check(res);
    }
};
