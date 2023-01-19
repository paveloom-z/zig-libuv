const std = @import("std");

const uv = @import("uv.zig");

const Cast = uv.Cast;
const c = uv.c;
const check = uv.check;

/// Shared library
pub const Lib = extern struct {
    const Self = @This();
    pub const UV = c.uv_lib_t;
    handle: ?*anyopaque,
    errmsg: [*c]u8,
    usingnamespace Cast(Self);
    /// Open a shared library
    pub fn dlOpen(self: *Self, filename: [*:0]const u8) !void {
        const res = c.uv_dlopen(self.toUV(), filename);
        try check(res);
    }
    /// Close the shared library
    pub fn close(self: *Self) void {
        c.uv_dlclose(self.toUV());
    }
    /// Retrieve a data pointer from a dynamic library
    pub fn dlSym(self: *Self, name: [*:0]const u8, ptr: [*c]?*anyopaque) !void {
        const res = c.uv_dlsym(self.toUV(), name, ptr);
        try check(res);
    }
    /// Returns the last `dlopen` or `dlsym` error message
    pub fn dlError(self: *const Self) [*c]const u8 {
        return c.uv_dlerror(self.toConstUV());
    }
};
