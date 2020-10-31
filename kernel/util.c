#include "../include/stdint.h"


/* copy bytes from one place to another */
void memory_copy(char* source, char* dest, int no_bytes)
{
	int i;
	for(i=0; i<no_bytes; i++)
	{
		*(dest + i) = *(source +i);
	}
}
void make_memory_null(void* base, uint64_t limit)
{
	/*null out the whole regeion (base + limit) */
	char* tmp_base = base;
	uint32_t end = (uint32_t)tmp_base + limit -1;

	while((uint32_t)tmp_base < end)
	{
		*tmp_base =0;	// avoid (void*) dereferencing
		tmp_base++;
	}
}

/* general wait loop to supliment HLT OR MWAIT OR PAUSE instruction for the moment
 * since these instructions are privilaged instructions, we will implement a generic 
 * for loop to do nothing. */

void wait(uint8_t time_sec)
{
	time_sec = time_sec *10000000;
	for(int i=0;i<time_sec;i++)
	{
		continue;
		//asm("nop");
	}
}

