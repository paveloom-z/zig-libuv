const std = @import("std");

const uv = @import("uv.zig");

const Buf = uv.Buf;
const Cast = uv.Cast;
const Handle = uv.Handle;
const HandleDecls = uv.HandleDecls;
const Loop = uv.Loop;
const OsSock = uv.OsSock;
const Req = uv.Req;
const ReqDecls = uv.Req;
const SockAddr = uv.SockAddr;
const c = uv.c;
const check = uv.check;

/// Flags used in `Udp.bind` and `Udp.recvCb`
pub usingnamespace struct {
    pub const UDP_IPV6ONLY = c.UV_UDP_IPV6ONLY;
    pub const UDP_LINUX_RECVERR = c.UV_UDP_LINUX_RECVERR;
    pub const UDP_MMSG_CHUNK = c.UV_UDP_MMSG_CHUNK;
    pub const UDP_MMSG_FREE = c.UV_UDP_MMSG_FREE;
    pub const UDP_PARTIAL = c.UV_UDP_PARTIAL;
    pub const UDP_RECVMMSG = c.UV_UDP_RECVMMSG;
    pub const UDP_REUSEADDR = c.UV_UDP_REUSEADDR;
};

/// UDP handle
pub const Udp = extern struct {
    /// Membership type for a multicast address
    pub const Membership = c.uv_membership;
    const Self = @This();
    pub const UV = c.uv_udp_t;
    /// Type definition for callback passed to `recvStart`,
    /// which is called when the endpoint receives data.
    pub const UdpRecvCallback = ?*const fn (
        *Self,
        isize,
        *const Buf,
        *const SockAddr,
        c_uint,
    ) callconv(.C) void;
    pub const UdpRecvCallbackUV = c.uv_udp_recv_cb;
    data: ?*anyopaque,
    loop: ?*Loop,
    type: Handle.Type,
    close_cb: Handle.CloseCallbackUV,
    handle_queue: [2]?*anyopaque,
    u: extern union {
        fd: c_int,
        reserved: [4]?*anyopaque,
    },
    next_closing: ?*Handle,
    flags: c_uint,
    send_queue_size: usize,
    send_queue_count: usize,
    alloc_cb: Handle.AllocCallbackUV,
    recv_cb: UdpRecvCallbackUV,
    io_watcher: c.uv__io_t,
    write_queue: [2]?*anyopaque,
    write_completed_queue: [2]?*anyopaque,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    /// Initialize a new UDP handle
    pub fn init(self: *Self, loop: *Loop) !void {
        const res = c.uv_udp_init(loop.toUV(), self.toUV());
        try check(res);
    }
    /// Initialize the handle with the specified flags
    pub fn initEx(self: *Self, loop: *Loop, flags: c_uint) !void {
        const res = c.uv_udp_init_ex(loop.toUV(), self.toUV(), flags);
        try check(res);
    }
    /// Open an existing file descriptor or Windows SOCKET as a UDP handle
    pub fn open(self: *Self, sock: OsSock) !void {
        const res = c.uv_udp_open(self.toUV(), sock);
        try check(res);
    }
    /// Bind the UDP handle to an IP address and port
    pub fn bind(self: *Self, addr: *const SockAddr, flags: c_uint) !void {
        const res = c.uv_udp_bind(self.toUV(), addr.toConstUV(), flags);
        try check(res);
    }
    /// Associate the UDP handle to a remote address and port
    pub fn connect(self: *Self, addr: *const SockAddr) !void {
        const res = c.uv_udp_connect(self.toUV(), addr.toConstUV());
        try check(res);
    }
    /// Get the remote IP and port of the UDP handle on connected UDP handles
    pub fn getPeerName(
        self: *const Self,
        name: *SockAddr,
        namelen: *c_int,
    ) !void {
        const res = c.uv_udp_getpeername(
            self.toConstUV(),
            name.toUV(),
            namelen,
        );
        try check(res);
    }
    /// Get the local IP and port of the UDP handle
    pub fn getSockName(
        self: *const Self,
        name: *SockAddr,
        namelen: *c_int,
    ) !void {
        const res = c.uv_udp_getsockname(
            self.toConstUV(),
            name.toUV(),
            namelen,
        );
        try check(res);
    }
    /// Set membership for a multicast address
    pub fn setMembership(
        handle: *Self,
        multicast_addr: ?[*:0]const u8,
        interface_addr: ?[*:0]const u8,
        membership: Udp.Membership,
    ) !void {
        const res = c.uv_udp_set_membership(
            handle.toUV(),
            multicast_addr,
            interface_addr,
            membership,
        );
        try check(res);
    }
    /// Set membership for a source-specific multicast group.
    pub fn setSourceMembership(
        handle: *Self,
        multicast_addr: ?[*:0]const u8,
        interface_addr: ?[*:0]const u8,
        source_addr: ?[*:0]const u8,
        membership: Udp.Membership,
    ) !void {
        const res = c.uv_udp_set_source_membership(
            handle.toUV(),
            multicast_addr,
            interface_addr,
            source_addr,
            membership,
        );
        try check(res);
    }
    /// Set IP multicast loop flag
    pub fn setMulticastLoop(self: *Self, on: c_int) !void {
        const res = c.uv_udp_set_multicast_loop(self.toUV(), on);
        try check(res);
    }
    /// Set the multicast time to live
    pub fn setMulticastTtl(self: *Self, ttl: c_int) !void {
        const res = c.uv_udp_set_multicast_ttl(self.toUV(), ttl);
        try check(res);
    }
    /// Set the multicast interface to send or receive data on
    pub fn setMulticastInterface(
        self: *Self,
        interface_addr: [*c]const u8,
    ) !void {
        const res = c.uv_udp_set_multicast_interface(
            self.toUV(),
            interface_addr,
        );
        try check(res);
    }
    /// Set broadcast on or off
    pub fn setBroadcast(self: *Self, on: c_int) !void {
        const res = c.uv_udp_set_broadcast(self.toUV(), on);
        try check(res);
    }
    /// Set the time to live
    pub fn setTtl(self: *Self, ttl: c_int) !void {
        const res = c.uv_udp_set_ttl(self.toUV(), ttl);
        try check(res);
    }
    /// Same as `UdpSend.send`, but won’t queue a send
    /// request if it can’t be completed immediately
    pub fn trySend(
        self: *Self,
        bufs: [*c]const Buf,
        nbufs: c_uint,
        addr: *const SockAddr,
    ) !void {
        const res = c.uv_udp_try_send(
            self.toUV(),
            bufs.toConstUV(),
            nbufs,
            addr.toConstUV(),
        );
        try check(res);
    }
    /// Prepare for receiving data
    pub fn recvStart(
        self: *Self,
        alloc_cb: Handle.AllocCallback,
        recv_cb: UdpRecvCallback,
    ) !void {
        const res = c.uv_udp_recv_start(
            self.toUV(),
            @ptrCast(Handle.AllocCallback, alloc_cb),
            @ptrCast(UdpRecvCallbackUV, recv_cb),
        );
        try check(res);
    }
    /// Returns `true` if the UDP handle was created with the `UV_UDP_RECVMMSG`
    /// flag and the platform supports `recvmmsg(2)`, `false` otherwise
    pub fn usingRecvmmsg(self: *const Self) bool {
        return c.uv_udp_using_recvmmsg(self.toConstUV()) == 1;
    }
    /// Stop listening for incoming datagrams
    pub fn recvStop(self: *Self) bool {
        const res = c.uv_udp_recv_stop(self.toUV());
        try check(res);
    }
};

