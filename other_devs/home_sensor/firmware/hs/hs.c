﻿/*
 * hs.c
 *
 * Created: 25.11.2015 8:16:25
 *  Author: Александр
 */ 

#define F_CPU 9600000UL
#include "avr/io.h"
#include <avr/interrupt.h>
#include "util/delay.h"

#define SPIN(data, pin) (data |= (1<<pin))
#define CPIN(data, pin) (data &= ~(1<<pin))
#define GPIN(data, pin) (data & (1<<pin))

#define LED_L 2
#define LED_R 0
#define SENSOR_L 3
#define SENSOR_R 4

#define OW_DDR DDRB
#define OW_READ PINB
#define OW_PIN 1

#define SEARCH_ROM 0xF0
#define ALARM_SEARCH 0xEC
#define MATCH_ROM 0x55
#define READ_DATA 0xA0

#define OW_UP OW_DDR &= ~(1 << OW_PIN)
#define OW_DOWN OW_DDR |= (1 << OW_PIN)
#define IS_LOW ((OW_READ & (1 << OW_PIN)) == 0)
#define IS_HIGH (OW_READ & (1 << OW_PIN))

#define WAIT_COUNT 1000
#define WAIT_FOR_LOW for (int i = 0; i < WAIT_COUNT && IS_HIGH; i++)
#define WAIT_FOR_HIGH for (int i = 0; i < WAIT_COUNT && IS_LOW; i++)

unsigned char sensor_data = 0;
unsigned char isChange = 0;

unsigned char ROM[8] = {0xF0,0x00,0x00,0x00,0x00,0x00,0x01,0x0};
	
unsigned char crc_table(unsigned char data)
{
	unsigned char crc = 0x0;
	unsigned char fb_bit = 0;
	for (unsigned char b = 0; b < 8; b++)
	{ 
		fb_bit = (crc ^ data) & 0x01;
		if (fb_bit==0x01) 
			crc = crc ^ 0x18;
		crc = (crc >> 1) & 0x7F;
		if (fb_bit==0x01) 
			crc = crc | 0x80;
		data >>= 1;
	}
	return crc;
}

unsigned char OW_readBit()
{
	unsigned char res = 0;
	WAIT_FOR_LOW;
	_delay_us(20);	
	if (IS_HIGH) res = 1;
	WAIT_FOR_HIGH;
	return res;
}

unsigned char OW_readByte()
{
	unsigned char res = 0;
	WAIT_FOR_HIGH;
	for (unsigned char i = 0; i < 8; i++)
	{
		res = res >> 1;
		if (OW_readBit())
			res |= 0x80;
	}
	return res;
}

void OW_writeBit(unsigned char b)
{	
	WAIT_FOR_LOW;
	OW_UP;
	//_delay_us(1);
	if (b == 0) OW_DOWN;	
	_delay_us(60);
	OW_UP;
	WAIT_FOR_HIGH;
}

void OW_writeByte(unsigned char data)
{
	WAIT_FOR_HIGH;
	for (unsigned char i = 0; i < 8; i++)
	{
		OW_writeBit(data & 1);
		data >>= 1;
	}
}

void one_wire_action()
{	
	//Presence
	WAIT_FOR_HIGH;
	_delay_us(30);
	OW_DOWN;
	_delay_us(100);
	OW_UP;		
	WAIT_FOR_HIGH;
	
	unsigned char i;
	unsigned char k;
	unsigned char count;
	
	unsigned char rom_cmd = OW_readByte();

	switch (rom_cmd)
	{
		case SEARCH_ROM: // Поиск устройств на шине
		case ALARM_SEARCH: // Поиск устройств с флагом ALARM
			if ((rom_cmd != SEARCH_ROM) && (isChange == 0))
				return ;
			for (i = 0; i < 8; i++)
			{	
				unsigned char b = ROM[i];
				for (k = 0; k < 8; k++)
				{			
					unsigned char wb = (b & 1);
					OW_writeBit(wb);
					OW_writeBit(!wb);									
					unsigned char rb = OW_readBit();
					if (rb != wb)
						return ;			
					b >>= 1;
				}
			}				
			break;			
		
		case MATCH_ROM: // Выбор устройства
			// Проверем ключ устройства
			for (i = 0; i < 8; i++) 
				if (OW_readByte() != ROM[i])
					return ;
												
			switch (OW_readByte()) // Читаем комманду для этого устройства
			{
				case READ_DATA: // Чтение данных	
					isChange = 0;
					OW_writeByte(sensor_data);		
					OW_writeByte(crc_table(sensor_data));
					break;
			}			
			break;			
		default: ;
	}	
}
	
