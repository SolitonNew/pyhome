/*
 * LCD_fonts.h
 *
 * Created: 05.02.2017 12:44:49
 *  Author: Александр
 */ 

#include <avr/pgmspace.h>
#include "font_1.h"
#include "font_2.h"

#define font_height(fontNum) font_data_byte(fontNum, 31)

unsigned char font_data_byte(char fontNum, unsigned int pos)
{
	switch (fontNum) {
		case 1:	return pgm_read_byte(&(font_1[pos]));
		case 2:	return pgm_read_byte(&(font_2[pos]));
	}
	return 0;
}

unsigned char font_char_w(char fontNum, unsigned char sym)
{
	unsigned char cFrom = font_data_byte(fontNum, 29);
	unsigned char cTo = font_data_byte(fontNum, 30);
	
	if (sym < cFrom)
		sym = cFrom;
		
	if (sym > cTo)
		sym = cTo;
        
	return font_data_byte(fontNum, 32 + (sym - cFrom) * 3 + 2);
}


unsigned int font_char_pos(char fontNum, unsigned char sym)
{
	unsigned char cFrom = font_data_byte(fontNum, 29);
	unsigned char cTo = font_data_byte(fontNum, 30);
	
	if (sym < cFrom)
		sym = cFrom;
		
	if (sym > cTo)
		sym = cTo;
		
	unsigned char p0 = font_data_byte(fontNum, 32 + (sym - cFrom) * 3);
	unsigned char p1 = font_data_byte(fontNum, 32 + (sym - cFrom) * 3 + 1);
        
	return (p1 << 8) | p0;
}