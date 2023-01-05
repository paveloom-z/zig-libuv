const std = @import("std");

pub const c = @import("c.zig");

const @"error" = @import("error.zig");
const cast = @import("cast.zig");
const handle = @import("handle.zig");
const loop = @import("loop.zig");
const signal = @import("signal.zig");
const stream = @import("stream.zig");
const tcp = @import("tcp.zig");
const timer = @import("timer.zig");
pub const dns = @import("dns.zig");
pub const misc = @import("misc.zig");

pub const Cast = cast.Cast;
pub const Connect = stream.Connect;
pub const Error = @"error".Error;
pub const Handle = handle.Handle;
pub const HandleDecls = handle.HandleDecls;
pub const Loop = loop.Loop;
pub const Shutdown = stream.Shutdown;
pub const Signal = signal.Signal;
pub const Stream = stream.Stream;
pub const StreamDecls = stream.StreamDecls;
pub const TCP = tcp.TCP;
pub const Timer = timer.Timer;
pub const Write = stream.Write;
pub const check = @"error".check;

test {
    // Reference nested container tests
    std.testing.refAllDecls(@This());
}
