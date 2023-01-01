/// Create a namespace for the casting functions
pub fn Cast(comptime T: type) type {
    // We use `anytype` in arguments here instead of `?*T` and `?*T.UV`,
    // respectively, because of an unclear error message of expecting
    // a pointer instead of an object itself, even though a pointer
    // was passed. We do, however, use `@ptrCast` and perform additional
    // checks, so it's still required to be a proper pointer
    return struct {
        /// Cast the pointer to a Zig struct to a pointer to a C struct
        pub inline fn toUV(ptr: anytype) ?*T.UV {
            if (@TypeOf(ptr) != ?*T and @TypeOf(ptr) != *T) @compileError("Wrong argument");
            return @ptrCast(?*T.UV, ptr);
        }
        /// Cast the pointer to a C struct to a pointer to a Zig struct
        pub inline fn fromUV(ptr: anytype) ?*T {
            if (@TypeOf(ptr) != ?*T.UV and @TypeOf(ptr) != *T.UV) @compileError("Wrong argument");
            return @ptrCast(?*T, ptr);
        }
    };
}
