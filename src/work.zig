const std = @import("std");

const uv = @import("lib.zig");

const Cast = uv.Cast;
const Loop = uv.Loop;
const Req = uv.Req;
const ReqDecls = uv.ReqDecls;
const c = uv.c;
const check = uv.check;

/// Work request
pub const Work = extern struct {
    const Self = @This();
    pub const UV = c.uv_work_t;
    /// Callback passed to `queueWork` which will be run on the thread pool
    pub const WorkCallback = ?fn (*Self) callconv(.C) void;
    pub const WorkCallbackUV = c.uv_work_cb;
    /// Callback passed to `queueWork` which will be called on the loop
    /// thread after the work on the threadpool has been completed
    pub const AfterWorkCallback = ?fn (*Self, c_int) callconv(.C) void;
    pub const AfterWorkCallbackUV = c.uv_after_work_cb;
    data: ?*anyopaque,
    type: Req.Type,
    reserved: [6]?*anyopaque,
    loop: ?*Loop,
    work_cb: WorkCallbackUV,
    after_work_cb: AfterWorkCallbackUV,
    work_req: c.struct_uv__work,
    usingnamespace Cast(Self);
    usingnamespace ReqDecls;
    /// Initializes a work request which will run the
    /// given `work_cb` in a thread from the threadpool
    pub fn queueWork(self: *Self, loop: *Loop, work_cb: WorkCallback, after_work_cb: AfterWorkCallback) !void {
        const res = c.uv_queue_work(
            loop.toUV(),
            self.toUV(),
            @ptrCast(WorkCallbackUV, work_cb),
            @ptrCast(AfterWorkCallbackUV, after_work_cb),
        );
        try check(res);
    }
};
