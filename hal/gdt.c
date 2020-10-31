/*
 * -> Initialize GDT and GDTR 
 * -> GDT will be initialize with two descriptors , the descriptors  
 *  spanning from base 0x00000000 to 0xffffffff
 * -> both code and data will have the same base and limit.
 *
 * */
#include "../include/stdint.h"
#include "gdt.h"

extern void make_memory_null(void* address, int limit);
extern void print(const char* message);
extern void wait(uint8_t time_sec);

void gdt_set_descriptor(uint32_t i, uint32_t base, uint32_t limit, uint8_t flags1, uint8_t flags2)
{

	if(i > MAX_DESCRIPTORS)
		return;

	//null out the descriptor.
	make_memory_null((void*)&o_gdt[i], sizeof(struct gdt_descriptor));

	// set limit and base address
	o_gdt[i].m_base_low = base & 0xffff;
	o_gdt[i].m_base_mid = (base >> 16) & 0xff;
	o_gdt[i].m_base_high = (base >> 24) & 0xff;
	o_gdt[i].m_limit_low = limit & 0xffff;

	// set flags1 and flags2 and limit(16:19)
	o_gdt[i].m_flags1 = flags1;
	o_gdt[i].m_flags2 = flags2;	// contains the limit(16:19)
	

}

void gdt_install(struct gdtr *o_p_gdtr)
{
	print("[*] loading global descriptor table.\n");
	wait(1);
	// load gdtr with the gdt base
	//asm("lgdt o_gdtr");
	asm("lgdt %0"::"m"(*o_p_gdtr));
}


int gdt_initialize()
{
	print("[*] initializing global descriptor table.\n");
	wait(1);
	//setupt gdtr
	o_gdtr->m_descriptor_limit = (sizeof(struct gdt_descriptor) * MAX_DESCRIPTORS -1);
	o_gdtr->m_descriptor_base = &o_gdt[0];

	// set null descriptor
	gdt_set_descriptor(0, 0, 0, 0, 0);
	
	// set code descriptor
	gdt_set_descriptor(1, 0, 0xffffffff,
			0x9a, 0xcf);

	//set data descriptor
	gdt_set_descriptor(2, 0, 0xffffffff,
			0x92, 0xcf);
	
	gdt_install(o_gdtr);
	
	return 0;
	

}
