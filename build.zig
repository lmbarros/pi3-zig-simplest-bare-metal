const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const exe = b.addExecutable("simplest", "src/main.zig");
    exe.setBuildMode(std.builtin.Mode.ReleaseFast);
    const target = try std.zig.CrossTarget.parse(.{
        .arch_os_abi = "arm-freestanding-none"
    });
    exe.setTarget(target);
    exe.setLinkerScriptPath("simplest.ld");
    exe.install();
}
