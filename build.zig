const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // TODO: Make this depend on the compilation target
    const sdk_path: std.Build.LazyPath = .{ .cwd_relative = "/Applications/Wolfram.app/Contents/SystemFiles/Components/StandaloneApplicationsSDK/MacOSX-ARM64/" };

    // Zig executable
    const wlr_zig_mod = b.createModule(.{
        .root_source_file = b.path("src/WolframLanguageRuntime.zig"),
        .target = target,
        .optimize = optimize,
    });

    const zig_exe = b.addExecutable(.{
        .name = "transliterate-zig",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    zig_exe.root_module.addImport("WolframLanguageRuntime", wlr_zig_mod);
    zig_exe.linkLibCpp();
    zig_exe.addLibraryPath(sdk_path);
    zig_exe.linkSystemLibrary("StandaloneApplicationsSDK");

    b.installArtifact(zig_exe);

    // C executable
    const c_exe = b.addExecutable(.{
        .name = "transliterate-c",
        .target = target,
        .optimize = optimize,
    });

    c_exe.addCSourceFile(.{ .file = b.path("src/main.c") });
    c_exe.linkLibCpp();
    c_exe.addLibraryPath(sdk_path);
    c_exe.addIncludePath(sdk_path);
    c_exe.linkSystemLibrary("StandaloneApplicationsSDK");

    b.installArtifact(c_exe);
}