/// UDP send request
pub const UdpSend = extern struct {
    const Self = @This();
    pub const UV = c.uv_udp_send_t;
    /// Type definition for callback passed to `send`,
    /// which is called after the data was sent
    pub const UdpSendCallback = ?fn (*Self, c_int) callconv(.C) void;
    pub const UdpSendCallbackUV = c.uv_udp_send_cb;
    data: ?*anyopaque,
    type: Req.Type,
    reserved: [6]?*anyopaque,
    handle: ?*Udp,
    cb: UdpSendCallbackUV,
    queue: [2]?*anyopaque,
    addr: c.struct_sockaddr_storage,
    nbufs: c_uint,
    bufs: [*c]Buf,
    status: isize,
    send_cb: UdpSendCallbackUV,
    bufsml: [4]Buf,
    usingnamespace Cast(Self);
    usingnamespace ReqDecls;
    /// Send data over the UDP socket
    pub fn send(
        self: Self,
        handle: *Udp,
        bufs: [*c]const Buf,
        nbufs: c_uint,
        addr: *const SockAddr,
        send_cb: UdpSendCallback,
    ) !void {
        const res = c.uv_udp_send(
            self.toUV(),
            handle.toUV(),
            bufs.toConstUV(),
            nbufs,
            addr.toConstUV(),
            @ptrCast(UdpSendCallbackUV, send_cb),
        );
        try check(res);
    }
};

/// Membership types for a multicast address
pub usingnamespace struct {
    pub const JOIN_GROUP = c.UV_JOIN_GROUP;
    pub const LEAVE_GROUP = c.UV_LEAVE_GROUP;
};
