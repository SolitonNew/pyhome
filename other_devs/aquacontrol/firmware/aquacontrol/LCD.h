/*
 * LCD.h
 *
 * Created: 04.02.2017 23:12:10
 *  Author: Александр
 */ 

#include "LCD_fonts.h"

#define SPIN(port, pin) port |= (1<<pin)
#define CPIN(port, pin) port &= ~(1<<pin)
#define GPIN(port, pin) port & (1<<pin)

#define LCD_DDR DDRB
#define LCD_PORT PORTB
#define LCD_RST 3
#define LCD_DC 2
#define LCD_DATA 1
#define LCD_SCK 0

#define LCD_LED_DDR DDRD
#define LCD_LED_PORT PORTD
#define LCD_LED_1 0
#define LCD_LED_2 1
#define LCD_LED_3 2
#define LCD_LED_4 3

#define LCD_W 84
#define LCD_H 48

unsigned char LCD_BUF[504];

long int CEIL(float val) {
	return ceil(val);
}

void LCD_write(unsigned char data)
{
	for (unsigned char i = 0; i < 8; i++) {
		CPIN(LCD_PORT, LCD_SCK);
		if (data & 0x80) {
			SPIN(LCD_PORT, LCD_DATA);
		} else {
			CPIN(LCD_PORT, LCD_DATA);
		}
		data <<= 1;
		_delay_us(5);
		SPIN(LCD_PORT, LCD_SCK);
	}
	//_delay_us(5);
}

void LCD_contrast(unsigned char bias)
{
	CPIN(LCD_PORT, LCD_DC);
	LCD_write(0x21); // LCD Extended Commands.
	LCD_write(0x10 + bias); // LCD Extended Commands.
	LCD_write(0x20); // LCD Standard Commands, Horizontal addressing mode.
	SPIN(LCD_PORT, LCD_DC);	
}

void LCD_show()
{
	//cli();
	CPIN(LCD_PORT, LCD_DC);
	LCD_write(0x80);
	LCD_write(0x40);
	SPIN(LCD_PORT, LCD_DC);
	for (unsigned int i = 0; i < 504; i++) {
		LCD_write(LCD_BUF[i]);
	}
	LCD_write(0);
	CPIN(LCD_PORT, LCD_DC);
	//sei();
}

void LCD_clear()
{
	for (unsigned int i = 0; i < 504; i++)
		LCD_BUF[i] = 0;
}

unsigned char LCD_pixel(char x, char y, char v)
{
	if (x < 0 || x > LCD_W - 1) return 0;
	if (y < 0 || y > LCD_H - 1) return 0;
	
	unsigned char l = CEIL(y / 8);
	unsigned int bi = LCD_W * l + x; // Byte number in buf
	unsigned char c = 1 << (y - (l * 8)); // Bit of the screen controller byte

	switch (v) {
		case 1:
			LCD_BUF[bi] |= c;
			break;
		case 0:
			LCD_BUF[bi] &= ~c;
			break;
		default:
			if (LCD_BUF[bi] & c)
				return 1;
			else
				return 0;
	}	
	return 0;
}

void LCD_rect(char x, char y, char w, char h, char solid)
{
	if (solid)
		LCD_fill_rect(x, y, w, h, 1);
	else {
		for (unsigned char i = x; i < x + w; i++) {
			LCD_pixel(i, y, 1);
			LCD_pixel(i, y + h - 1, 1);
		}
		
		for (unsigned char i = y; i < y + h; i++) {
			LCD_pixel(x, i, 1);
			LCD_pixel(x + w, i, 1);
		}
	}	
}

void LCD_fill_rect(char x, char y, char w, char h, char color)
{
	char l1 = trunc(y / 8);
	char l2 = CEIL((y + h + 1) / 8);

	unsigned char flcTop = 0x0;
	for (char i = 0; i < 8; i++) {
		char b = ((l1 * 8) + i);
		if (b >= y && b < y + h)
			flcTop |= (1 << i);
	}	

	unsigned char flcBottom = 0x0;
	for (char i = 0; i < 8; i++) { 
		if (((l2 * 8) + i) < y + h)
			flcBottom |= (1 << i);
	}

	int k = 0;

	// Верхушка
	k = l1 * LCD_W;
	if (color) {
		for (char i = x; i < x + w + 1; i++) {
			LCD_BUF[k + i] |= flcTop;
		}		
	} else {
		for (char i = x; i < x + w + 1; i++) {
			LCD_BUF[k + i] &= ~flcTop;
		}		
	}
	
	// Центр
	
	unsigned char flc = 0x0;
	if (color)
		flc = 0xff;

	for (char l = l1 + 1; l < l2; l++) {
		k = l * LCD_W;
		for (char i = x; i < x + w + 1; i++) {
			LCD_BUF[k + i] = flc;
		}			
	}
	
	// Низ
	
	if (l2 > l1) {
		k = l2 * LCD_W;
		if (color) {
			for (char i = x; i < x + w + 1; i++)
				LCD_BUF[k + i] |= flcBottom;
		} else {
			for (char i = x; i < x + w + 1; i++)
				LCD_BUF[k + i] &= ~flcBottom;
		}
	}	
}

