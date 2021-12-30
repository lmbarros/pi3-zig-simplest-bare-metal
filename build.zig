//
// Bare metal programming a Pi 3 in Zig.
// By Leandro Motta Barros
// Licensed under the MIT license. See LICENSE.txt.
//

const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // I am creating an executable. This will create an ELF file, which is not
    // what I need -- what I need is a "raw" binary image that can be directly
    // copied to the Pi 3 memory. I think the Zig compiler cannot generate a
    // binary image at the moment (I think I saw a comment in the code saying
    // this may be added in the future). So, what I do is that I added an
    // additional build step (see the `Makefile`) that converts the ELF into a
    // binary image.
    const exe = b.addExecutable("simplest", "src/main.zig");

    // I want an optimized build.
    exe.setBuildMode(std.builtin.Mode.ReleaseFast);

    // I want to target a a 32-bit ARM CPU (yes, the Pi 3 has a 64-bit CPU, but
    // I using it in 32-bit mode). The `freestanding` part says I am writing
    // bare metal code, without any perating system.
    const target = try std.zig.CrossTarget.parse(.{
        .arch_os_abi = "arm-freestanding-none"
    });
    exe.setTarget(target);

    // I need be sure that the program's entry point is placed at the very start
    // of the binary image. I use a linker script to do that. See `simplest.ld`
    // for details.
    exe.setLinkerScriptPath("simplest.ld");

    // This will build the ELF and place it on `zig-out/bin/`.
    exe.install();
}
