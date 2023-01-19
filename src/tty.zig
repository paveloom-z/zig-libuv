const std = @import("std");

const uv = @import("uv.zig");

const Cast = uv.Cast;
const Connect = uv.Connect;
const File = uv.File;
const Handle = uv.Handle;
const Loop = uv.Loop;
const Shutdown = uv.Shutdown;
const Stream = uv.Stream;
const StreamDecls = uv.StreamDecls;
const c = uv.c;
const check = uv.check;

/// TTY mode types
pub usingnamespace struct {
    pub const TTY_MODE_IO = c.UV_TTY_MODE_IO;
    pub const TTY_MODE_NORMAL = c.UV_TTY_MODE_NORMAL;
    pub const TTY_MODE_RAW = c.UV_TTY_MODE_RAW;
};

/// Console virtual terminal mode types
pub usingnamespace struct {
    pub const TTY_SUPPORTED = c.UV_TTY_SUPPORTED;
    pub const TTY_UNSUPPORTED = c.UV_TTY_UNSUPPORTED;
};

/// TTY handle
pub const Tty = extern struct {
    /// TTY mode type
    pub const Mode = c.uv_tty_mode_t;
    /// Console virtual terminal mode type
    pub const VTermState = c.uv_tty_vtermstate_t;
    const Self = @This();
    pub const UV = c.uv_tty_t;
    usingnamespace Cast(Self);
    usingnamespace StreamDecls;
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
    connect_req: ?*Connect,
    shutdown_req: ?*Shutdown,
    io_watcher: c.uv__io_t,
    write_queue: [2]?*anyopaque,
    write_completed_queue: [2]?*anyopaque,
    connection_cb: Stream.ConnectionCallbackUV,
    delayed_error: c_int,
    accepted_fd: c_int,
    queued_fds: ?*anyopaque,
    orig_termios: c.struct_termios,
    mode: c_int,
    /// Initialize a new TTY stream with the given file descriptor
    pub fn init(self: *Self, loop: *Loop, fd: File, readable: c_int) !void {
        const res = c.uv_tty_init(loop.toUV(), self.toUV(), fd, readable);
        try check(res);
    }
    /// Set the TTY using the specified terminal mode
    pub fn setMode(self: *Self, mode: Self.Mode) !void {
        const res = c.uv_tty_set_mode(self.toUV(), mode);
        try check(res);
    }
    /// To be called when the program exits
    pub fn resetMode() !void {
        const res = c.uv_tty_reset_mode();
        try check(res);
    }
    /// Gets the current Window size
    pub fn getWinSize(self: *Self, width: *c_int, height: *c_int) !void {
        const res = c.uv_tty_get_winsize(self.toUV(), width, height);
        try check(res);
    }
    /// Controls whether console virtual terminal
    /// sequences are processed by `libuv` or console
    pub fn setVTermState(state: Self.VTermState) void {
        c.uv_tty_set_vterm_state(state);
    }
    /// Controls whether console virtual terminal
    /// sequences are processed by `libuv` or console
    pub fn getVTermState(state: *Self.VTermState) !void {
        const res = c.uv_tty_get_vterm_state(state);
        try check(res);
    }
};
