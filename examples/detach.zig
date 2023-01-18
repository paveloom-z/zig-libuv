const std = @import("std");

const uv = @import("libuv");

const alloc = std.heap.c_allocator;
var loop: *uv.Loop = undefined;

var process: uv.Process = undefined;
var options: uv.ProcessOptions = undefined;

const stdout = std.io.getStdOut().writer();

// The memory will inevitably be reported as lost by Valgrind

/// Run the program
pub fn main() !void {
    // Initialize the loop
    loop = try alloc.create(uv.Loop);
    defer alloc.destroy(loop);
    try uv.Loop.init(loop);
    // Prepare arguments
    const args = [_]?[*:0]const u8{ "sleep", "10", null };
    // Set process options
    options.args = &args;
    options.exit_cb = null;
    options.file = "sleep";
    options.flags = uv.PROCESS_DETACHED;
    // Spawn a process
    try process.spawn(loop, &options);
    try stdout.print("Launched process with ID {}\n", .{process.pid});
    process.unref();
    // Run the loop
    try loop.run(uv.RUN_DEFAULT);
}
