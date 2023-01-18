const std = @import("std");

const uv = @import("libuv");

const alloc = std.heap.c_allocator;
var loop: *uv.Loop = undefined;

var process: uv.Process = undefined;
var options: uv.ProcessOptions = undefined;

const stdout = std.io.getStdOut().writer();

/// A callback called on the process's exit
fn onExit(req: *uv.Process, exit_status: i64, term_signal: c_int) callconv(.C) void {
    stdout.print(
        "Process exited with status {}, signal {}\n",
        .{ exit_status, term_signal },
    ) catch {};
    req.close(null);
}

/// Run the program
pub fn main() !void {
    // Initialize the loop
    loop = try alloc.create(uv.Loop);
    defer alloc.destroy(loop);
    try uv.Loop.init(loop);
    // Prepare arguments
    var args = [_][*c]const u8{ "mkdir", "test-dir", null };
    // Set process options
    options.args = @ptrCast([*c][*c]u8, &args);
    options.exit_cb = @ptrCast(uv.Process.ExitCallbackUV, onExit);
    options.file = "mkdir";
    // Spawn a process
    try process.spawn(loop, &options);
    try stdout.print("Launched process with ID {}\n", .{process.pid});
    // Run the loop
    try loop.run(uv.RUN_DEFAULT);
    // Close the loop
    try loop.close();
}
