const std = @import("std");

const uv = @import("libuv");

const alloc = std.heap.c_allocator;
var loop: *uv.Loop = undefined;

var process: uv.Process = undefined;
var options: uv.ProcessOptions = undefined;

const stderr = std.io.getStdErr().writer();
const stdout = std.io.getStdOut().writer();

/// A callback to call when closing the handle
fn onClose(maybe_handle: ?*uv.Handle) callconv(.C) void {
    // If the handle is still there
    if (maybe_handle) |handle| {
        // Free the memory
        alloc.destroy(handle);
    }
}

/// A callback called on the process's exit
fn onExit(req: *uv.Process, exit_status: i64, term_signal: c_int) callconv(.C) void {
    stdout.print(
        "Process exited with status {}, signal {}\n",
        .{ exit_status, term_signal },
    ) catch {};
    var client = @ptrCast(*uv.Tcp, @alignCast(8, req.data));
    client.close(onClose);
    req.close(null);
}

/// A callback called in case the request is accepted
fn invokeCGIScript(client: *uv.Tcp) !void {
    // Prepare a path to the executable
    var exe_path = [_]u8{0} ** 100;
    _ = std.mem.replace(u8, @src().file, "cgi.zig", "tick.bash", &exe_path);
    // Prepare the arguments
    const args = [_]?[*:0]const u8{
        &exe_path,
        null,
    };
    // Set up the streams
    options.stdio_count = 3;
    var child_stdio: [3]uv.StdIOContainer = undefined;
    child_stdio[0].flags = uv.IGNORE;
    child_stdio[1].flags = uv.INHERIT_STREAM;
    child_stdio[1].data.stream = @ptrCast(*uv.Stream, client);
    child_stdio[2].flags = uv.IGNORE;
    options.stdio = &child_stdio;
    // Set up the process options
    options.args = &args;
    options.exit_cb = @ptrCast(uv.Process.ExitCallbackUV, onExit);
    options.file = args[0];
    // Spawn a process
    process.data = @ptrCast(*anyopaque, client);
    process.spawn(loop, &options) catch |err| {
        try stderr.print("Couldn't spawn a process, got {}\n", .{err});
    };
    stdout.print("Launched process with ID {}\n", .{process.pid}) catch {};
}

/// A callback in case a connection happened
fn onNewConnection(server: *uv.Stream, status: c_int) callconv(.C) void {
    // Check the status
    if (status == -1) {
        return;
    }
    // Create a client
    var client = alloc.create(uv.Tcp) catch unreachable;
    client.init(loop) catch {};
    // Accept or decline
    if (server.accept(@ptrCast(*uv.Stream, client))) |_| {
        invokeCGIScript(client) catch {};
    } else |_| {
        client.close(null);
    }
}

/// A callback to call for each handle
fn onWalk(maybe_handle: ?*uv.Handle, arg: ?*anyopaque) callconv(.C) void {
    _ = arg;
    // If the handle is still there
    if (maybe_handle) |handle| {
        // If the handle isn't being closed already
        if (!handle.isClosing()) {
            // Request to close the handle
            handle.close(null);
        }
    }
}

/// A callback in case an interrupt happened
fn onInterrupt(handle: *uv.Signal, signum: c_int) callconv(.C) void {
    _ = signum;
    // Print the message
    stderr.print("\r", .{}) catch {};
    // Try to close the loop
    loop.close() catch |err| {
        if (err == uv.Error.UV_EBUSY) {
            // Request to close each handle
            handle.loop.walk(onWalk, null);
        }
    };
}

/// Run the program
pub fn main() !void {
    // Initialize the loop
    loop = try alloc.create(uv.Loop);
    defer alloc.destroy(loop);
    try uv.Loop.init(loop);
    // Prepare a handler for the interrupt signal
    var sigint: uv.Signal = undefined;
    try sigint.init(loop);
    try sigint.start(onInterrupt, std.os.SIG.INT);
    // Prepare a server
    var server: uv.Tcp = undefined;
    try server.init(loop);
    // Bind the address
    var bind_addr_in: uv.SockAddrIn = undefined;
    try uv.ip4Addr("0.0.0.0", 7000, &bind_addr_in);
    try server.bind(bind_addr_in.asAddr(), 0);
    try server.listen(128, onNewConnection);
    // Print a help message
    try stdout.print(
        \\Try running `curl --http0.9 localhost:7000`
        \\
    ,
        .{},
    );
    // Run the loop
    try loop.run(uv.RUN_DEFAULT);
    // Close the loop
    try loop.close();
}
