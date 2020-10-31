/*
 * IDT descriptor table and IDTR structures
 *
 * */

#include "../include/stdint.h"

#define MAX_INTERRUPTS	255

struct idt_descriptor
{
	uint16_t m_base_low;
	uint16_t m_segment_selector;
	uint8_t m_reserved; 	//bits(7:5) = 0, bits(4:0) = reserved
	uint8_t m_flags;
	uint16_t m_base_high;
};

struct idtr
{
	uint16_t m_limit;
	struct idt_descriptor* m_base;
}__attribute__((packed));


static struct idt_descriptor	o_idt[MAX_INTERRUPTS];
static struct idtr		*o_idtr;

