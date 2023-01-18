const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Add standard target options
    const target = b.standardTargetOptions(.{});
    // Add standard release options
    const mode = b.standardReleaseOptions();
    // Add the library
    const lib = b.addStaticLibrary("libuv", "src/lib.zig");
    lib.setBuildMode(mode);
    lib.install();
    // Add the unit tests
    const unit_tests_step = b.step("test", "Run the unit tests");
    const unit_tests = b.addTest("src/lib.zig");
    unit_tests.setBuildMode(mode);
    unit_tests_step.dependOn(&unit_tests.step);
    unit_tests.test_evented_io = true;
    // Define the library package
    const libuv_pkg = std.build.Pkg{
        .name = "libuv",
        .source = .{ .path = "src/lib.zig" },
        .dependencies = &.{},
    };
    // Add examples
    const detach = b.addExecutable("detach", "examples/detach.zig");
    const dns = b.addExecutable("dns", "examples/dns.zig");
    const locks = b.addExecutable("locks", "examples/locks.zig");
    const onchange = b.addExecutable("onchange", "examples/onchange.zig");
    const progress = b.addExecutable("progress", "examples/progress.zig");
    const queue_work = b.addExecutable("queue_work", "examples/queue_work.zig");
    const signal = b.addExecutable("signal", "examples/signal.zig");
    const spawn = b.addExecutable("spawn", "examples/spawn.zig");
    const thread_create = b.addExecutable("thread_create", "examples/thread_create.zig");
    const timer = b.addExecutable("timer", "examples/timer.zig");
    const uvcat = b.addExecutable("uvcat", "examples/uvcat.zig");
    const uvtee = b.addExecutable("uvtee", "examples/uvtee.zig");
    // For each example
    inline for (.{
        detach,
        dns,
        locks,
        onchange,
        progress,
        queue_work,
        signal,
        spawn,
        thread_create,
        timer,
        uvcat,
        uvtee,
    }) |step| {
        // Make sure they can be built and installed
        step.setTarget(target);
        step.setBuildMode(mode);
        step.install();
        // Add the library package
        step.addPackage(libuv_pkg);
        // Add a run step
        if (step.install_step) |install_step| {
            const run_step_name = try std.mem.concat(
                b.allocator,
                u8,
                &.{ "Run the `", step.name, "` example" },
            );
            const run_step = b.step(step.name, run_step_name);
            const run_cmd = step.run();
            run_cmd.step.dependOn(&install_step.step);
            if (b.args) |args| {
                run_cmd.addArgs(args);
            }
            run_step.dependOn(&run_cmd.step);
        }
    }
    // Add the dependencies
    inline for (.{
        detach,
        dns,
        lib,
        locks,
        onchange,
        progress,
        queue_work,
        signal,
        spawn,
        thread_create,
        timer,
        unit_tests,
        uvcat,
        uvtee,
    }) |step| {
        // Link the libraries
        step.linkLibC();
        step.linkSystemLibrary("libuv");
        // Use the `stage1` compiler because of
        // https://github.com/ziglang/zig/issues/12325
        step.use_stage1 = true;
    }
}
