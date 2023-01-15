const std = @import("std");

const uv = @import("libuv");

const alloc = std.heap.c_allocator;
var loop: *uv.Loop = undefined;

var stdin_pipe: uv.Pipe = undefined;
var stdout_pipe: uv.Pipe = undefined;
var file_pipe: uv.Pipe = undefined;

const stderr = std.io.getStdErr().writer();
const stdout = std.io.getStdOut().writer();

/// A wrapper around the write request
///
/// We use it to pass the buffer around
const WriteReq = struct {
    req: uv.Write,
    buf: uv.Buf,
};

/// Allocate a buffer
fn allocBuffer(handle: ?*uv.Handle, suggested_size: usize, buf: *uv.Buf) callconv(.C) void {
    _ = handle;
    // Allocate the data
    const maybe_data = alloc.alloc(u8, suggested_size) catch null;
    // If that's successful
    if (maybe_data) |data| {
        buf.base = data.ptr;
        buf.len = data.len;
    } else {
        buf.base = null;
        buf.len = 0;
    }
}

/// Free the write request
fn freeWriteReq(req: *uv.Write) void {
    // Cast back to the wrapper
    const wr = @ptrCast(*WriteReq, req);
    // Free the memory
    alloc.free(wr.buf.base[0..wr.buf.len]);
    alloc.destroy(wr);
}

/// A callback on `stdout` write
fn onStdoutWrite(req: *uv.Write, status: c_int) callconv(.C) void {
    _ = status;
    freeWriteReq(req);
}

/// A callback on file write
fn onFileWrite(req: *uv.Write, status: c_int) callconv(.C) void {
    _ = status;
    freeWriteReq(req);
}

/// Write data
fn writeData(dest: *uv.Pipe, size: usize, buf: uv.Buf, cb: uv.Write.WriteCallback) void {
    // Prepare a request
    var wr_req = alloc.create(WriteReq) catch |err| {
        stderr.print(
            "Couldn't allocate memory for the write request, got {}.\n",
            .{err},
        ) catch {};
        return;
    };
    // Copy the buffer into the request
    var data = alloc.alloc(u8, size) catch |err| {
        stderr.print(
            "Couldn't allocate memory for a buffer copy, got {}.\n",
            .{err},
        ) catch {};
        return;
    };
    std.mem.copy(u8, data, buf.base[0..size]);
    wr_req.buf = uv.Buf{
        .base = data.ptr,
        .len = data.len,
    };
    // Request to write to the stream
    var wr = @ptrCast(*uv.Write, wr_req);
    wr.write(@ptrCast(*uv.Stream, dest), &wr_req.buf, 1, cb) catch |err| {
        stderr.print(
            "Couldn't write to the stream, got {}.\n",
            .{err},
        ) catch {};
        return;
    };
}

/// A callback on reading `stdin`
fn readStdin(stream: *uv.Stream, nread: isize, buf: *const uv.Buf) callconv(.C) void {
    _ = stream;
    // Check the status
    if (nread < 0) {
        // If that's the end of the file
        uv.check(@intCast(c_int, nread)) catch |err| {
            if (err != uv.Error.UV_EOF) {
                // Close the pipes
                stdin_pipe.close(null);
                stdout_pipe.close(null);
                file_pipe.close(null);
            }
        };
    } else if (nread > 0) {
        writeData(&stdout_pipe, @intCast(usize, nread), buf.*, onStdoutWrite);
        writeData(&file_pipe, @intCast(usize, nread), buf.*, onFileWrite);
    }
    // Free the buffer (that's okay since we copy it)
    if (buf.base != null)
        alloc.free(buf.base[0..buf.len]);
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
    // Prepare an arguments iterator
    var args = try std.process.argsWithAllocator(alloc);
    defer args.deinit();
    // Skip the first argument (which is a path to the binary)
    if (args.skip()) {
        // If there is a second argument
        if (args.next()) |path| {
            // Prepare a handler for the interrupt signal
            var sigint = try alloc.create(uv.Signal);
            try sigint.init(loop);
            try sigint.start(onInterrupt, std.os.SIG.INT);
            defer alloc.destroy(sigint);
            // Open the `stdin` pipe
            try stdin_pipe.init(loop, 0);
            try stdin_pipe.open(0);
            // Open the `stdout` pipe
            try stdout_pipe.init(loop, 0);
            try stdout_pipe.open(1);
            // Synchronously open a file for writing
            var file_req: uv.Fs = undefined;
            const fd = try file_req.open(
                loop,
                path,
                uv.O_CREAT | uv.O_RDWR | uv.O_TRUNC,
                0o644,
                null,
            );
            try file_pipe.init(loop, 0);
            try file_pipe.open(fd);
            // Start reading from `stdin`
            try stdin_pipe.readStart(allocBuffer, readStdin);
            // Run the loop
            try loop.run(uv.RUN_DEFAULT);
        } else {
            // Suggest the user to provide one
            try stderr.print(
                \\Please provide a path to a file.
                \\
                \\Note that the file will be created, and everything you type
                \\will be redirected to this file and to the standard output.
                \\
            ,
                .{},
            );
        }
    }
    // Close the loop
    try loop.close();
}
