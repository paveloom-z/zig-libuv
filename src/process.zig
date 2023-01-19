const std = @import("std");

const uv = @import("uv.zig");

const Cast = uv.Cast;
const Handle = uv.Handle;
const HandleDecls = uv.HandleDecls;
const Loop = uv.Loop;
const Stream = uv.Stream;
const c = uv.c;
const check = uv.check;

/// Options for spawning the process
pub const ProcessOptions = extern struct {
    const Self = @This();
    pub const UV = c.uv_process_options_t;
    exit_cb: Process.ExitCallbackUV,
    file: [*c]const u8,
    args: [*]const ?[*:0]const u8,
    env: [*c][*c]u8,
    cwd: [*c]const u8,
    flags: c_uint,
    stdio_count: c_int,
    stdio: ?[*]StdIOContainer,
    uid: c.uv_uid_t,
    gid: c.uv_gid_t,
    usingnamespace Cast(Self);
};

/// Flags to be set on the flags field of `ProcessOptions`
pub usingnamespace struct {
    pub const PROCESS_DETACHED = c.UV_PROCESS_DETACHED;
    pub const PROCESS_SETGID = c.UV_PROCESS_SETGID;
    pub const PROCESS_SETUID = c.UV_PROCESS_SETUID;
    pub const PROCESS_WINDOWS_HIDE = c.UV_PROCESS_WINDOWS_HIDE;
    pub const PROCESS_WINDOWS_HIDE_CONSOLE = c.UV_PROCESS_WINDOWS_HIDE_CONSOLE;
    pub const PROCESS_WINDOWS_HIDE_GUI = c.UV_PROCESS_WINDOWS_HIDE_GUI;
    pub const PROCESS_WINDOWS_VERBATIM_ARGUMENTS = c.UV_PROCESS_WINDOWS_VERBATIM_ARGUMENTS;
};

/// Container for each `stdio` handle or `fd` passed to a child process
pub const StdIOContainer = extern struct {
    const Self = @This();
    pub const UV = c.uv_stdio_container_t;
    flags: c.uv_stdio_flags,
    data: extern union {
        stream: ?*Stream,
        fd: c_int,
    },
};

/// Flags specifying how a stdio should be transmitted to the child process
pub usingnamespace struct {
    pub const CREATE_PIPE = c.UV_CREATE_PIPE;
    pub const IGNORE = c.UV_IGNORE;
    pub const INHERIT_FD = c.UV_INHERIT_FD;
    pub const INHERIT_STREAM = c.UV_INHERIT_STREAM;
    pub const NONBLOCK_PIPE = c.UV_NONBLOCK_PIPE;
    pub const READABLE_PIPE = c.UV_READABLE_PIPE;
    pub const WRITABLE_PIPE = c.UV_WRITABLE_PIPE;
};

/// Process handle
pub const Process = extern struct {
    const Self = @This();
    pub const UV = c.uv_process_t;
    /// Type definition for callback passed in `ProcessOptions` which
    /// will indicate the exit status and the signal that caused
    /// the process to terminate, if any
    pub const ExitCallback = ?fn (*Self, i64, c_int) callconv(.C) void;
    pub const ExitCallbackUV = c.uv_exit_cb;
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
    exit_cb: ExitCallbackUV,
    pid: c_int,
    queue: [2]?*anyopaque,
    status: c_int,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    /// Disable inheritance for file descriptors / handles
    /// that this process inherited from its parent
    pub fn disableStdIOInheritance() void {
        c.uv_disable_stdio_inheritance();
    }
    /// Initialize the process handle and start the process
    pub fn spawn(
        self: *Self,
        loop: *Loop,
        options: *const ProcessOptions,
    ) !void {
        const res = c.uv_spawn(loop.toUV(), self.toUV(), options.toConstUV());
        try check(res);
    }
    /// Sends the specified signal to the given process handle
    pub fn processKill(self: *Self, signum: c_int) !void {
        const res = c.uv_process_kill(self.toUV(), signum);
        try check(res);
    }
    /// Sends the specified signal to the given PID
    pub fn kill(pid: c_int, signum: c_int) !void {
        const res = c.uv_kill(pid, signum);
        try check(res);
    }
};
