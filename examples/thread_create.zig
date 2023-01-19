const std = @import("std");

const uv = @import("uv");

const stdout = std.io.getStdOut().writer();

/// Go, hare!
fn hare(arg: ?*anyopaque) callconv(.C) void {
    var tracklen = @ptrCast(*usize, @alignCast(8, arg.?));
    while (tracklen.* > 0) {
        tracklen.* -= 1;
        uv.sleep(1000);
        stdout.print("Hare ran another step...\n", .{}) catch {};
    }
    stdout.print("Hare done running!\n", .{}) catch {};
}

/// Go, tortoise!
fn tortoise(arg: ?*anyopaque) callconv(.C) void {
    var tracklen = @ptrCast(*usize, @alignCast(8, arg.?));
    while (tracklen.* > 0) {
        tracklen.* -= 1;
        stdout.print("Tortoise ran another step\n", .{}) catch {};
        uv.sleep(3000);
    }
    stdout.print("Tortoise done running!\n", .{}) catch {};
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
