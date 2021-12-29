const GPFSEL1: *u32 = @intToPtr(*u32, 0x3F20_0004);
const GPFSET0: *u32 = @intToPtr(*u32, 0x3F20_001C);

// comptime {
//     asm (
//         \\.global my_func;
//         \\.type my_func, @function;
//         \\my_func:
//         \\  lea (%rdi,%rsi,1),%eax
//         \\  retq
//     );
// }

comptime {
    asm(
        \\.section .text.boot // the linker script puts this at the start of the image
        \\.global _start
        \\_start:
        \\b simplestMain
    );
}

export fn simplestMain() noreturn {
    GPFSEL1.* = 0x0004_0000;
    GPFSET0.* = 0x0001_0000;

    while (true) {
        // nothing!
    }
}
