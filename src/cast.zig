/// Create a namespace for the casting functions
pub fn Cast(comptime T: type) type {
    return struct {
        /// Cast the pointer to a Zig struct to a pointer to a C struct
        pub inline fn toUV(ptr: anytype) ?*T.UV {
            return @ptrCast(?*T.UV, ptr);
        }
        /// Cast the pointer to a C struct to a pointer to a Zig struct
        pub inline fn fromUV(ptr: anytype) ?*T {
            return @ptrCast(?*T, ptr);
        }
    };
}
