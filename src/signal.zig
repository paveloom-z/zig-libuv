const std = @import("std");

const uv = @import("lib.zig");

const Cast = uv.Cast;
const Handle = uv.Handle;
const HandleDecls = uv.HandleDecls;
const Loop = uv.Loop;
const c = uv.c;
const check = uv.check;

/// Signal handle
pub const Signal = extern struct {
    const Self = @This();
    pub const UV = c.uv_signal_t;
    /// Type definition for callback passed to `start`
    pub const SignalCallback = ?fn (*Self, c_int) callconv(.C) void;
    pub const SignalCallbackUV = c.uv_signal_cb;
    data: ?*anyopaque,
    loop: *Loop,
    type: c.uv_handle_type,
    close_cb: c.uv_close_cb,
    handle_queue: [2]?*anyopaque,
    u: extern union {
        fd: c_int,
        reserved: [4]?*anyopaque,
    },
    next_closing: *Handle,
    flags: c_uint,
    signal_cb: c.uv_signal_cb,
    signum: c_int,
    tree_entry: extern struct {
        rbe_left: [*c]c.struct_uv_signal_s,
        rbe_right: [*c]c.struct_uv_signal_s,
        rbe_parent: [*c]c.struct_uv_signal_s,
        rbe_color: c_int,
    },
    caught_signals: c_uint,
    dispatched_signals: c_uint,
    usingnamespace Cast(Self);
    usingnamespace HandleDecls;
    /// Initialize the handle
    pub fn init(self: *Self, loop: *Loop) !void {
        const res = c.uv_signal_init(loop.toUV(), self.toUV());
        try check(res);
    }
    /// Start the handle with the given callback, watching for the given signal
    pub fn start(self: *Self, signal_cb: SignalCallback, signum: c_int) !void {
        const res = c.uv_signal_start(
            self.toUV(),
            @ptrCast(SignalCallbackUV, signal_cb),
            signum,
        );
        try check(res);
    }
    /// Same functionality as `Self.start` but the signal
    /// handler is reset the moment the signal is received
    pub fn startOneshot(self: *Self, signal_cb: SignalCallback, signum: c_int) !void {
        const res = c.uv_signal_start_oneshot(
            self.toUV(),
            @ptrCast(SignalCallbackUV, signal_cb),
            signum,
        );
        try check(res);
    }
    /// Stop the handle, the callback will no longer be called
    pub fn stop(self: *Self) !void {
        const res = c.uv_signal_stop(self.toUV());
        try check(res);
    }
};

/// Signals
pub usingnamespace struct {
    pub const SIGABRT = c.SIGABRT;
    pub const SIGALRM = c.SIGALRM;
    pub const SIGBUS = c.SIGBUS;
    pub const SIGCHLD = c.SIGCHLD;
    pub const SIGCLD = c.SIGCLD;
    pub const SIGCONT = c.SIGCONT;
    pub const SIGFPE = c.SIGFPE;
    pub const SIGHUP = c.SIGHUP;
    pub const SIGILL = c.SIGILL;
    pub const SIGINT = c.SIGINT;
    pub const SIGIO = c.SIGIO;
    pub const SIGIOT = c.SIGIOT;
    pub const SIGKILL = c.SIGKILL;
    pub const SIGPIPE = c.SIGPIPE;
    pub const SIGPOLL = c.SIGPOLL;
    pub const SIGPROF = c.SIGPROF;
    pub const SIGPWR = c.SIGPWR;
    pub const SIGQUIT = c.SIGQUIT;
    pub const SIGSEGV = c.SIGSEGV;
    pub const SIGSTKFLT = c.SIGSTKFLT;
    pub const SIGSTOP = c.SIGSTOP;
    pub const SIGSYS = c.SIGSYS;
    pub const SIGTERM = c.SIGTERM;
    pub const SIGTRAP = c.SIGTRAP;
    pub const SIGTSTP = c.SIGTSTP;
    pub const SIGTTIN = c.SIGTTIN;
    pub const SIGTTOU = c.SIGTTOU;
    pub const SIGURG = c.SIGURG;
    pub const SIGUSR1 = c.SIGUSR1;
    pub const SIGUSR2 = c.SIGUSR2;
    pub const SIGVTALRM = c.SIGVTALRM;
    pub const SIGWINCH = c.SIGWINCH;
    pub const SIGXCPU = c.SIGXCPU;
    pub const SIGXFSZ = c.SIGXFSZ;
};
