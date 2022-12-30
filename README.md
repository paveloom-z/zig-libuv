### Notices

#### Mirrors

Repository:
- [Codeberg](https://codeberg.org/paveloom-z/zig-libuv)
- [GitHub](https://github.com/paveloom-z/zig-libuv)
- [GitLab](https://gitlab.com/paveloom-g/zig/zig-libuv)

#### Prerequisites

Make sure you have installed:

- [Zig](https://ziglang.org) (`v0.10.0`)
- [Zigmod](https://github.com/nektro/zigmod)

#### Build

First, fetch the dependencies with `zigmod fetch`.

To build and install the library, run `zig build install`.

To run unit tests, run `zig build test`.

See `zig build --help` for more build options, including how to run examples.

#### Integrate

To integrate Tracy in your project:

1) Add this repository as a dependency in `zigmod.yml`:

    ```yml
    # <...>
    root_dependencies:
      - src: git https://github.com/paveloom-z/zig-libuv
    ```

2) Make sure you build the C sources in your build script:

    ```zig
    // <...>
    const deps = @import("deps.zig");
    const libuv_pkg = deps.pkgs.clap.pkg.?;
    // <...>
    pub fn build(b: *std.build.Builder) !void {
      // <...>
      // For each step
      inline for (steps) |step| {
          // Add the library package
          step.addPackage(libuv_pkg);
          // Add the dependencies
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
      // <...>
    }
    ```
