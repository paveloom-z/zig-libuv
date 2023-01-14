const std = @import("std");

const uv = @import("libuv");

const alloc = std.heap.c_allocator;
var loop: *uv.Loop = undefined;

const stderr = std.io.getStdErr().writer();

/// Allocate the buffer
fn allocBuffer(
    maybe_handle: ?*uv.Handle,
    suggested_size: usize,
    maybe_buf: ?*uv.Buf,
) callconv(.C) void {
    _ = maybe_handle;
    // If the buffer is still there
    if (maybe_buf) |buf| {
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
}

/// A callback in case there is something to read from the stream
fn onRead(
    client: *uv.Stream,
    nread_isize: isize,
    buf: *const uv.Buf,
) callconv(.C) void {
    // Free the memory when done
    defer alloc.destroy(buf.base);
    // If there are no more bytes to read
    if (nread_isize < 0) {
        // If that's the end of the file
        uv.check(@intCast(c_int, nread_isize)) catch |err| {
            if (err != uv.Error.UV_EOF) {
                stderr.print("Couldn't read from the stream, got {}.\n", .{err}) catch {};
            }
        };
        // Close the stream
        client.close(null);
        // Free the memory
        alloc.destroy(client);
        return;
    }
    // Get the data
    const nread_usize = @intCast(usize, nread_isize);
    var data = alloc.alloc(u8, nread_usize + 1) catch |err| {
        stderr.print("Couldn't allocate memory for the data, got {}.\n", .{err}) catch {};
        // Close the stream
        client.close(null);
        // Free the memory
        alloc.destroy(client);
        return;
    };
    data[nread_usize] = 0;
    std.mem.copy(u8, data, buf.base[0..nread_usize]);
    stderr.print("{s}", .{data}) catch {};
    // Free the memory
    alloc.free(data);
}

/// A callback in case the TCP connection is established
fn onConnect(req: *uv.Connect, status: c_int) callconv(.C) void {
    // Free the memory when done
    defer alloc.destroy(req);
    // Prepare a writer
    // Check the status code
    uv.check(status) catch |err| {
        stderr.print("Couldn't connect, got {}.\n", .{err}) catch {};
        return;
    };
    // Try to read the data from the stream
    req.handle.readStart(allocBuffer, onRead) catch |err| {
        stderr.print("Couldn't read data from the stream, got {}.\n", .{err}) catch {};
        return;
    };
}

/// A callback in case the address is resolved
fn onResolved(
    maybe_getaddrinfo: ?*uv.GetAddrInfo,
    status: c_int,
    maybe_res: ?*uv.AddrInfo,
) callconv(.C) void {
    _ = maybe_getaddrinfo;
    // Check the status code
    uv.check(status) catch |err| {
        stderr.print("Couldn't resolve, got {}.\n", .{err}) catch {};
        return;
    };
    const res = maybe_res.?;
    defer res.free();
    // Get the IP4 address
    var addr = [_]u8{0} ** 17;
    uv.ip4Name(res.ai_addr.asIn(), addr[0..16]) catch |err| {
        stderr.print("Couldn't decode the address, got {}.\n", .{err}) catch {};
        return;
    };
    stderr.print("{s}\n", .{&addr}) catch {};
    // Make a TCP connection
    var connect_req = alloc.create(uv.Connect) catch |err| {
        stderr.print(
            "Couldn't allocate memory for the connect request, got {}.\n",
            .{err},
        ) catch {};
        return;
    };
    var socket = alloc.create(uv.Tcp) catch |err| {
        stderr.print(
            "Couldn't allocate memory for the socket, got {}.\n",
            .{err},
        ) catch {};
        return;
    };
    socket.init(loop) catch |err| {
        stderr.print("Couldn't initialize the socket, got {}.\n", .{err}) catch {};
        return;
    };
    socket.connect(connect_req, res.ai_addr, onConnect) catch |err| {
        stderr.print("Couldn't establish a connection, got {}.\n", .{err}) catch {};
        return;
    };
}

/// A callback to call when closing the handle
fn onClose(maybe_handle: ?*uv.Handle) callconv(.C) void {
    // If the handle is still there
    if (maybe_handle) |handle| {
        // Free the memory
        alloc.destroy(handle);
    }
}

/// A callback to call for each handle
fn onWalk(maybe_handle: ?*uv.Handle, arg: ?*anyopaque) callconv(.C) void {
    _ = arg;
    // If the handle is still there
    if (maybe_handle) |handle| {
        // If the handle isn't being closed alread
        if (!handle.isClosing()) {
            // Request to close the handle
            handle.close(onClose);
        }
    }
}

/// A callback in case an interrupt happened
fn onInterrupt(handle: *uv.Signal, signum: c_int) callconv(.C) void {
    _ = signum;
    // Print the message
    stderr.print("\rInterrupting...\n", .{}) catch {};
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
    var sigint = try alloc.create(uv.Signal);
    try sigint.init(loop);
    try sigint.start(onInterrupt, std.os.SIG.INT);
    // Prepare hints for the resolver
    var hints: uv.AddrInfo = undefined;
    hints.ai_family = uv.AF_INET;
    hints.ai_socktype = uv.SOCK_STREAM;
    hints.ai_protocol = uv.IPPROTO_TCP;
    hints.ai_flags = 0;
    // Resolve an address
    var resolver: uv.GetAddrInfo = undefined;
    try resolver.getaddrinfo(loop, onResolved, "irc.libera.chat", "6667", &hints);
    // Run the loop
    try loop.run(uv.RUN_DEFAULT);
    // Close the loop
    try loop.close();
}
