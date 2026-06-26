OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    imem (rx)  : ORIGIN = 0x80000000, LENGTH = 64K
    dmem (rwx) : ORIGIN = 0x80010000, LENGTH = 10K
}

SECTIONS
{
    /* imem */
    .text : {
        *(.text)
    } > imem

    /* Read-only data, initialized variables, and zeroed data go to DMEM */
    .rodata : { *(.rodata) } > dmem
    .data   : { *(.data) } > dmem
    .bss    : { *(.bss) } > dmem
}

