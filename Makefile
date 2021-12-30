#
# Bare metal programming a Pi 3 in Zig.
# By Leandro Motta Barros
# Licensed under the MIT license. See LICENSE.txt.
#

# Build in two stages. First generate an ELF with `zig build`. This ELF seems to
# contain a lot of unneeded stuff, including a lot of stuff related with
# debugging and a mysterious `.ARM.exidx` section that even appears before my
# intended initial section `.text.boot` (maybe this `.ARM.exidx` section
# https://stackoverflow.com/questions/21527256/when-is-arm-exidx-is-used ?)
#
# The Pi 3 will not load an ELF image, though, so I convert it to a "raw" binary
# image using `objcopy`. During this step I specify that I want to copy only the
# `.text.boot` and `.text` sections to the final binary. This results in a lean
# 68-byte image containing only the stuff I need.
all:
	zig build
	arm-none-eabi-objcopy -j .text.boot -j .text zig-out/bin/simplest -O binary kernel7.img


# The targets below are for inspecting (disassemblng) the binaries (either the
# ELF or the final "raw" binary image). These were very useful while I was
# trying to make the program work for the first time. For example, it took me
# some attempts until I managed to make the entry point get to the very start of
# the binary. Looking at the disassembly was great to see how my attempts were
# changing the results.
dump-elf: all
	arm-none-eabi-objdump -D zig-out/bin/simplest -m arm

dump: all
	arm-none-eabi-objdump -D -b binary -D kernel7.img -m arm


# Remove all generated stuff.
clean:
	rm -rf zig-cache zig-out kernel7.img
