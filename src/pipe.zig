const std = @import("std");

const uv = @import("lib.zig");

const Cast = uv.Cast;
const Connect = uv.Connect;
const File = uv.File;
const Handle = uv.Handle;
const HandleDecls = uv.HandleDecls;
const Loop = uv.Loop;
const Shutdown = uv.Shutdown;
const Stream = uv.Stream;
const StreamDecls = uv.StreamDecls;
const c = uv.c;
const check = uv.check;

/// Pipe handle
pub const Pipe = extern struct {
    const Self = @This();
    pub const UV = c.uv_pipe_t;
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
    ipc: c_int,
    pipe_fname: [*c]const u8,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    usingnamespace StreamDecls;
    /// Initialize a pipe handle
    pub fn init(self: *Self, loop: *Loop, ipc: c_int) !void {
        const res = c.uv_pipe_init(loop.toUV(), self.toUV(), ipc);
        try check(res);
    }
    /// Open an existing file descriptor or handle as a pipe
    pub fn open(self: *Self, file: File) !void {
        const res = c.uv_pipe_open(self.toUV(), file);
        try check(res);
    }
    /// Bind the pipe to a file path (Unix) or a name (Windows)
    pub fn bind(self: *Self, name: [*c]const u8) !void {
        const res = c.uv_pipe_bind(self.toUV(), name);
        try check(res);
    }
    /// Connect to the Unix domain socket or the named pipe
    pub fn connect(
        self: *Self,
        req: *Connect,
        name: [*c]const u8,
        cb: Stream.ConnectCallback,
    ) void {
        c.uv_pipe_connect(
            req,
            self.toUV(),
            name,
            @ptrCast(Stream.ConnectCallbackUV, cb),
        );
    }
    /// Get the name of the Unix domain socket or the named pipe
    pub fn getsockname(self: *Self, buffer: []u8) !void {
        const res = c.uv_pipe_getsockname(self.toUV(), buffer.ptr, buffer.len);
        try check(res);
    }
    /// Get the name of the Unix domain socket or the
    /// named pipe to which the handle is connected
    pub fn getpeername(self: *Self, buffer: []u8) !void {
        const res = c.uv_pipe_getpeername(self.toUV(), buffer.ptr, buffer.len);
        try check(res);
    }
    /// Set the number of pending pipe instance handles
    /// when the pipe server is waiting for connections
    pub fn pendingInstances(self: *Self, count: c_int) !void {
        c.uv_pipe_pending_instances(self.toUV(), count);
    }
    /// Used to receive handles over IPC pipes
    pub fn pendingCount(self: *Self) !c_int {
        return c.uv_pipe_pending_count(self.toUV());
    }
    /// Used to receive handles over IPC pipes
    pub fn pendingType(self: *Self) Handle.Type {
        return c.uv_pipe_pending_type(self.toUV());
    }
    /// Alter pipe permissions, allowing it to be accessed
    /// from processes run by different users
    pub fn chmod(self: *Self, flags: c_int) !void {
        const res = c.uv_pipe_chmod(self.toUV(), flags);
        try check(res);
    }
    /// Create a pair of connected pipe handles
    pub fn pipe(fds: [2]File, read_flags: c_int, write_flags: c_int) !void {
        const res = c.uv_pipe(&fds, read_flags, write_flags);
        try check(res);
    }
};
