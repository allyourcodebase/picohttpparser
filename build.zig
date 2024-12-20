const std = @import("std");

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
    });
    lib.addIncludePath(b.path("."));
    lib.linkLibC();
    lib.addCSourceFiles(.{
        .root = upstream.path("."),
        .files = &[_][]const u8{
            "picohttpparser.c",
        },
        .flags = &[_][]const u8{
            "-Wall", "-fsanitize=address,undefined",
        },
    });
    lib.installHeader(upstream.path("picohttpparser.h"), "picohttpparser.h");

    b.installArtifact(lib);

    // Tests

    const picotest = b.dependency("picotest", .{
        .target = target,
        .optimize = optimize,
    });

    const tests = b.addExecutable(.{
        .name = "test-bin",
        .target = target,
        .optimize = optimize,
    });
    tests.linkLibrary(lib);
    tests.addIncludePath(upstream.path("."));
    tests.addIncludePath(picotest.path("."));
    tests.addCSourceFiles(.{
        .root = picotest.path("."),
        .files = &[_][]const u8{
            "picotest.c",
        },
        .flags = &[_][]const u8{
            "-Wall", "-fsanitize=address,undefined",
        },
    });
    tests.addCSourceFiles(.{
        .root = upstream.path("."),
        .files = &[_][]const u8{
            "test.c",
        },
        .flags = &[_][]const u8{
            "-Wall", "-fsanitize=address,undefined",
        },
    });

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run the tests");
    test_step.dependOn(&run_tests.step);
}
