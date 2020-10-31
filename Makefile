C_SOURCES = $(wildcard kernel/*.c drivers/*.c hal/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h hal/*.h include/*.h)
ASM_SOURCES_WITH_EXTERN = $(wildcard drivers/*.asm)
BOOT_SECTOR = $(wildcard boot_sect.asm)

OBJ = ${C_SOURCES:.c=.o}
OBJ2 = ${ASM_SOURCES_WITH_EXTERN:.asm=.o}
OBJ_BOOT_SECT = ${BOOT_SECTOR:.asm=.o}

symbol_file: all
	bash script.sh kernel.elf

all: ${OBJ2} kernel.bin kernel.elf kernel.sym os-image final_image

kernel.sym: kernel.elf
	objcopy --only-keep-debug $< $@

${OBJ2}: ${ASM_SOURCES_WITH_EXTERN}	# assembly files are required 
	nasm $< -f elf -o $@		#for compilation the C files 
					# -elf64 rmoved

os-image: boot_sect.bin kernel.bin
	cat $^ > os-image		# $^ = dependencies

final_image: os-image
	dd if=/dev/zero bs=1 count=2560 >> os-image

kernel.bin: kernel_entry.o ${OBJ} ${OBJ2} 
	ld -m elf_i386 $^ -Ttext 0x1000 --oformat binary -o $@ #--oformat -binary removed


kernel.elf: kernel_entry.o ${OBJ} ${OBJ2} 
	ld -m elf_i386 $^ -Ttext 0x1000 -o $@ #--oformat -binary removed

%.o : %.c ${HEADERS} 
	gcc -m32 -fno-pie -g -c $< -o $@	#-m32 added #-ffreestandin removed

%.o : %.asm
	nasm $< -f elf -o $@		# -el64 option removed
%.bin : %.asm
	nasm $< -f bin -o $@

clean:
	rm -fr *bin *.dis *.o *.elf *.sym os-image 
	rm -fr kernel/*.o boot/*.bin drivers/*.o
#disassemble out kernel , might be usefull for debugging
kernel.dis: kernel.bin
	ndisasm -b 32 $< > $@