ISR (INT0_vect)
{
	if ((MCUCR & (1<<ISC00))!=0) 
	{
		TCCR0B = 0; //Выключаем таймер
		TIFR0 |= (1<<TOV0);
		MCUCR = (1<<ISC01); //Сброс ISC00 - прерывание по \__
	}
	else
	{		
		TCNT0 = 255-60;
		TIFR0 |= (1<<TOV0); //Сброс флага TOV0
		TIMSK0 |= (1<<TOIE0);
		MCUCR = (1<<ISC01)|(1<<ISC00); // прерывание по __/
		TCCR0B = (1<<CS01)|(1<<CS00); //Делитель на 64		
	}
}

ISR (TIM0_OVF_vect)
{			
	TCCR0B = 0;
	TIFR0 |= 1<<TOV0;
	one_wire_action();
}

void shutdownSensor(unsigned char pin)
{
	DDRB |= (1<<pin);
	PORTB &= ~(1<<pin);
	_delay_ms(2);
	//for (unsigned char i = 0; (i < 255); i++) 
	//	if (PINB & (1<<pin) == 0)
	//		return ;	
}

unsigned char checkSensor(unsigned char pin)
{
	unsigned char b = 1;
	DDRB &= ~(1<<pin);
	for (unsigned char i = 0; i < 8; i++)
		if (PINB & (1<<pin))
			b = 0;
	return b;
}

int main(void)
{
	unsigned char crc = 0;
	for (unsigned char i = 0; i < 7; i++)
		crc = (crc_table(crc ^ ROM[i]));
	ROM[7] = crc;
	
	// Сенсор	
	DDRB |= (1<<SENSOR_L)|(1<<SENSOR_R); //|(1<<LED_L)|(1<<LED_R);
	SPIN(PORTB, LED_L);
	SPIN(PORTB, LED_R);
	
	// Шина
	CPIN(OW_DDR, OW_PIN);
		
	TIFR0 |= 1<<TOV0;
	GIFR |= 1<<INTF0;
	MCUCR = (1<<ISC01); //Сброс ISC00 - прерывание по \__
	GIMSK |= (1<<INT0);
	
	sei();
	
	unsigned char data;
	unsigned char sleep_l = 0;
	unsigned char sleep_r = 0;
	
    while(1)
    {
		data = 0;
		unsigned char n = 0;
		unsigned char cn = 12;
		
		if (sleep_l == 0) {
			n = 0;
			for (unsigned char a = 0; a < 15; a++)
			{
				shutdownSensor(SENSOR_L);
				if (checkSensor(SENSOR_L)) n++;
			}
			if (n > cn) {
				SPIN(data, SENSOR_L);
				SPIN(DDRB, LED_L);
				sleep_l = 9;
			} else {
				CPIN(DDRB, LED_L);
			}			
		} else {
			sleep_l--;
		}		
		
		if (sleep_r == 0) {
			n = 0;
			for (unsigned char a = 0; a < 15; a++)
			{
				shutdownSensor(SENSOR_R);
				if (checkSensor(SENSOR_R)) n++;
			}		
			if (n > cn) {
				SPIN(data, SENSOR_R);
				SPIN(DDRB, LED_R);
				sleep_r = 9;
			} else {
				CPIN(DDRB, LED_R);
			}			
		} else {
			sleep_r--;
		}		
				
		if (sensor_data != data)
		{
			isChange = 1;			
			sensor_data = data;
			_delay_ms(50);
		}					
    }
}