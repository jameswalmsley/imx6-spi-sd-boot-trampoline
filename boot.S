.section .boot.padding
_ivt_padding:

.section .boot.ivt
_ivt_header:
	.word	0x402000d1	/* Tag 0xd1, Len = 0x0020, Ver = 0x40 */
_ivt_app_code_jump_v:
	.word	_start
_ivt_reserved_1:
	.word 	0x0
_ivt_dcd_ptr:
	.word	0x0
_ivt_boot_data_ptr:
	.word	_ivt_boot_data
_ivt_self_ptr:
	.word	_ivt_header
_ivt_code_csf:
	.word	0x0
_ivt_reserved2:
	.word	0x0
_ivt_boot_data:
	.word	_ivt_padding
_ivt_image_len:
	.word	0x800
_ivt_plugin:
	.word 	0x0
.globl _start
_start:

#define CONFIG_SD
	/*
		Here's the boot code to push the chip into sd-card boot mode.
	*/
	mov	r3, 	#0x8000
	movt	r3,	#0x20d	// r3 == 0x020d8000
#ifdef SABRE
#ifdef CONFIG_SDHCI3
	mov	r2,	#0x3040
#else
	mov	r2, 	#0x3840
#endif
#else
#ifdef CONFIG_SD
	movw	r2,	#0x3850
#elif defined (CONFIG_EMMC)
	movw	r2,	#0x5262
#else 	// CONFIG_uSD
	movw	r2,	#0x2850
#endif
#endif
	str	r2,	[r3, #0x40]	// 0x020d8040 	= 0x3840
	mov	r2, 	#0x10000000
	str	r2,	[r3, #0x44]	// 0x020d8044	= 0x10000000
	mov 	r3, 	#0xc000
	movt	r3, 	#0x20b
	mov	r2,	#0xb2
	strh	r2,	[r3]
	ldrh	r2,	[r3]
	orr	r2, 	r2,	#4
	strh	r2, 	[r3]
	ldrh	r2,	[r3]
	orr	r2,	r2,	#8
	strh	r2,	[r3]
_loop:
	b	_loop
_end:
	.word	0x0

