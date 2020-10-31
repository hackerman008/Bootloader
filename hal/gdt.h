/*
 * m_ - member
 * o_ - object
 *
 * */
#include "../include/stdint.h"
#define MAX_DESCRIPTORS	3


struct gdt_descriptor
{
	uint16_t m_limit_low;	// limit(0:15)
	uint16_t m_base_low;
	uint8_t m_base_mid;
	uint8_t m_flags1;	//[ P | DPL | S | TYPE ]
	uint8_t m_flags2;	//[ G | D/B | L | AVL | limit(19:16)]
	uint8_t m_base_high;

};

struct gdtr
{
	uint16_t m_descriptor_limit;
	struct gdt_descriptor* m_descriptor_base;	

}__attribute__((packed));

static struct gdt_descriptor	o_gdt[MAX_DESCRIPTORS];
static struct gdtr	*o_gdtr; //changed

