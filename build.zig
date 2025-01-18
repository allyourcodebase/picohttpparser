const std = @import("std");

const c_flags = &[_][]const u8{
    "-Wall",
    // TODO(vincent): upstream uses this but it's broken when building with Zig: https://github.com/ziglang/zig/issues/11403
    // "-fsanitize=address",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("upstream", .{
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addStaticLibrary(.{
        .name = "picohttpparser",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .single_threaded = true,
    });
    lib.addCSourceFiles(.{
        .root = upstream.path("."),
        .files = &[_][]const u8{
            "picohttpparser.c",
        },
        .flags = c_flags,
    });
    lib.linkLibC();
    lib.installHeader(upstream.path("picohttpparser.h"), "picohttpparser.h");
    b.installArtifact(lib);

    // Tests

    const picotest = b.dependency("picotest", .{
        .target = target,
        .optimize = optimize,
    });

    // NOTE(vincent): because picotest is actually a submodule in the picohttpparser repository
    // the test.c program expects to find the picotest.h under the picotest directory.
    // However in our case we have picohttpparser and picotest as two distinct dependency, and
    // this "picotest" directory doesn't exist in the picotest repository.
    //
    // So, because this directory doesn't exist anywhere, I have to create it: this is what the following does.
    //
    // See the upstream documentation: https://ziglang.org/learn/build-system/#write-files

    const wf = b.addWriteFiles();
    _ = wf.addCopyFile(picotest.path("picotest.h"), "picotest/picotest.h");

    const test_bin = b.addExecutable(.{
        .name = "test-bin",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .single_threaded = true,
    });
    test_bin.linkLibrary(lib);
    test_bin.addIncludePath(upstream.path("."));
    test_bin.addIncludePath(wf.getDirectory());
    test_bin.addCSourceFiles(.{
        .root = picotest.path("."),
        .files = &[_][]const u8{
            "picotest.c",
        },
        .flags = c_flags,
    });
    test_bin.addCSourceFiles(.{
        .root = upstream.path("."),
        .files = &[_][]const u8{
            "test.c",
        },
        .flags = c_flags,
    });

    const run_tests = b.addRunArtifact(test_bin);
    run_tests.step.dependOn(&wf.step);

    const test_step = b.step("test", "Run the tests");
    test_step.dependOn(&run_tests.step);
}