void LCD_clear_rect(char x, char y, char w, char h)
{
	LCD_fill_rect(x, y, w, h, 0);
}

char LCD_draw_char(char x, char y, char sym, char fontNum, char inv)
{
	unsigned char h = font_height(fontNum);
	unsigned char w = font_char_w(fontNum, sym);
	unsigned char cFrom = font_data_byte(fontNum, 29);
	unsigned char cTo = font_data_byte(fontNum, 30);
	unsigned char bh = trunc(h / 8);
	if (h % 8 > 0) bh++;
	unsigned int sym_pos = 32 + (cTo - cFrom + 1) * 3 + font_char_pos(fontNum, sym) * bh;
	
	unsigned char i_y = 0;
	unsigned char i_x = 0;
	
	unsigned long long int mask = 0x0;
	
	if (inv) {	
		for (i_y = 0; i_y < h; i_y++)
			mask |= (1<<i_y);
	}	
	mask <<= y;
	
	for (i_x = x; i_x < x + w; i_x++) {
		unsigned long long int b = 0x0;
		unsigned char n = 0;
		
		for (i_y = 0; i_y < bh; i_y++) {
			b |= ((unsigned long long int)font_data_byte(fontNum, sym_pos)) << n;
			n += 8;
			sym_pos++;
		}		
		b <<= y;
		if (inv) {
			b &= mask;
			for (i_y = 0; i_y < 6; i_y++) {
				LCD_BUF[i_y * LCD_W + i_x] &= ~(b & 0xff);
				b >>= 8;
			}
		} else {
			for (i_y = 0; i_y < 6; i_y++) {
				LCD_BUF[i_y * LCD_W + i_x] |= (b & 0xff);
				b >>= 8;
			}
		}
	}
		
	return w;
}

unsigned char LCD_text(char x, char y, char text[], char fontNum, char wrap, char inv)
{
	char cx = x;
	unsigned char h = font_height(fontNum);
	for (char c = 0; c < strlen(text); c++) {
		char o = text[c];
		if (o > 255) 
			o = 32;
		char c_w = font_char_w(fontNum, o);
		if (cx + c_w > LCD_W) {
			if (wrap) {
				cx = x;
				y += h;
			} else {
				if (cx + c_w >= LCD_W + font_char_w(fontNum, 32))
					return cx;
			}			
		}		
		cx += LCD_draw_char(cx, y, o, fontNum, inv);
	}
	return cx;
}

unsigned char LCD_text_w(char text[], char fontNum)
{
	char cx = 0;
	for (char c = 0; c < strlen(text); c++) {
		cx += font_char_w(fontNum, text[c]);
	}
	return cx;
}


void LCD_draw_gradus(char x, char y, char size) {
	LCD_rect(x, y, size - 1, size, 0);
	LCD_pixel(x, y, 0);
	LCD_pixel(x + size - 1, y, 0);
	LCD_pixel(x, y + size - 1, 0);
	LCD_pixel(x + size - 1, y + size - 1, 0);
}

void LCD_led(char on)
{
	if (on) {
		SPIN(LCD_LED_PORT, LCD_LED_1);
		SPIN(LCD_LED_PORT, LCD_LED_2);
		SPIN(LCD_LED_PORT, LCD_LED_3);
		SPIN(LCD_LED_PORT, LCD_LED_4);
	} else {
		CPIN(LCD_LED_PORT, LCD_LED_1);
		CPIN(LCD_LED_PORT, LCD_LED_2);
		CPIN(LCD_LED_PORT, LCD_LED_3);
		CPIN(LCD_LED_PORT, LCD_LED_4);
	}
}

void LCD_init()
{
	LCD_LED_DDR |= (1<<LCD_LED_1)|(1<<LCD_LED_2)|(1<<LCD_LED_3)|(1<<LCD_LED_4);
	LCD_DDR |= (1<<LCD_RST)|(1<<LCD_DC)|(1<<LCD_DATA)|(1<<LCD_SCK);
	
	// Reset
	CPIN(LCD_PORT, LCD_DC);
	CPIN(LCD_PORT, LCD_RST);
	_delay_ms(1);
	SPIN(LCD_PORT, LCD_RST);
	_delay_ms(1);

	// Init
	CPIN(LCD_PORT, LCD_DC);
	LCD_write(0x21); // LCD Extended Commands.
	LCD_write(0xC3); // Set LCD Vop
	LCD_write(0x04); // Set Temp coefficent.
	LCD_write(0x20); // LCD Standard Commands, Horizontal addressing mode.
	LCD_write(0x0C); // LCD in normal mode.        
	SPIN(LCD_PORT, LCD_DC);
	
	LCD_contrast(3); // 0-5
	//LCD_clear();
	//LCD_show();
}