#include <stdio.h>
#include <stdlib.h>
#include "bios_meminfo.h"

/**
  This macro prints the contents of meminfo structure
**/
#define MEMINFO_PRINT(ptr) { \
  printf("%016I64x %016I64x %04x %04x\n", \
    ptr->start, \
    ptr->size, \
    ptr->type, \
    ptr->acpiFlags); \
    ptr++; \
}

/**
  print memory information array obtained from BIOS
**/
void printMemInfo(const bios_meminfo_t * meminfo,
                  kuint32 count) {

    int i;
    for(i=0; i<count; i++) {
      MEMINFO_PRINT(meminfo);
    }
}

/**
  This structure contains information for reserved memory blocks.
  When computer starts some memory which reported as free by BIOS
  cannot be used by different reasons. For example the first 4K
  block contain real mode interrupts and BIOS data area which
  should be leaved untouched. The OS kernel is loaded into the
  memory and this memory is also reserved.
*/
typedef struct {
  /*
    The start address of the reserved memory block
    The address is page aligned.
  */
  kuint32 start;
  /*
    The number of reserved pages
  */
  kuint32 size;
} reserved_block_t;


/*
  This structure is for compatibility with 64-bit systems. BIOS may return
  memory block outside 4G limit. Such block should be ignored in current
  version. This is done by normilizing BIOS data. If BIOS block cannot be
  as a normal memory then bios_normilized size will be 0
*/
typedef struct {
  kuint32 start;
  kuint32 size;
} bios_normalized_t;

#define MAX_UNSIGNED_ULL 0x100000000ULL

static bios_normalized_t *
  normalize_bios_block(bios_normalized_t * result,
                       const bios_meminfo_t * bios) {
  // used to check upper bound of memory block return by BIOS
  kuint64 upper_limit;
  kuint64 size;

  // by default return block that cannot be used
  result->size = 0;
  result->start = (kuint32)bios->start;

  if (bios->type == MEMINFO_RAM) {
    if(bios->start < MAX_UNSIGNED_ULL) {
      size = bios->size;
      if(bios->size > MAX_UNSIGNED_ULL) {
        size = MAX_UNSIGNED_ULL;
      }
      upper_limit = bios->start + size;
      if(upper_limit > MAX_UNSIGNED_ULL) {
        size -= (upper_limit - MAX_UNSIGNED_ULL);
      }
      result->size = size&0xFFFFF000;
    }
  }

  return result;
}

/*
 This function
*/
void add_memory_block(kuint32 start, kuint32 size) {
  printf("%08x %05x\n", start, size);
}

#define INCREMENT_ITERATOR(ptr, count) { \
   ptr++; \
   count--; \
}

#define REDUCE_BLOCK(ptr, sz) { \
   ptr->start += sz; \
   ptr->size -= sz;  \
}

/*
  This function populates page list by BIOS data. The function
  input parameters are the BIOS memory information and the array
  of reserved blocks. The output of the function are calls to
  add_memory_block() with free memory blocks to initialize the
  memory allocation structures.

  The reserved block are any arbitrary memory ranges specified by
  OS developer. It can be any ranges for example which are already
  in use (by kernel code or data).

  I use iterators ideology inside the function. Each pair of array
  element pointer + array elements count treated as an iterator.
  Increment of iterator is actually incrementing of array pointer
  and simultanious decrementing of array count.
*/
void populate_page_list(bios_meminfo_t * bios,
                        kuint32 bios_count,
                        reserved_block_t * reserved,
                        kuint32 reserved_count) {

  bios_normalized_t normalized;
  kuint32 reduce_size;

    // hasNext(bios_meminfo_t) ?
    while(bios_count > 0) {
        normalize_bios_block(&normalized, bios);
        // if BIOS block has 0 size then skip it
        if(normalized.size == 0) {
          INCREMENT_ITERATOR(bios, bios_count)
          continue;
        }
        // if no more reserved blocks that add any block
        if (reserved_count == 0) {
          add_memory_block(normalized.start, normalized.size);
          INCREMENT_ITERATOR(bios, bios_count)
          continue;
        }
        // if start of reserved is the same as bios block
        if(reserved->start==normalized.start) {
            if(reserved->size <= normalized.size) {
              REDUCE_BLOCK(bios, reserved->size)
              INCREMENT_ITERATOR(reserved, reserved_count)
              continue;
            } else {
              REDUCE_BLOCK(reserved, normalized.size)
              INCREMENT_ITERATOR(bios, bios_count)
              continue;
            }
        }
        if(reserved->start > normalized.start ) {
          if(reserved->start <= normalized.start + normalized.size) {
            reduce_size = reserved->start - normalized.start;
            add_memory_block(normalized.start, reduce_size);
            REDUCE_BLOCK(bios, reduce_size);
            continue;
          } else {
            add_memory_block(bios->start, bios->size);
            INCREMENT_ITERATOR(bios, bios_count)
            continue;
          }
        }
        if(reserved->start < normalized.start) {
           reduce_size = normalized.start - reserved->start;
           if(reserved->size > reduce_size) {
             REDUCE_BLOCK(reserved, reduce_size);
           } else {
             INCREMENT_ITERATOR(reserved, reserved_count)
           }
           continue;
        }
        add_memory_block(normalized.start, normalized.size);
        INCREMENT_ITERATOR(bios, bios_count)
    }
}

#define RESERVED_COUNT 3
#define TESTDATA_COUNT 11

int main()
{

  bios_meminfo_t meminfo[TESTDATA_COUNT] = {
    { 0x0ULL, 0x9F800ULL, 0x1, 0x1 },
    { 0x9F800ULL, 0x800ULL, 0x2, 0x1 },
    { 0xCA000ULL, 0x3000ULL, 0x2, 0x1 },
    { 0xDC000ULL, 0x24000ULL, 0x2, 0x1 },
    { 0x100000ULL, 0xFDF0000ULL, 0x1, 0x1 },
    { 0xFEF0000ULL, 0xC000ULL, 0x3, 0x1 },
    { 0xFEFC000ULL, 0x4000ULL, 0x4, 0x1 },
    { 0xFF00000ULL, 0x100000ULL, 0x1, 0x1 },
    { 0xFEC00000ULL, 0x10000ULL, 0x2, 0x1 },
    { 0xFEE00000ULL, 0x10000ULL, 0x2, 0x1 },
    { 0xFFFE0000ULL, 0x20000ULL, 0x2, 0x1 }
  };

  reserved_block_t reserved_blocks[RESERVED_COUNT]= {
    { 0, 1<<12 },
    { 0x10000, 5<<12 },
    { 0x80000, 0x400<<12 }
  };

  printMemInfo(meminfo, TESTDATA_COUNT);

  populate_page_list(meminfo, TESTDATA_COUNT,
                     reserved_blocks, RESERVED_COUNT);

  return 0;
}
