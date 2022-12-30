const std = @import("std");

const deps = @import("deps.zig");

pub fn build(b: *std.build.Builder) void {
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
    // Add the dependencies
    inline for (.{ lib, unit_tests }) |step| {
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
