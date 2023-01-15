const std = @import("std");

const uv = @import("libuv");

const stderr = std.io.getStdErr().writer();

/// Go, hare!
fn hare(arg: ?*anyopaque) callconv(.C) void {
    var tracklen = @ptrCast(*usize, @alignCast(8, arg.?));
    while (tracklen.* > 0) {
        tracklen.* -= 1;
        uv.sleep(1000);
        stderr.print("Hare ran another step...\n", .{}) catch {};
    }
    stderr.print("Hare done running!\n", .{}) catch {};
}

/// Go, tortoise!
fn tortoise(arg: ?*anyopaque) callconv(.C) void {
    var tracklen = @ptrCast(*usize, @alignCast(8, arg.?));
    while (tracklen.* > 0) {
        tracklen.* -= 1;
        stderr.print("Tortoise ran another step\n", .{}) catch {};
        uv.sleep(3000);
    }
    stderr.print("Tortoise done running!\n", .{}) catch {};
}

/// Run the program
pub fn main() !void {
    // Prepare a track
    var tracklen: usize = 10;
    var hare_id: uv.Thread = undefined;
    var tortoise_id: uv.Thread = undefined;
    // Run!
    try hare_id.create(hare, &tracklen);
    try tortoise_id.create(tortoise, &tracklen);
    // Wait for the finish of this totally fair race
    try hare_id.join();
    try tortoise_id.join();
}
