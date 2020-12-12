/*
	print a char on the screen at col, row, or at curson position 
 */


#include "screen.h"

extern unsigned char port_byte_in(unsigned short port);
extern void port_byte_out(unsigned short port, unsigned char data);
extern void memory_copy(char* dest, char* source, int no_bytes);

int get_screen_offset(int col, int row)
{
	int offset = (row * 80 + col)*2;	// gives the offset derived from row and
				// column
	/* use offset to set the cursor to that place
	  returnt the offset*/
	port_byte_out(REG_SCREEN_CTRL, 14);
	port_byte_out(REG_SCREEN_DATA,(unsigned char)(offset >> 8));
	port_byte_out(REG_SCREEN_CTRL, 15);
	port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset & 0b0000000011111111));


	return offset;
}

int get_cursor()
{
	port_byte_out(REG_SCREEN_CTRL, 14);
	int offset = port_byte_in(REG_SCREEN_DATA) << 8;
	port_byte_out(REG_SCREEN_CTRL, 15);
	offset += port_byte_in(REG_SCREEN_DATA);
	 
	return offset*2;
}

void set_cursor(int offset)
{
	offset /= 2;
	port_byte_out(REG_SCREEN_CTRL, 14);
	port_byte_out(REG_SCREEN_DATA,(unsigned char)(offset >> 8));
	port_byte_out(REG_SCREEN_CTRL, 15);
	port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset & 0b0000000011111111));

}




int handle_scrolling(int cursor_offset)
{
	if(cursor_offset < MAX_ROWS*MAX_COLS*2)
	{
		return cursor_offset;
	}

	/* copy line to the previous line to give an illusion of 
	 * scrolling*/
	int i;
	for(i=1; i< MAX_ROWS; i++)
	{
		memory_copy((char*)(get_screen_offset(0, i) + VIDEO_ADDRESS),
				(char*)(get_screen_offset(0,i-1) + VIDEO_ADDRESS),
				MAX_COLS*2);
	}
	
	/* print blank characters at the last line*/
	char* last_line = (char*)(get_screen_offset(0, MAX_ROWS -1) + 
			VIDEO_ADDRESS);

	for(i = 0; i<MAX_COLS*2; i++)
	{
		last_line[i] = 0;
	}

	/* cursor_offset was at last position of the screen when passed
	 * to the function , we took the last line position using 
	 * get_screen_offset without changing the cursor offset variable
	 * and now we are setting it to the*/
	cursor_offset -= 2*MAX_COLS;


}

void print_char(char character, int col, int row, char attribute_byte)
{
	volatile unsigned char *vidmem = (unsigned char*) VIDEO_ADDRESS;

	if(!attribute_byte)
	{
		attribute_byte = WHITE_ON_BLACK;
	}

	int offset;
	if(col>= 0 && row >=0)
	{
		offset = get_screen_offset(col, row);
	}
	else
	{
		offset = get_cursor();
	}

	if(character == '\n')
	{
		int rows = offset / (2*MAX_COLS);
		offset = get_screen_offset(79, rows);
	}
	else
	{
		vidmem[offset] = character; 
		vidmem[offset+1] = attribute_byte;
	}

	offset += 2;
	offset = handle_scrolling(offset);
	set_cursor(offset);

}


void print_at(const char* message, int col, int row)
{
	if(col>= 0 && row >=0)
	{
		set_cursor(get_screen_offset(col, row));
	}
	
	int i=0;
	while(message[i] != 0)
	{
		print_char(message[i++], col, row, WHITE_ON_BLACK);
	}
}


void print(const char* message)
{
	print_at(message, -1, -1);
}

void clear_screen()
{
	int row =0;
	int col =0;
	//set_cursor(get_screen_offset(0, 0));

	/* looping and printing black characters on the screen*/
	for(row=0;row<MAX_ROWS; row++)
	{
		for(col=0;col<MAX_COLS; col++)
		{
			print_char(' ', col, row, WHITE_ON_BLACK);
		}
	}
	
	//move the cursor back to the top left
	set_cursor(get_screen_offset(0, 0));
}
