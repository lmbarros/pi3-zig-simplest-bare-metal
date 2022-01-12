/*
 * Bare metal programming a Pi 3 in Zig.
 * By Leandro Motta Barros
 * Licensed under the MIT license. See LICENSE.txt.
 */

/*
 * The important thing I do here is defining the layout of the binary -- in
 * other words, what will appear in the final executable image and in what
 * order.
 */
SECTIONS {
	/*
	 * The Pi 3 will start executing the image from its first byte, so I need to
	 * make sure the first section of the image contains that small piece of
	 * assembly defined in `main.zig` meant to be the program entry point. There
	 * in `main.zig` we say the assembly code is on a section called
	 * `.text.boot`. Here I am just saying that we want this `.text.boot`
	 * section to be the very first thing on the image.
	 *
	 * This also says to place this section at the 0x8000 address, which is
	 * where the image will be loaded to by the Pi 3 bootloader. I think this is
	 * not necessary in this case, because this information will be lost on the
	 * final binary image. This 0x8000 address will be available on the ELF
	 * executable (check with `zig build dump-elf`), but is gone from the final
	 * binary image (check with `zig build dump-bin`). Still, I decided to keep
	 * the reference to 0x8000 here: at least it works as a sort of
	 * documentation, reminding me of where this code will be placed in the
	 * Pi 3 memory when running.
	 *
	 * Also worth noting that I don't understand these things very well. If I
	 * look at the ELF executable that is created first , `.text.boot` is not
	 * the very first section -- but I discard all bogus sections when
	 * generating the final raw image with `objcopy`).
	 */
	.text.boot 0x8000 : {
		*(.text.boot)
	}

	/*
	 * And here I am saying that all other code is to be placed right after
	 * that. "Text" is a synonym of "code", and by default all code is placed in
	 * a section called `.text`. I think this line is not really necessary. If
	 * I understand correctly, if I don't say where I want the `.text` section
	 * to be placed, the linker is free to place it wherever it wants. That'd
	 * be fine, because it doesn't matter. (I only care about the placement of
	 * the `.text.boot` section, which I dealt with above.)
	 */
	.text : {
		*(.text)
	}

	/*
	 * It's usual to also include the `.data` section in the linker script, but
	 * I decided to leave it out, since this program does not define any data,
	 * it's pure executable code.
	 *
	 * But there's one thing I do here: I discard all sections that I don't want
	 * but for some reason the compiler generates. I inspected the generated
	 * ELF found them with `zig build dump-elf` to find everything I wanted to
	 * discard.
	 */
	/DISCARD/ : {
			*(.ARM.*)
			*(.debug_*)
			*(.comment)
	}
}
