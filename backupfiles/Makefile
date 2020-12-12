symbol_file: all

C_SOURCES = $(wildcard kernel/*.c drivers/*.c hal/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h hal/*.h include/*.h)
ASM_SOURCES_WITH_EXTERN = $(wildcard drivers/*.asm)
BOOTLOADER = ${wildcard bootloader/stage1.asm bootloader/stage2_new.asm}

OBJ = ${C_SOURCES:.c=.o}
OBJ2 = ${ASM_SOURCES_WITH_EXTERN:.asm=.o}
OBJ3 = ${BOOTLOADER:.asm=.bin}

all: copy_to_disk
	bash script.sh kernel.elf

copy_to_disk: ${OBJ3} ${OBJ2} kernel.bin kernel.elf kernel.sym
	sudo dd if=bootloader/stage1.bin of=../../random/hdd.img conv=notrunc
	sudo dd if=bootloader/stage2_new.bin of=../../random/hdd.img seek=1 conv=notrunc
	sudo losetup -o1048576 /dev/loop1 ../../random/hdd.img
	sudo mkdosfs -v -F32 /dev/loop1
	sudo mount /dev/loop1 /mnt/mount_temp
	sudo cp kernel.bin /mnt/mount_temp
	sudo umount /dev/loop1
	sudo losetup -d /dev/loop1


${OBJ2}: ${ASM_SOURCES_WITH_EXTERN}				# assembly files are required 
	nasm $< -f elf -o $@					# for compilation the C files

kernel.bin: kernel_entry.o ${OBJ} ${OBJ2} 
	ld -m elf_i386 $^ -Ttext 0x1000 --oformat binary -o $@ 	

kernel.elf: kernel_entry.o ${OBJ} ${OBJ2} 
	ld -m elf_i386 $^ -Ttext 0x1000 -o $@ 			

kernel.sym: kernel.elf
	objcopy --only-keep-debug $< $@

%.o : %.c ${HEADERS} 
	gcc -m32 -fno-pie -g -c $< -o $@			#-m32 & -fno-pie added 

%.o : %.asm
	nasm $< -f elf -o $@	

%.bin : %.asm
	nasm $< -f bin -o $@

#disassemble out kernel , might be usefull for debugging
kernel.dis: kernel.bin
	ndisasm -b 32 $< > $@


clean:
	rm -fr *bin *.dis *.o *.elf *.sym os-image 
	rm -fr kernel/*.o boot/*.bin bootloader/*.bin drivers/*.o




