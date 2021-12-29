all:
	zig build
	arm-none-eabi-objcopy -j .text.boot -j .text zig-out/bin/simplest -O binary kernel7.img


dump:
	arm-none-eabi-objdump -b binary -D kernel7.img -m arm
