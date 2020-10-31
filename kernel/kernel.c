 
/* My first kernel , will call the print functiont to print string on
 * screen. *
 * */

#include "../include/stdint.h"

extern void print(const char* message);
extern void clear_screen();
extern int initialize_hal();
extern void wait(uint8_t time_sec);
extern void make_beep();

void main()
{
	

	clear_screen(); 
	make_beep();
	const char* message1 = "[*] Drivers loaded.\n";
	const char* message2 = "[*] Inside kernel\n";
	const char* message3 = "[*] Initializing HAL.\n";
	print(message1);
	print(message2);

	//initilaizing  HAL	
	print(message3);
	initialize_hal();
	for(;;);
	
}
