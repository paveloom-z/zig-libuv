const std = @import("std");

const uv = @import("uv.zig");

const Cast = uv.Cast;
const Connect = uv.Connect;
const Handle = uv.Handle;
const HandleDecls = uv.HandleDecls;
const Loop = uv.Loop;
const OsSock = uv.OsSock;
const Shutdown = uv.Shutdown;
const SockAddr = uv.SockAddr;
const Stream = uv.Stream;
const StreamDecls = uv.StreamDecls;
const c = uv.c;
const check = uv.check;

/// TCP handle
pub const Tcp = extern struct {
    const Self = @This();
    pub const UV = c.uv_tcp_t;
    data: ?*anyopaque,
    loop: ?*Loop,
    type: c.uv_handle_type,
    close_cb: c.uv_close_cb,
    handle_queue: [2]?*anyopaque,
    u: extern union {
        fd: c_int,
        reserved: [4]?*anyopaque,
    },
    next_closing: ?*Handle,
    flags: c_uint,
    write_queue_size: usize,
    alloc_cb: Handle.AllocCallbackUV,
    read_cb: Stream.ReadCallbackUV,
    connect_req: ?*Stream.ConnectCallbackUV,
    shutdown_req: ?*Shutdown.ShutdownCallbackUV,
    io_watcher: c.uv__io_t,
    write_queue: [2]?*anyopaque,
    write_completed_queue: [2]?*anyopaque,
    connection_cb: Stream.ConnectionCallbackUV,
    delayed_error: c_int,
    accepted_fd: c_int,
    queued_fds: ?*anyopaque,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    usingnamespace StreamDecls;
    /// Initialize the handle
    pub fn init(self: *Self, loop: *Loop) !void {
        // Initialize the handle
        const res = c.uv_tcp_init(loop.toUV(), self.toUV());
        try check(res);
    }
    /// Initialize the handle with the specified flags
    pub fn initEx(self: *Self, loop: *Loop, flags: c_uint) !void {
        // Initialize the handle
        const res = c.uv_tcp_init_ex(loop.toUV(), self.toUV(), flags);
        try check(res);
    }
    /// Open an existing file descriptor or SOCKET as a TCP handle
    pub fn open(self: *Self, sock: OsSock) !void {
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
    pub fn bind(self: *Self, addr: *const SockAddr, flags: c_uint) !void {
        const res = c.uv_tcp_bind(self.toUV(), addr.toConstUV(), flags);
        try check(res);
    }
    /// Get the current address to which the handle is bound
    pub fn getSockName(self: *Self, name: *SockAddr, namelen: *c_int) !void {
        const res = c.uv_tcp_getsockname(self.toUV(), name.toUV(), namelen);
        try check(res);
    }
    /// Get the address of the peer connected to the handle
    pub fn getPeerName(self: *Self, name: *SockAddr, namelen: *c_int) !void {
        const res = c.uv_tcp_getpeername(self.toUV(), name.toUV(), namelen);
        try check(res);
    }
    /// Establish an IPv4 or IPv6 TCP connection
    pub fn connect(
        self: *Self,
        req: *Connect,
        addr: *const SockAddr,
        cb: Self.ConnectCallback,
    ) !void {
        const res = c.uv_tcp_connect(
            req.toUV(),
            self.toUV(),
            addr.toConstUV(),
            @ptrCast(Self.ConnectCallbackUV, cb),
        );
        try check(res);
    }
    /// Reset a TCP connection by sending a RST packet
    pub fn closeReset(self: *Self, close_cb: Self.CloseCallback) !void {
        const res = c.uv_tcp_close_reset(
            self.toUV(),
            @ptrCast(Self.CloseCallbackUV, close_cb),
        );
        try check(res);
    }
    /// Create a pair of connected sockets with the specified properties
    pub fn socketPair(
        @"type": c_int,
        protocol: c_int,
        socket_vector: *OsSock,
        flags0: c_int,
        flags1: c_int,
    ) !void {
        const res = c.uv_socketpair(@"type", protocol, socket_vector, flags0, flags1);
        try check(res);
    }
};
