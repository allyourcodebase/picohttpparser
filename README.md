# picohttpparser

This is [picohttpparser](https://github.com/h2o/picohttpparser) packaged for [Zig](https://ziglang.org)

# zig version compatibility

* master targets Zig 0.13.0
* zig-master targets Zig master

# Installation

Use `zig fetch`:

```
zig fetch --save git+https://github.com/allyourcodebase/picohttpparser#master
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
