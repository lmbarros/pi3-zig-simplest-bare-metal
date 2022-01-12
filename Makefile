#
# Bare metal programming a Pi 3 in Zig.
# By Leandro Motta Barros
# Licensed under the MIT license. See LICENSE.txt.
#

# The targets below are for inspecting (disassemblng) the binaries (either the
# ELF or the final "raw" binary image). These were very useful while I was
# trying to make the program work for the first time. For example, it took me
# some attempts until I managed to make the entry point get to the very start of
# the binary. Looking at the disassembly was great to see how my attempts were
# changing the results.
#
# I eventually intend to move those to Zig's build system.
dump-elf: all
	arm-none-eabi-objdump -D zig-out/bin/simplest -m arm

dump: all
	arm-none-eabi-objdump -D -b binary -D kernel7.img -m arm


# Remove all generated stuff.
clean:
	rm -rf zig-cache zig-out kernel7.img
