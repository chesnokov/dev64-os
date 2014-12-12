include objfiles.mk

CFLAGS = -O2 -I ../include -fno-builtin -nostdinc -Wall
ASMFLAGS = -i ../include/asm/ -f elf32

.c.o: 
	$(CC) $(CFLAGS) -c -o $@ $<

obj/%.o: ../kernel/entry/x86_16/%.asm
	nasm $(ASMFLAGS) -o $@ $<

obj/%.o: ../kernel/%.asm
	nasm $(ASMFLAGS) -o $@ $<

obj/%.o: ../kernel/console/x86_32/%.asm
	nasm $(ASMFLAGS) -o $@ $<

obj/%.o: ../klib/x86_16/%.asm
	nasm $(ASMFLAGS) -o $@ $<

obj/%.o: ../klib/x86_32/%.asm
	nasm $(ASMFLAGS) -o $@ $<

obj/%.o: ../kernel/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

obj/%.o: ../klib/x86_32/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

obj/%.o: ../klib/console/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

obj/%.o: ../kernel/stack/%.asm
	nasm $(ASMFLAGS) -o $@ $<

obj/%.o: ../kernel/idt/%.asm
	nasm $(ASMFLAGS) -o $@ $<

.asm.o:
	nasm $(ASMFLAGS) -o $@ $<
	
KERNEL.MNT: $(OBJS)
	ld -M -Tlink.ld $(OBJS) -o KERNEL.MNT > kernel.map

install: KERNEL.MNT
	mount_msdosfs /dev/fd0 /mnt
	rm -f /mnt/KERNEL.MNT
	cp KERNEL.MNT /mnt
	umount /dev/fd0


asm: csrc/dbg_video.s csrc/hello.s


csrc/dbg_video.s: csrc/dbg_video.c
	(cd csrc; $(CC) -S $(CFLAGS) dbg_video.c)

start/start.o: start/start.asm
	(cd start; nasm -felf32 start.asm)

csrc/dbg_video.o: csrc/dbg_video.c
	(cd csrc; $(CC) $(CFLAGS) -c dbg_video.c)

clean:
	rm -f KERNEL.MNT $(OBJS) csrc/*.s *.map
