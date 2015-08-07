# IMX6 Boot Trampoline

The code in boot.S is a tiny nano boot-loader that causes the iMX.6
processor to reset itself in SD-Card boot mode, so that the main 
boot-loader can be loaded from the another SD-card / uSD card.

## Boot Process overview.

Many imx6 boards are shipped with an spi flash pre-programmed with
something like u-boot.

In order to make the imx6 boot from the spi flash on POR (power-on-reset)
the manufacturer as blown some fuses (the eFUSEs - see HRM (hardware ref manual).

This means that the device always boots from SPI flash, and this can be
inconvenient during development, and even production.

This simple boot-loader can be stored into the SPI flash to cause the imx6 to reboot
but load the main boot-loader from an SD-Card instead.

To do this, it sets the registers at:

    0x020d8040 <= (SD 0x3840) (uSD 0x3040)                ; // The bit-pattern seems to be undocumented. (Typical Sabrelite board)
    0x020d8040 <= (SD 0x3850) (uSD 0x2850) (eMMC 0x5262)  ; // (Congatex QMX-6 board).
    0x020d8044 <= 0x10000000                              ; // Signals a persistent boot.

It then causes a system warm reset, i.e. not POR, which causes the boot rom
to read the values in these registers as arguments to the boot flow.

So far I didn't manage to find any real documentation on the meaning of these
bits. Maybe I should read more carefully.


## Building the boot image

    make

## Flash the SPI flash using u-boot:

Copy the boot image onto an sd-card or other medium usable by u-boot:

    dd if=boot.bin of=/dev/sdc

Note this operation overwrites the MBR of the sd-card, ensure you backup anything important.

Now insert the SD-Card into a slot.

    # Replace 0 with the correct ID for your sd-slot.
    mmc dev 0
    mmc read 0x10800000 0 200

Flash the spi:

    sf probe 1
    # Note the next command erases any current boot-loader.
    sf erase 0 0x40000
    sf write 0x10800000 0 0x40000

## Make a bootable SD-Card.

You should find out if your u-boot image is padded:

    arm-none-eabi-objdump -b binary -D u-boot.bin -marm | more

You'll see output like:

    u-boot.bin:     file format binary
    
    
    Disassembly of section .data:
    
    00000000 <.data>:
           0:       ea0001be        b       0x700
            ...
         400:       402000d1        ldrdmi  r0, [r0], -r1   ; <UNPREDICTABLE>
         404:       27800700        strcs   r0, [r0, r0, lsl #14]
         408:       00000000        andeq   r0, r0, r0
         40c:       2780042c        strcs   r0, [r0, ip, lsr #8]
         410:       27800420        strcs   r0, [r0, r0, lsr #8]
         414:       27800400        strcs   r0, [r0, r0, lsl #8]
    

If the value 0x402000d1 (as seen at address 0x400) is at 0x0 then your image is not padded.

    dd if=u-boot.bin of=/dev/sdc bs=512 skip=2 seek=2     # Padded image
    dd if=u-boot.bin of=/dev/sdc bs=512 skip=0 seek=2     # Non-padded image


