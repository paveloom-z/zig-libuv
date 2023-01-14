const std = @import("std");

const uv = @import("lib.zig");

const Buf = uv.Buf;
const Cast = uv.Cast;
const Handle = uv.Handle;
const HandleDecls = uv.HandleDecls;
const c = uv.c;
const check = uv.check;

/// Stream handle
pub const Stream = extern struct {
    const Self = @This();
    pub const UV = c.uv_stream_t;
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
};

/// Stream handle declarations
pub const StreamDecls = struct {
    pub const ConnectCallback = ?fn (*Connect, c_int) callconv(.C) void;
    pub const ConnectCallbackUV = c.uv_connect_cb;
    pub const ConnectionCallback = ?fn (*Stream, c_int) callconv(.C) void;
    pub const ConnectionCallbackUV = c.uv_connection_cb;
    pub const ReadCallback = ?fn (*Stream, isize, *const Buf) callconv(.C) void;
    pub const ReadCallbackUV = c.uv_read_cb;
    /// Start listening for incoming connections
    pub fn listen(stream: anytype, backlog: c_int, cb: ConnectionCallback) !void {
        const res = c.uv_listen(
            Stream.toUV(stream),
            backlog,
            @ptrCast(ConnectionCallbackUV, cb),
        );
        try check(res);
    }
    /// Accept incoming connections
    pub fn accept(server: anytype, client: *Stream.UV) !void {
        const res = c.uv_accept(Stream.toUV(server), client);
        try check(res);
    }
    /// Read data from an incoming stream
    pub fn readStart(
        stream: anytype,
        alloc_cb: Handle.AllocCallback,
        read_cb: ReadCallback,
    ) !void {
        const res = c.uv_read_start(
            Stream.toUV(stream),
            @ptrCast(Handle.AllocCallbackUV, alloc_cb),
            @ptrCast(ReadCallbackUV, read_cb),
        );
        try check(res);
    }
    /// Stop reading data from the stream
    pub fn readStop(stream: anytype) !void {
        const res = c.uv_read_stop(Stream.toUV(stream));
        try check(res);
    }
    /// Same as `Write.write`, but won’t queue a write
    /// request if it can’t be completed immediately
    pub fn tryWrite(handle: anytype, bufs: *const Buf, nbufs: c_uint) !c_int {
        const res = c.uv_try_write(handle.toUV(), bufs, nbufs);
        return try check(res);
    }
    /// Same as `Stream.try_write` and extended write function
    /// for sending handles over a pipe like `Write.write2`
    pub fn tryWrite2(
        handle: anytype,
        bufs: *const Buf,
        nbufs: c_uint,
        send_handle: *Handle,
    ) !c_int {
        const res = c.uv_try_write2(handle, bufs, nbufs, send_handle.toUV());
        return try check(res);
    }
    /// Returns 1 if the stream is readable, 0 otherwise
    pub fn isReadable(handle: anytype) c_int {
        return c.uv_is_readable(handle.toUV());
    }
    /// Returns 1 if the stream is writable, 0 otherwise
    pub fn isWritable(handle: anytype) c_int {
        return c.uv_is_writable(handle.toUV());
    }
    /// Enable or disable blocking mode for a stream
    pub fn setBlocking(handle: anytype, blocking: c_int) !void {
        const res = c.uv_stream_set_blocking(handle.toUV(), blocking);
        try check(res);
    }
};

/// Connect request type
pub const Connect = extern struct {
    const Self = @This();
    pub const UV = c.uv_connect_t;
    data: ?*anyopaque,
    type: c.uv_req_type,
    reserved: [6]?*anyopaque,
    cb: c.uv_connect_cb,
    handle: *Stream,
    queue: [2]?*anyopaque,
    usingnamespace Cast(Self);
};

/// Shutdown request type
pub const Shutdown = extern struct {
    const Self = @This();
    pub const UV = c.uv_shutdown_t;
    pub const ShutdownCallback = ?fn (*Self, c_int) callconv(.C) void;
    pub const ShutdownCallbackUV = c.uv_shutdown_cb;
    data: ?*anyopaque,
    type: c.uv_req_type,
    reserved: [6]?*anyopaque,
    handle: [*c]c.uv_stream_t,
    cb: c.uv_shutdown_cb,
    usingnamespace Cast(Self);
    /// Shutdown the outgoing (write) side of a duplex stream
    pub fn shutdown(req: *Self, handle: *Handle.UV, cb: ShutdownCallback) !void {
        const res = c.uv_shutdown(req.toUV(), handle, @ptrCast(ShutdownCallbackUV, cb));
        try check(res);
    }
};

/// Write request type
pub const Write = extern struct {
    const Self = @This();
    pub const UV = c.uv_write_t;
    pub const WriteCallback = ?fn (*Self, c_int) callconv(.C) void;
    pub const WriteCallbackUV = c.uv_write_cb;
    data: ?*anyopaque,
    type: c.uv_req_type,
    reserved: [6]?*anyopaque,
    cb: c.uv_write_cb,
    send_handle: [*c]c.uv_stream_t,
    handle: [*c]c.uv_stream_t,
    queue: [2]?*anyopaque,
    write_index: c_uint,
    bufs: [*c]c.uv_buf_t,
    nbufs: c_uint,
    @"error": c_int,
    bufsml: [4]c.uv_buf_t,
    usingnamespace Cast(Self);
    /// Write data to stream
    pub fn write(
        req: *Self,
        handle: *Stream,
        bufs: *const Buf,
        nbufs: c_uint,
        cb: WriteCallback,
    ) !void {
        const res = c.uv_write(
            req.toUV(),
            handle.toUV(),
            bufs.toConstUV(),
            nbufs,
            @ptrCast(WriteCallbackUV, cb),
        );
        try check(res);
    }
    /// Extended write function for sending handles over a pipe
    pub fn write2(
        req: *Self,
        handle: *Handle,
        bufs: *const Buf,
        nbufs: c_uint,
        send_handle: *Handle,
        cb: WriteCallback,
    ) !void {
        const res = c.uv_write2(
            req.toUV(),
            handle.toUV(),
            bufs.toConstUV(),
            nbufs,
            send_handle.toUV(),
            @ptrCast(WriteCallbackUV, cb),
        );
        try check(res);
    }
};
