all: copy_to_disk

copy_to_disk: stage1.bin stage2_new.bin
	sudo dd if=stage1.bin of=../../../random/hdd.img conv=notrunc
	sudo dd if=stage2_new.bin of=../../../random/hdd.img seek=1 conv=notrunc
	sudo losetup -o1048576 /dev/loop1 ../../../random/hdd.img
	sudo mkdosfs -v -F32 /dev/loop1
	sudo mount /dev/loop1 /mnt/mount_temp
	sudo cp kernel.bin /mnt/mount_temp
	sudo umount /dev/loop1
	sudo losetup -d /dev/loop1

stage1.bin: stage1.asm
	nasm $< -f bin -o $@

stage2_new.bin: stage2_new.asm
	nasm $< -f bin -o $@

clean:
	rm stage1.bin stage2.bin stage2_new.bin


