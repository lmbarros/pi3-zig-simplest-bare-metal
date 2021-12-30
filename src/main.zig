const GPFSEL1 = @intToPtr(*volatile u32, 0x3F20_0004);
const GPSET0 = @intToPtr(*volatile u32, 0x3F20_001C);
const GPCLR0 = @intToPtr(*volatile u32, 0x3F20_0028);

comptime {
    asm (
        \\.section .text.boot // the linker script puts this at the start of the image
        \\.global _start
        \\_start:
        \\b simplestMain
    );
}

export fn simplestMain() noreturn {
    GPFSEL1.* = 0x0004_0000;

    var ledON = true;
    while (true) {
        if (ledON) {
            GPSET0.* = 0x0001_0000;
        } else {
            GPCLR0.* = 0x0001_0000;
        }

        var i: u32 = 2_500_000;
        while (i > 0) {
            GPFSEL1.* = 0x0004_0000;
            i -= 1;
        }

        ledON = !ledON;
    }
}
