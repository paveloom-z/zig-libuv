const std = @import("std");

const uv = @import("uv");

const alloc = std.heap.c_allocator;
var loop: *uv.Loop = undefined;

var async_handle: uv.Async = undefined;

var progress: f64 = undefined;

const stdout = std.io.getStdOut().writer();

/// Print the progress
fn printProgress(handle: *uv.Async) callconv(.C) void {
    const percentage = @ptrCast(*f64, @alignCast(8, handle.data)).*;
    stdout.print("Downloaded {d:.2}%\n", .{percentage}) catch {};
}

/// Download the data
fn download(req: *uv.Work) callconv(.C) void {
    const size = @ptrCast(*i16, @alignCast(2, req.data)).*;
    // Until we download all the data
    var downloaded: i16 = 0;
    while (downloaded < size) {
        // Compute the current percentage
        var percentage =
            @intToFloat(f64, downloaded) * 100.0 /
            @intToFloat(f64, size);
        async_handle.data = @ptrCast(*anyopaque, &percentage);
        // Ask the async handler to print the progress
        async_handle.send() catch {};
        std.time.sleep(1e9);
        // Download some more
        downloaded += @mod(
            std.crypto.random.intRangeAtMost(i16, 200, 1000),
            1000,
        );
    }
}

/// Notify when done downloading the data
fn afterDownload(req: *uv.Work, status: c_int) callconv(.C) void {
    _ = req;
    _ = status;
    stdout.print("Download complete\n", .{}) catch {};
    async_handle.close(null);
}

/// Run the program
pub fn main() !void {
    // Initialize the loop
    loop = try alloc.create(uv.Loop);
    defer alloc.destroy(loop);
    try uv.Loop.init(loop);
    // Prepare data
    var req: uv.Work = undefined;
    var size: i16 = 10240;
    req.data = @ptrCast(*anyopaque, &size);
    // Start the download
    try async_handle.init(loop, printProgress);
    try req.queueWork(loop, download, afterDownload);
    // Run the loop
    try loop.run(uv.RUN_DEFAULT);
    // Close the loop
    try loop.close();
}
