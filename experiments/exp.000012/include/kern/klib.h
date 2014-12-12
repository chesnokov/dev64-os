#ifndef _KLIB_H_
#define _KLIB_H_

#include <bios/meminfo.h>

#define PHMEM_BASE 0xff800000
#define BIOS_MEMDATA 0xffc00600

/**
  This structure contains information for reserved memory blocks.
  When computer starts some memory which reported as free by BIOS
  cannot be used by different reasons. For example the first 4K
  block contain real mode interrupts and BIOS data area which
  should be leaved untouched. The OS kernel is loaded into the
  memory and this memory is also reserved.
*/
typedef struct {
  /**
    The start address of the reserved memory block
    The address is page aligned.
  */
  kuint32 start;
  /**
    The number of reserved pages
  */
  kuint32 size;
} reserved_block_t;

/// physical memory block header
typedef struct {
	int32_t next;		///< index of next phmem_frame sorted by addr
	uint32_t addr;		///< free frame address
	uint32_t size;		///< free frame size in bytes
	uint32_t reserved;
} phmem_frame;

/// free list element
typedef struct {
	int32_t next_free;	///< index of the next free_list structure. 0 means that there are no free_list after this.
	int32_t count;		///< free_list block size
	int32_t reserved[2];
} free_list;

/// root structure
typedef struct {
	/// memory information pages count
	int32_t count;
	/*!	index of the root free_list structure. Initially this
		structure initialized by phmem_init().
	*/
	int32_t next_free;
	/*!
	    next_mem index of the 1st phmem_frame block (sorted by addr).
		If next_mem is 0 then no free memory blocks available. Initially
		after phmem_init() function next_mem is 0. Free blocks are added
		later by free_frames() function. Valid index value > 0.
	*/
	int32_t next_mem;
	int32_t reserved;
} phmem_root;

/*!
	each 16-byte block may contain structure of 3 different types
	1st - phmem_root this type of block is only one
	2nd - free_list this type of structures contains list of free blocks
		that can be allocated for page_frame blocks
	3d - block for free page fram information
*/
typedef union {
	phmem_frame frame;
	free_list free;
	phmem_root root;
} phmem;

/*!
	initialize root physical memory allocation structures

	@param[in] buf - pointer to phmem_root structure

	Function initialize phmem_root structure and adds the root
	free_list structure. See comments in code for more information.
*/
void phmem_init(void * buf);

/*!
	allocate pages with summary size = size
	@param[in] ph pointer to root phmem_root structure
	@param[in] size the size of required block
*/
uint32_t alloc_pages(phmem * ph, uint32_t size);

uint32_t get_mem_available(phmem * ph);

/*!
	adds blocks of memory

	@param[in] ph - pointer to root phmem_root structure
	@param[in] addr - address of memory block to be added
	@patam[in] size - size of memory block in bytes

	@result function adds information about specified block
		into an internal list of free memory blocks.
*/
void free_pages(phmem ** ph, uint32_t addr, int32_t size);

/*!
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
                        kuint32 reserved_count);

void add_memory_block(kuint32 start, kuint32 size);

#endif
