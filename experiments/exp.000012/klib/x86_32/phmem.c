// memtest.cpp : Defines the entry point for the console application.
//

#ifdef _WIN32
#include "stdafx.h"
#include <malloc.h>
#include <memory.h>
#include "stdint.h"
#else
    #include <kern/types.h>
    #include <kern/klib.h>
#endif

#define BLOCK_SIZE 4096

extern uint32_t mm_entry_count;

/**
 This is callback function
*/
void add_memory_block(kuint32 start, kuint32 size) {
    phmem * ph = (phmem *)PHMEM_BASE;
    free_pages(&ph, start, size);
}


uint32_t init_phys_memory_allocation() {
    phmem * ph = (phmem *)PHMEM_BASE;
    phmem_init(ph);
    reserved_block_t reserved_blocks[1]= {
      { 0, 0x100000 }
    };
    populate_page_list((bios_meminfo_t *)BIOS_MEMDATA, mm_entry_count,
                     reserved_blocks, 1);
    return get_mem_available(ph);
}

/*!
	initialize root physical memory allocation structures

	@param[in] buf - pointer to phmem_root structure

	Function initialize phmem_root structure and adds the root
	free_list structure. See comments in code for more information.
*/
void phmem_init(void * buf) {
	phmem * ph = (phmem *)buf;
	ph->root.count = 1;			// page count used to store physical memory information
	ph->root.next_free = 1;		// index of the first free_list structure
	ph->root.next_mem = 0;

	// initialize free_list structure
	ph +=1;
	ph->free.count = 255; // 4096/16 - 1
	ph->free.next_free = 0; // no free blocks any more
}

/*
	allocate pages with summary size = size
	@param[in] ph pointer to root phmem_root structure
	@param[in] size the size of required block
*/
uint32_t alloc_pages(phmem * ph, uint32_t size) {
	phmem * frame = ph + ph->root.next_mem;
	phmem * prev_frame = frame;
	uint32_t addr;

	if(ph->root.next_mem == 0)
		return 0;

	while(frame->frame.size < size) {
		if(frame->frame.next != 0) {
			prev_frame = frame;
			frame = ph + frame->frame.next;
		} else {
			// no blocks with enougth size found
			return 0;
		}
	}
	if(frame->frame.size == size) {
		if(prev_frame != frame) {
			prev_frame->frame.next = frame->frame.next;
		} else {
			// first frame
			ph->root.next_mem = frame->frame.next;
		}
		return frame->frame.addr;
	}
	// frame->frame.next > size
	addr = frame->frame.addr;
	frame->frame.addr += size;
	frame->frame.size -= size;
	return addr;
}

uint32_t get_mem_available(phmem * ph) {

	phmem * frame = ph + ph->root.next_mem;
	uint32_t size = 0;

	if(ph->root.next_mem == 0)
		return 0;

	for(;;) {
		size += frame->frame.size;
		if(frame->frame.next == 0) {
			return size;
		} else {
			frame = ph + frame->frame.next;
		}
	}
}

/*!
	find empty element to store phmem_frame structure
	@warning no error assumed when realloc used.

	@param[in,out] ph pointer to root phmem_root structure
	@return pointer to phmem_frame item

*/
static phmem * find_empty_block(phmem ** ph) {
	phmem * upd;

	if ((*ph)->root.next_free != 0) {
		phmem * empty = (*ph) + (*ph)->root.next_free;
		if(empty->free.count > 1) {
			// reduce empty block by 1
			// move empty block forward
			phmem * upd = empty + 1;
			upd->free.count = empty->free.count - 1;
			upd->free.next_free = empty->free.next_free;

			(*ph)->root.next_free = upd - (*ph);
			return empty;

		} else {
			(*ph)->root.next_free = empty->free.next_free;
			return empty;
		}
	} else { // ph->root.next_free == 0
		// allocate additional space
		(*ph)->root.count++;
#ifdef _WIN32
		*ph = (phmem *)realloc(*ph, (*ph)->root.count * 0x1000);
#endif

		upd = (*ph) + ((*ph)->root.count - 1 ) * 256;
		upd++;
		upd->free.count = 255;
		upd->free.next_free = 0;
		upd--;
		return upd;
	}

}

