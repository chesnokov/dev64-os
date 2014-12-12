#ifndef _BIOS_MEMINFO_H_
#define _BIOS_MEMINFO_H_

#include <kern/types.h>

/*
   Constant for region type for structure below
*/
#define MEMINFO_RAM 1

/**
  This structure contains memory information
  obtained by BIOS call 0x15 with eax=0xe820
**/
typedef struct {
  /*
    memory region start address
   */
  kuint64 start;
  /*
    memory region size
   */
  kuint64 size;
  /*
    memory region type:
    Type 1: Usable (normal) RAM
    Type 2: Reserved – unusable
    Type 3: ACPI reclaimable memory
    Type 4: ACPI NVS memory
    Type 5: Area containing bad memory
   */
  kuint32 type;
  /*
    ACPI 3.0 Extended Attributes bitfield
    (if 24 bytes are returned, instead of 20)
    Bit 0 of the Extended Attributes indicates if the entire
    entry should be ignored (if the bit is clear). This is going
    to be a huge compatibility problem because most current OSs
    won’t read this bit and won’t ignore the entry.
    Bit 1 of the Extended Attributes indicates if the entry is
    non-volatile (if the bit is set) or not. The standard states
    that “Memory reported as non-volatile may require characterization
    to determine its suitability for use as conventional RAM.”
    The remaining 30 bits of the Extended Attributes are
    currently undefined.
  */
  kuint32 acpiFlags;
} bios_meminfo_t;


#endif // _BIOS_MEMINFO_H_
