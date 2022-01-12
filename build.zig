//
// Bare metal programming a Pi 3 in Zig.
// By Leandro Motta Barros
// Licensed under the MIT license. See LICENSE.txt.
//

const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // I am creating an executable. This will generate an ELF executable, which
    // the Raspberry Pi bootloader cannot run directly. Later it will be
    // converted to something more appropriate to our needs.
    const exe = b.addExecutable("simplest", "src/main.zig");

    // I want an optimized build.
    exe.setBuildMode(std.builtin.Mode.ReleaseFast);

    // Configure the target. The target tells the compiler details about the
    // hardware and software that going to run the program.
    const target = .{
        // The Pi 3 has an ARM CPU, so I set it to `arm`. In fact, I think I
        // could have used `aarch64` here, since it is a 64-bit CPU, but using
        // it in 32-bit mode seemed simpler (because I recently did a similar
        // example in assembly using 32 bits). Worth noting that smaller devices
        // like the Raspberry Pi Pico, which feature ARM-M CPUs, must use
        // `thumb` here because they don't support the "classic" ARM instruction
        // set, only the Thumb instruction set.
        .cpu_arch = .arm,

        // Specifically, the PI 3 has a Cortex A53 CPU. I understand that this
        // will help the compiler to know, for example, which assembly
        // instructions it can use in the compiled program. Here I knew exactly
        // CPU I wanted to target, so I used it. When in doubt, I think that
        // `baseline` is a safe option representing the most basic CPU of the
        // selected architecture.
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_a53 },

        // This is a bare metal program, not using any operating system. That's
        // what `freestanding` means.
        .os_tag = .freestanding,

        // The ABI (Application Binary Interface) defines how different compiled
        // modules communicate with each other (for example, if function
        // arguments are passed on registers or on the stack). Here I am using
        // EABIHF, which is the ARM ABI that allows using floating-point
        // registers to pass arguments between functions ("HF" stands for
        // something like "hardware floats"). I am using it because the Pi 3 has
        // an FPU and therefore these registers shall be available, but this
        // program doesn't do anything with floating-point, so I could have used
        // `eabi` as well. (Worth noting: this ABI setting affects only how
        // floating point arguments are passed in function calls; it doesn't say
        // anything about the ability to use the FPU. It's OK to use `eabi` and
        // still use the FPU to do the actual calculations.)
        .abi = .eabihf,
    };

    exe.setTarget(target);

    // I need be sure that the program's entry point is placed at the very start
    // of the binary image. Additionally, I want to discard several sections
    // from the generated ELF that the compiler tries to add. I use a linker
    // script to do that. See `simplest.ld` for details.
    exe.setLinkerScriptPath(std.build.FileSource{
        .path = "simplest.ld",
    });

    // This says that the ELF executable will be copied to `zig-out/bin/` as
    // part of the `install` step. The `dump-elf` (defined below) step will need
    // this. (Not sure I understand this correctly, but here I go: if I omit
    // this line, the build system can assume that I am not interested in the
    // executable, so it will not be placed under `zig-out`.)
    exe.install();

    // With `addInstallRaw()` I tell the build system that I want to generate a
    // raw binary image from the ELF executable we generated above. This is the
    // binary the Pi 3 can run. I make this "bin generation step" a dependency
    // of the default "install step" so that it gets executed on a regular
    // `zig build`.
    const bin = b.addInstallRaw(exe, "kernel7.img", .{});
    b.getInstallStep().dependOn(&bin.step);

    // Here I add a step to disassemble the intermediate ELF executable. Handy
    // to troubleshoot issues with the  linker script. Note how I say that this
    // step depends on the `install` step. That's because the command we run
    // here expects to find the ELF executable at `zig-out/bin/`, and it is the
    // `install` step that places it there. Run with `zig build dump-elf`.
    const dumpELFCommand = b.addSystemCommand(&[_][]const u8{
        "arm-none-eabi-objdump",
        "-D",
        "-m",
        "arm",
        b.getInstallPath(.{ .custom = "bin" }, exe.out_filename),
    });
    dumpELFCommand.step.dependOn(b.getInstallStep());
    const dumpELFStep = b.step("dump-elf", "Disassemble the ELF executable");
    dumpELFStep.dependOn(&dumpELFCommand.step);

    // As above, but for disassembling the final raw binary image. Use to check
    // the final result, the code that will actually run on the Raspberry Pi.
    // Run with `zig build dump-bin`
    const dumpBinCommand = b.addSystemCommand(&[_][]const u8{
        "arm-none-eabi-objdump",
        "-D",
        "-m",
        "arm",
        "-b",
        "binary",
        b.getInstallPath(bin.dest_dir, bin.dest_filename),
    });
    dumpBinCommand.step.dependOn(&bin.step);
    const dumpBinStep = b.step("dump-bin", "Disassemble the raw binary image");
    dumpBinStep.dependOn(&dumpBinCommand.step);
}
