const std = @import("std");

const uv = @import("libuv");

const alloc = std.heap.c_allocator;
var loop: *uv.Loop = undefined;

var open_req: uv.Fs = undefined;
var read_req: uv.Fs = undefined;
var write_req: uv.Fs = undefined;

var buffer: [1024]u8 = undefined;

var iov: uv.Buf = undefined;

const stderr = std.io.getStdErr().writer();

/// A callback on write
fn onWrite(req: *uv.Fs) callconv(.C) void {
    // Check the status
    if (req.result < 0) {
        stderr.print("Couldn't write the result.\n", .{}) catch {};
        return;
    }
    // Read some more
    read_req.read(loop, @intCast(c_int, open_req.result), &iov, 1, -1, onRead) catch |err| {
        stderr.print("Couldn't read the file, got {}.\n", .{err}) catch {};
        return;
    };
}

/// A callback on read
fn onRead(req: *uv.Fs) callconv(.C) void {
    // Check the status
    if (req.result < 0) {
        stderr.print("Couldn't read the file.\n", .{}) catch {};
        return;
    }
    // Check the status
    if (req.result == 0) {
        // Synchronously close the file
        var close_req: uv.Fs = undefined;
        close_req.close(loop, @intCast(c_int, open_req.result), null) catch |err| {
            stderr.print("Couldn't close the file, got {}.\n", .{err}) catch {};
            return;
        };
    } else {
        // Write the result to standard output
        iov.len = @intCast(usize, req.result);
        write_req.write(loop, 1, &iov, 1, -1, onWrite) catch |err| {
            stderr.print("Couldn't write the result, got {}.\n", .{err}) catch {};
            return;
        };
    }
}

/// A callback on open
fn onOpen(req: *uv.Fs) callconv(.C) void {
    // Check that the request passed to the callback is the
    // same as the one the call setup function was passed
    if (req != &open_req) {
        stderr.print("Couldn't verify the request.\n", .{}) catch {};
        return;
    }
    // Initialize the buffer
    iov = uv.Buf.init(&buffer);
    // Request to read the file
    read_req.read(loop, @intCast(c_int, req.result), &iov, 1, -1, onRead) catch |err| {
        stderr.print("Couldn't read the file, got {}.\n", .{err}) catch {};
        return;
    };
}

/// Run the program
pub fn main() !void {
    // Initialize the loop
    loop = try alloc.create(uv.Loop);
    defer alloc.destroy(loop);
    try uv.Loop.init(loop);
    // Prepare an arguments iterator
    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();
    // Skip the first argument (which is a path to the binary)
    if (args.skip()) {
        // If there is a second argument
        if (args.next()) |path| {
            // Request to open a file for reading
            _ = try open_req.open(loop, path, uv.O_RDONLY, 0, onOpen);
            // Run the loop
            try loop.run(uv.RUN_DEFAULT);
        } else {
            // Suggest the user to provide one
            try stderr.print("Please provide a path to a file.\n", .{});
        }
    }
    // Cleanup the requests
    open_req.cleanup();
    read_req.cleanup();
    write_req.cleanup();
    // Close the loop
    try loop.close();
}
