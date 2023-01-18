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
    // Prepare the arguments
    const args = [_]?[*:0]const u8{ "echo", "Hello there!", null };
    // Set up the streams
    options.stdio_count = 3;
    var child_stdio: [3]uv.StdIOContainer = undefined;
    child_stdio[0].flags = uv.IGNORE;
    child_stdio[1].flags = uv.INHERIT_FD;
    child_stdio[1].data.fd = 1;
    child_stdio[2].flags = uv.IGNORE;
    options.stdio = &child_stdio;
    // Set up the process options
    options.exit_cb = @ptrCast(uv.Process.ExitCallbackUV, onExit);
    options.file = args[0];
    options.args = &args;
    // Spawn a process
    try process.spawn(loop, &options);
    try stdout.print("Launched process with ID {}\n", .{process.pid});
    // Run the loop
    try loop.run(uv.RUN_DEFAULT);
    // Close the loop
    try loop.close();
}
