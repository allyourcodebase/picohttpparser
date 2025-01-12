# picohttpparser

This is [picohttpparser](https://github.com/h2o/picohttpparser) packaged for [Zig](https://ziglang.org)

# Installation

Use `zig fetch`:

```
zig fetch --save git+https://github.com/vrischmann/picohttpparser#master
```

You can then import `picohttpparser` in your `build.zig`:
```zig
const picohttpparser = b.dependency("picohttpparser", .{
    .target = target,
    .optimize = optimize,
});

your_exe.addIncludePath(picohttpparser.path("."));
your_exe.linkLibrary(picohttpparser.artifact("picohttpparser"));
```
