# Simplest Raspberry Pi 3 bare metal program in Zig

Not literally *the* simplest possible bare metal [Pi
3](https://www.raspberrypi.com/products/raspberry-pi-3-model-b-plus/) program in
[Zig](https://ziglang.org/), but a very simple one, and pretty well-documented.

This program will alternate the GPIO pin 16 between 0 and 1, which is good for
blinking an LED. High-tech stuff here, uh?!

I have written a blog post, [From Bare Docs to Bare
Metal](https://stackedboxes.org/2021/12/30/from-bare-docs-to-bare-metal/),
explaining some of the fundamentals of how to program the Raspberry Pi GPIO.

## How to run

Build with `zig build`, copy the resulting `zig-out/bin/kernel7.img` file to an
SD card, along with all files under `firmware`.
