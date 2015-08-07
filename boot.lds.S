ENTRY(_start)

MEMORY
{
	FLASH (rx)	: ORIGIN = 0x90a000, LENGTH = 0x2000
}

SECTIONS
{
	.ivt : {
		KEEP(*(.boot.padding))
		. += 0x400;
		KEEP(*(.boot.ivt))
	} > FLASH
}


