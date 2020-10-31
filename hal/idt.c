/*
 * -> Initialize the IDT and load the IDTR
 * -> For now the default interrupt handler will be executed everytime
 *
 * */

#include "idt.h"

extern void make_memory_null(void* address,int limit);
extern void print(const char* message); 	//for debuggind and messages
extern void clear_screen();
extern void wait(uint8_t time_sec);

void generate_interrupt(uint8_t n)
{
	int a=n;
	print("[debug] generating interupt.\n");
	wait(1);
	//asm("int %0"::"i"(a));
	asm("int $2");
}

void default_interrupt_handler()
{
	//default interrupt handler for now
	//clear_screen();
	print("[***] default interrupt: unhandled exception");
}	

void idt_install(struct idtr *o_p_idtr)
{
	//install idt 
	print("[*] loading interrupt descriptor table.\n");
	wait(1);
	//asm("lidt [o_idtr]");
	asm("lidt %0"::"m"(*o_p_idtr));
}

int idt_set_descriptor(uint32_t i, uint16_t segment_selector, uint16_t flags, void* interrupt_handler)
{
	if(i > MAX_INTERRUPTS)
		return 1;	
	if(!interrupt_handler)
		return 1;	// return non-zero if error

	// set up IDT
	uint32_t* interrupt_handler_base = ((uint32_t*)interrupt_handler);

	o_idt[i].m_base_low = (uint32_t)interrupt_handler_base & 0xffff;
	o_idt[i].m_segment_selector = segment_selector;
	o_idt[i].m_reserved = 0;	//here the lower 5 bits are reserved and upper 3 bits are 0;
	o_idt[i].m_flags = flags;
	o_idt[i].m_base_high = ((uint32_t)interrupt_handler_base >> 16) & 0xffff;

}

int idt_initialize(uint16_t code_segment_selector)
{
	print("[*] Initializing interrupt descriptor table.\n");
	wait(1);
	//setup idtr
	o_idtr->m_limit = sizeof(struct idt_descriptor) * MAX_INTERRUPTS - 1;	  
	o_idtr->m_base = &o_idt[0];
	
	//null out the whole IDT table
	make_memory_null((void*)&o_idt[0], sizeof(struct idt_descriptor)*6);
	
	// flags = 0x8e
	// setup idt with default handler
	for(int i=0;i <MAX_INTERRUPTS; i++)
	{
		idt_set_descriptor(i, code_segment_selector, 0x8e, (&default_interrupt_handler));

	}
	idt_install(o_idtr);	
	generate_interrupt(0x2);
	return 0;
}	
