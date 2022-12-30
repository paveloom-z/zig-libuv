const std = @import("std");

const c = @import("c.zig").c;

/// Base handle
pub fn Handle(comptime T: type) type {
    return struct {
        const Self = @This();
        pub const UVHandle = c.uv_handle_t;
        pub const CloseCallback = c.uv_close_cb;
        /// A specific `libuv` handle
        uv_handle: T,
        /// Cast a pointer to the specific handle
        /// to a pointer to the base handle
        pub inline fn toBase(uv_handle: *T) *UVHandle {
            return @ptrCast(*UVHandle, uv_handle);
        }
        /// Request handle to be closed
        pub fn close(self: *Self, close_cb: CloseCallback) void {
            c.uv_close(toBase(&self.uv_handle), close_cb);
        }
        /// Return `handle->data`
        pub fn get_data(self: *const Self) ?*anyopaque {
            c.uv_handle_get_data(toBase(&self.uv_handle));
        }
        /// Set `handle->data`
        pub fn set_data(self: *Self, data: ?*anyopaque) void {
            c.uv_handle_set_data(toBase(&self.uv_handle), data);
        }
    };
}
