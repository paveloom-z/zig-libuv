/// Cast the pointer to a Zig struct to a pointer to a C struct
pub inline fn toUV(comptime T: type, ptr: ?*T) ?*T.UV {
    return @ptrCast(?*T.UV, ptr);
}

/// Cast the pointer to a C struct to a pointer to a Zig struct
pub inline fn fromUV(comptime T: type, ptr: ?*T.UV) ?*T {
    return @ptrCast(?*T, ptr);
}
