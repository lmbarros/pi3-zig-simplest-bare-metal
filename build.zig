const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();
    const target = try std.zig.CrossTarget.parse(.{
        .arch_os_abi = "arm-freestanding-none"
    });

    const exe = b.addExecutable("simplest", "src/main.zig");
    exe.setBuildMode(mode);
    exe.setTarget(target);
    exe.setLinkerScriptPath("simplest.ld");
    exe.install();
}
