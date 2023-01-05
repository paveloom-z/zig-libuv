const std = @import("std");

const deps = @import("deps.zig");

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
    const timer = b.addExecutable("timer", "examples/timer.zig");
    const dns = b.addExecutable("dns", "examples/dns.zig");
    // For each example
    inline for (.{ timer, dns }) |step| {
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
    inline for (.{ lib, unit_tests, timer, dns }) |step| {
        inline for (@typeInfo(deps.package_data).Struct.decls) |decl| {
            const pkg = @field(deps.package_data, decl.name);
            // Add the include paths
            inline for (pkg.c_include_dirs) |path| {
                step.addIncludePath(@field(deps.dirs, decl.name) ++ "/" ++ path);
            }
            // Add the C source files
            inline for (pkg.c_source_files) |path| {
                step.addCSourceFile(@field(deps.dirs, decl.name) ++ "/" ++ path, pkg.c_source_flags);
            }
        }
        // Link the C library
        step.linkLibC();
        // Use the `stage1` compiler because of
        // https://github.com/ziglang/zig/issues/12325
        step.use_stage1 = true;
    }
}
