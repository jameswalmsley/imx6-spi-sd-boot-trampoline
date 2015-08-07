override TOOLCHAIN ?= arm-none-eabi-

all: boot.bin

boot.bin: boot.elf
	$(TOOLCHAIN)objcopy boot.elf -O binary $@

boot.elf: boot.o boot.lds
	$(TOOLCHAIN)gcc boot.o -nostartfiles -T boot.lds -o $@

boot.o: boot.S
	$(TOOLCHAIN)gcc -c boot.S -o $@

boot.lds: boot.lds.S
	$(TOOLCHAIN)gcc -E -P boot.lds.S -o $@

.PHONY: clean
clean:
	rm -rf boot.lds boot.o boot.elf boot.bin
 
