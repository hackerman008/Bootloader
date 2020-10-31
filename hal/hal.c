#include "hal.h"
#include "gdt.h"
#include "idt.h"

int initialize_hal()
{
	gdt_initialize();
	idt_initialize(0x8);	//code segment = 0x8
	return 0;


}