/*!
	adds blocks of memory

	@param[in] ph - pointer to root phmem_root structure
	@param[in] addr - address of memory block to be added
	@patam[in] size - size of memory block in bytes

	@result function adds information about specified block
		into an internal list of free memory blocks.
*/
void free_pages(phmem ** ph, uint32_t addr, int32_t size) {
	// check if no blocks yet
	if((*ph)->root.next_mem == 0 ) {
		phmem * frame = find_empty_block(ph);
		frame->frame.addr = addr;
		frame->frame.size = size;
		frame->frame.next = 0;		// no next frame yet

		// update root
		//ph->root.next_free = free - ph;
		(*ph)->root.next_mem = frame - (*ph);
		//add_first_block(ph, addr, size);
		return;
	} else {
		// find block where new block to be inserted
		phmem * frame = (*ph) + (*ph)->root.next_mem;
		phmem * prev_frame = frame;
		while(frame->frame.addr < addr) {
			prev_frame = frame;
			if (frame->frame.next == 0) {
				break;
			}
			frame = (*ph) + frame->frame.next;
		}
		// we have found frame with frame.addr > addr
		// or frame is only frame so prev = frame...
		if(prev_frame->frame.addr < addr) {
			if (frame->frame.addr < addr) {
				// prev < addr && frame < addr
				if(prev_frame->frame.addr + prev_frame->frame.size == addr) {
					// update prev_frame
					prev_frame->frame.size += size;
					return;
				} else {
					// add frame after prev
					phmem * update = find_empty_block(ph);
					update->frame.addr = addr;
					update->frame.size = size;
					update->frame.next = prev_frame->frame.next;
					prev_frame->frame.next = update - (*ph);
					return;
				}

			} else { // frame->frame.addr > addr
				// block between prev_frame and frame
				if(prev_frame->frame.addr + prev_frame->frame.size == addr) {
					// update size of prev frame
					prev_frame->frame.size += size;
					if (prev_frame->frame.addr + prev_frame->frame.size == frame->frame.addr) {
						// link prev frame and frame
						prev_frame->frame.size += frame->frame.size;
						prev_frame->frame.next = frame->frame.next;
						// place frame element in a list of free elements
						frame->free.next_free = (*ph)->root.next_free;
						(*ph)->root.next_free = frame - (*ph);
						frame->free.count = 1;
					}
					return;
				} else { // insert frame between prev and frame
					phmem * update = find_empty_block(ph);
					update->frame.addr = addr;
					update->frame.size = size;
					update->frame.next = frame - (*ph);
					prev_frame->frame.next = update - (*ph);
					return;
				}

			}
		} else { // prev_frame->frame.addr > addr
				if(prev_frame->frame.addr == addr + size) {
					// increment size of the prev_frame
					// update start address of prev frame
					// update prev_frame
					prev_frame->frame.addr = addr;
					prev_frame->frame.size += size;
					return;
				} else {
					// insert before 1st block
					// update root record
					phmem * update = find_empty_block(ph);
					update->frame.addr = addr;
					update->frame.size = size;
					update->frame.next = prev_frame - (*ph);
					(*ph)->root.next_mem = update - (*ph);
					return;
				}
		}

	}
}


#ifdef _WIN32

void save_meminfo(const phmem * cntl) {
	// save memory blocks to file
	FILE * out = fopen("d:\\tmp\\memory.out", "wb+");
	fwrite(cntl, cntl->root.count*0x1000, 1, out);
	fclose(out);
}


int _tmain(int argc, _TCHAR* argv[])
{
	// allocate block
	char * buf = (char *)malloc(BLOCK_SIZE);
	phmem * root = (phmem *)buf;
	uint32_t size;
	uint32_t addr1;

	memset(buf, 0xa, BLOCK_SIZE);

	phmem_init(buf);
//	free_pages(&root, 0x480000, 0xfa70000);
	free_pages(&root, 0x480000, 0x1000);
	free_pages(&root, 0x3000,0x1000);
	free_pages(&root, 0x1000,0x1000);
	free_pages(&root, 0x2000,0x1000);   // 0x1000 - 0x3000
	free_pages(&root, 0x5000,0x1000);
	free_pages(&root, 0x6000,0x1000);
	free_pages(&root, 0x490000,0x1000);
//	free_pages(&root, 0x4000,0x1000);
//	free_frames(root, 0x10000, 0x1000);
//	free_frames(root, 0xf000, 0x1000);


	size = get_mem_available(root);
	printf("size=%x\n", size);

	addr1 = alloc_pages(root, 0x3000);
	printf("addr=%x\n", addr1);
//	uint32_t addr = alloc_pages(root, 0x400000);


//	free_pages(&root, addr, 0x400000);
//	free_pages(&root, addr1, 0x1000);

//	size = get_mem_available(root);
//	printf("size=%d\n", size);

	//add_block(root, 0x15000, 0x6b000);


//	add_block(root, 0xff00000, 0x100000);

	save_meminfo(root);
	return 0;
}

#endif
