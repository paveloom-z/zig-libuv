const std = @import("std");

pub const c = @import("c.zig").c;

pub const Error = @import("error.zig").Error;
pub const Handle = @import("handle.zig").Handle;
pub const Loop = @import("loop.zig").Loop;
pub const Timer = @import("timer.zig").Timer;
pub const check = @import("error.zig").check;
pub const dns = @import("dns.zig");

test {
    // Reference nested container tests
    std.testing.refAllDecls(@This());
}
