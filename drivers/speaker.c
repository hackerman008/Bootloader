 /* My first kernel , will call the print functiont to print string on
 * screen. *
 * */

#include "../include/stdint.h"
extern void wait(uint8_t time_sec);

void make_beep()
{
	
	uint8_t n_frequency[ ] = {222, 111, 99, 150, 130, 200, 190, 100, 50, 240};
	uint32_t div;
	
	/*write to port 0x61 to ready the speaker and port 0x43 ? */
	__asm__ __volatile__(
			"xor %eax, %eax\n\t"
			"xor %ebx, %ebx\n\t"
			"xor %ecx, %ecx\n\t"
			"xor %edx, %edx\n\t"
			"movb $0x61, %dx\n\t"
			"inb %dx, %al\n\t"
			"or $3, %al\n\t"
			"outb %al, %dx\n\t"
			"movb $0x43, %dx\n\t"
			"movb $0xB6, %al\n\t"
			"outb %al, %dx");
	
	/*write to port 0x42 the data of 16bits in LSB and MSB form*/
	for(uint8_t i=0;i<10;i++)
	{
		div = 1193180 / ((uint32_t)n_frequency[i]*2);
		__asm__ __volatile__(
			"movb $0x42, %dx");

		__asm__ __volatile__(
			"movl %0, %%eax"::"r"(div));
		__asm__ __volatile__(
			"outb %%al, %%dx\n\t"
			"shr $8, %%eax":"+r"(div)::"cc");		/*"+r" = signifies input and output at the same time. "cc" = condition codes , use it whenever doing aritmetic*/

		__asm__ __volatile__(
			"outb %al, %dx");
		wait(10);

		__asm__ __volatile__(
			"xor %eax, %eax\n\t"
			"xor %ebx, %ebx\n\t"
			"xor %ecx, %ecx\n\t"
			"xor %edx, %edx\n\t"
			"movb $0x61, %dx\n\t"
			"inb %dx, %al\n\t"
			"and $0xFC, %al\n\t"	//"FC" = 11111100b
			"outb %al, %dx");
	}	
}
