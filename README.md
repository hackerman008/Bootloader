# Basic Bootloader
NOTE: still in development

![Alt text](basic_operating_system_screenshot.png?raw=true "OS image")

## FEATURES
1. 2 stage bootloader to load files from FAT32 file system
2. Fat32 file system
3. Screen driver


## REQUIREMENTS
1. Qemu
2. make

## BUILD
1. run make
2. run "xhost +"
3. run sudo qemu-system-x86_64 hdd.img
