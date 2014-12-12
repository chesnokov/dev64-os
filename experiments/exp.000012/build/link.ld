OUTPUT_FORMAT("binary")
ENTRY(start)
vla = 0x10000;
SECTIONS
{
  .text16 vla : AT(0x10000) {
  *(.text16)
  . = ALIGN(0x1000);
  text-offset = . - vla;
  }
 .text 0xFFC10000 + text-offset : AT(0x10000 + text-offset){
    *(.text)
    *(.rodata)
    *(.rdata)
    . = ALIGN(0x1000);
    data-offset = . - 0xFFC10000;
  }
  .data : AT(0x10000 + data-offset) { 
    *(.data)
    . = ALIGN(0x1000);
    bss-offset = . - 0xFFC10000;
  }
    bss = .;
  .bss : AT(0x10000 + bss-offset) {
    *(.bss)
    . = ALIGN(0x1000);
  }
  end = .;
}
