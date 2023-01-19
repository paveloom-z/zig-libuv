### Notices

#### Mirrors

Repository:
- [Codeberg](https://codeberg.org/paveloom-z/zig-libuv)
- [GitHub](https://github.com/paveloom-z/zig-libuv)
- [GitLab](https://gitlab.com/paveloom-g/zig/zig-libuv)

#### Prerequisites

Make sure you have installed:

- A development library for `libuv`
- [Zig](https://ziglang.org) (`v0.10.0`)

#### Build

To build and install the library, run `zig build install`.

To run unit tests, run `zig build test`.

See `zig build --help` for more build options, including how to run examples.

#### Integrate

To integrate the bindings into your project:

1) Add this repository as a dependency in `zigmod.yml`:

    ```yml
    # <...>
    root_dependencies:
      - src: git https://github.com/paveloom-z/zig-libuv
    ```

2) Make sure you have added the dependencies in your build script:

    ```zig
    // <...>
    const deps = @import("deps.zig");
    const uv_pkg = deps.pkgs.uv.pkg.?;
    // <...>
    pub fn build(b: *std.build.Builder) !void {
      // <...>
      // For each step
      inline for (steps) |step| {
          // Add the library package
          step.addPackage(uv_pkg);
          // Link the libraries
          step.linkLibC();
          step.linkSystemLibrary("libuv");
          // Use the `stage1` compiler because of
          // https://github.com/ziglang/zig/issues/12325
          step.use_stage1 = true;
      }
      // <...>
    }
    ```

    If you'd like a static build, take a look at the stab in the [`zigmod.yml`](zigmod.yml) file.
