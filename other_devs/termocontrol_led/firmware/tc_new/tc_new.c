/*
 * tc_new.c
 *
 * Created: 01.08.2016 16:59:00
 *  Author: Александр
 */ 

#define F_CPU 8000000UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <avr/eeprom.h>

#define main_loop_delay 50

#include "led.h"
#include "sound.h"
#include "ow_master.h"
#include "ow_slave.h"

#define btn_ddr DDRD
#define btn_pin PIND
#define btn_port PORTD
#define btn_sel_pin 4
#define btn_up_pin 5
#define btn_down_pin 6
#define btn_sel_delay 20
#define btn_delay 10

#define tempPauseLONG 25;
#define tempPauseFAST 5;

#define check_btn(pin) !(btn_pin & (1<<pin))

#define switch_ddr DDRB
#define switch_port PORTB
#define switch_pin 3

#define rele_ddr DDRA
#define rele_port PORTA
#define rele_main_pin PORTA0
#define rele_tp_pin PORTA1

#define query_len 6

/*
	управление краном малого круга
	управление магистральным насосом
	управление насосом теплого пола
	сигнализация "подклинило подсос"
	сигнализация "перегрев котла"
	сигнализация "перегрев трубы"
*/

unsigned char query[4][6];
unsigned char query_sel = 0;
unsigned char query_sel_sub = 0;

unsigned char btn_flags[3] = {0, 0, 0};

/* 
0 - рабочий режим; 
10 - настройка условий;
20 - сканирование OW; 21 - настройка термометров; 
*/
unsigned char regim = 0; 

unsigned char stop_sel_handler = 0;

void btn_sel_handler(unsigned char is_long) {	
	if (regim != 10)
		clearReleValues();
	if (is_long) {
		if (!stop_sel_handler) {
			stop_sel_handler = 1;
			switch (regim) {
				case 0:
					regim = 20;
					for (unsigned char i = 0; i < 15; i++)
						led_buff[i] = 16;	
					OW_M_scan_devs();
					OW_M_startLoading();
					regim = 21;
					selected_led = 0;
					OW_M_set_measPause = tempPauseFAST;
					break;
				default:					
					regim = 0;
					sel_query_sel(-1);
					selected_led = -1;
					selected_led_degs[0] = -1;
					selected_led_degs[1] = -1;
					led_blink_all = 0;
					hide_not_selected = 0;
					for (unsigned char i = 0; i < 15; i++)
						led_buff[i] = 16;
					save_props();
					_delay_ms(1000);
					OW_M_set_measPause = tempPauseLONG;
					break;
			}
		}		
	} else {
		switch (regim) {
			case 0:
				regim = 10;
				sel_query_sel(0);
				break;
			case 10:
				query_sel_sub++;
				if (query_sel_sub > 3)
					query_sel_sub = 0;
				redraw_query_led();				
				break;
			case 21:
				hide_not_selected = !hide_not_selected;
				break;
		}		
	}
}

void btn_up_handler() {
	unsigned char prev_s = selected_led;
	char v = 0;
	switch (regim) {
		case 0:
			//
			break;
		case 10:
			switch (query_sel_sub) {
				case 0:
					if (query_sel == 0)
						query_sel = query_len - 1;
					else
						query_sel--;
					sel_query_sel(query_sel);
					break;
				case 1:
					v = query[query_sel][0];
					if (v == 0)
						v = 4;
					else
						v--;						
					query[query_sel][0] = v;
					redraw_query_led();
					break;
				case 2:
					v = query[query_sel][1];
					if (v == 2)
						v = 0;
					else
						v++;						
					query[query_sel][1] = v;
					redraw_query_led();
					break;
				case 3:
					v = query[query_sel][2];
					if (v == 90)
						v = 10;
					else
						v++;						
					query[query_sel][2] = v;
					redraw_query_led();
					break;
			}
			break;
		case 21:			
			if (selected_led == 0)
				selected_led = 4;
			else 
				selected_led--;
			led_blink = 0;
			if (hide_not_selected)
				change_temp_order(prev_s, selected_led);
			break;
	}	
}

void btn_down_handler() {
	unsigned char prev_s = selected_led;
	char v = 0;
	switch (regim) {
		case 0:
			//
			break;
		case 10:
			switch (query_sel_sub) {
				case 0:
					if (query_sel == query_len - 1)
						query_sel = 0;
					else
						query_sel++;
					sel_query_sel(query_sel);
					break;
				case 1:
					v = query[query_sel][0];
					if (v == 4)
						v = 0;
					else
						v++;						
					query[query_sel][0] = v;
					redraw_query_led();
					break;
				case 2:
					v = query[query_sel][1];
					if (v == 0)
						v = 2;
					else
						v--;						
					query[query_sel][1] = v;
					redraw_query_led();
					break;
				case 3:
					v = query[query_sel][2];
					if (v == 10)
						v = 90;
					else
						v--;						
					query[query_sel][2] = v;
					redraw_query_led();
					break;
			}
			break;
		case 21:
			if (selected_led == 4)
				selected_led = 0;
			else 
				selected_led++;
			led_blink = 0;
			if (hide_not_selected)
				change_temp_order(prev_s, selected_led);
			break;
	}	
}

void change_temp_order(unsigned char i1, unsigned char i2) {
	float t = ow_master_values[i1];
	ow_master_values[i1] = ow_master_values[i2];
	ow_master_values[i2] = t;
	
	for (unsigned char i = 0; i < 8; i++) {
		unsigned char r = ow_master_roms[i1][i];
		ow_master_roms[i1][i] = ow_master_roms[i2][i];
		ow_master_roms[i2][i] = r;
	}	
}

void sel_query_sel(unsigned char val) {
	query_sel = val;
	for (unsigned char i = 0; i < 6; i++) {
		if (i != val)
			setReleValue(i, 0);
	}
	setReleValue(val, 1);
	query_sel_sub = 0;
	redraw_query_led();
}

void redraw_query_led() {
	unsigned char row = query[query_sel][0] * 3;
	
	switch (query_sel_sub) {
		case 0:
			selected_led = -1;
			led_blink_all = 1;
			/*for (unsigned char i = 0; i < 15; i++) {
				led_buff[i] = 16;
			}*/
			break;
		case 1:
			led_blink_all = 0;
			selected_led = query[query_sel][0];
			if (selected_led < 0 || selected_led > 4) selected_led = 0;
			/*for (unsigned char i = 0; i < 15; i++) {
				led_buff[i] = 17;
			}*/
			break;
		default:
			selected_led = -1;
			/*for (unsigned char i = 0; i < 15; i++) {
				led_buff[i] = 16;
			}*/
			led_blink_all = 0;
			break;
	}
	
	switch (query_sel_sub) {
		case 2:
			selected_led_degs[0] = row;
			selected_led_degs[1] = -1;
			break;
		case 3:
			selected_led_degs[0] = row + 1;
			selected_led_degs[1] = row + 2;
			break;
		default:
			selected_led_degs[0] = -1;
			selected_led_degs[1] = -1;
			break;
	}
	led_buff[row] = 17 + query[query_sel][1];
	
	int v = query[query_sel][2];
	unsigned char v1 = v / 10;
	v -= v1 * 10;
	unsigned char v2 = v;
	if (v1 == 0)
		v1 = 16;
	led_buff[row + 1] = v1;
	led_buff[row + 2] = v2;
	
	// Дополнительная индикация номера текущего условия
	for (unsigned char i = 0; i < 5; i++) {
		if (query[query_sel][0] != i) {
			unsigned char n = i * 3;
			led_buff[n] = query_sel + 1 + 0b00100000;
			led_buff[n + 1] = 16;
			led_buff[n + 2] = 16;
		}		
	}
}

void setReleValue(unsigned char num, unsigned char val) {
	switch (num) {
		case 0:
			if (val) {
				OCR0 = 100;				
			} else {
				OCR0 = 0;
			}			
			break;
		case 1:
			if (val)
				rele_port |= (1<<rele_main_pin);
			else
				rele_port &= ~(1<<rele_main_pin);
			break;
		case 2:
			if (val)
				rele_port |= (1<<rele_tp_pin);
			else
				rele_port &= ~(1<<rele_tp_pin);
			break;
		case 3:
			signals[0] = val;
			break;
		case 4:
			signals[1] = val;
			break;
		case 5:
			signals[2] = val;
			break;
	}
}

void clearReleValues() {
	for (unsigned char i = 0; i < 6; i++) {
		setReleValue(i, 0);
	}
}

void checkQuery() {
	for (unsigned char q = 0; q < 6; q++) {
		if (query[q][0] > 0) {
			switch (query[q][1]) {
				case 1:
					if (ow_master_values[query[q][0]] >= query[q][2]) {
						setReleValue(q, 1);
					} else 
					if (ow_master_values[query[q][0]] < query[q][2] - 2) {
						setReleValue(q, 0);
					}
					break;
				case 2:
					if (ow_master_values[query[q][0]] <= query[q][2]) {
						setReleValue(q, 1);
					} else
					if (ow_master_values[query[q][0]] > query[q][2] + 2) {
						setReleValue(q, 0);
					}
					break;
			}
		}		
	}
}

EEMEM unsigned char eep_ow_master_roms[5][8];
EEMEM unsigned char eep_query[4][6];

void load_props() {
	eeprom_read_block(&ow_master_roms, &eep_ow_master_roms, sizeof(ow_master_roms));
	eeprom_read_block(&query, &eep_query, sizeof(query));
	
	for (unsigned char i = 0; i < query_len; i++) {
		if (query[i][0] > 4)
			query[i][0] = 0;
		if (query[i][1] > 2)
			query[i][1] = 0;
		if (query[i][2] > 90)
			query[i][2] = 10;
		if (query[i][2] < 10)
			query[i][2] = 10;
	}
}

void save_props() {
	eeprom_update_block(&ow_master_roms, &eep_ow_master_roms, sizeof(ow_master_roms));
	eeprom_update_block(&query, &eep_query, sizeof(query));
}

int main(void) {
	load_props();
	
	led_init();
	sound_init();
	ow_master_init();
	OW_M_startLoading();
	OW_M_set_measPause = tempPauseLONG;
	
	ow_slave_init();
	
	btn_port |= (1<<btn_sel_pin)|(1<<btn_up_pin)|(1<<btn_down_pin);
	
	//switch_ddr |= (1<<switch_pin);
	//Switch
	TCCR0 = (1<<COM01)|(1<<WGM00)|(1<<CS00);
	switch_ddr |= (1<<switch_pin);
	//Relays
	rele_ddr |= (1<<rele_main_pin)|(1<<rele_tp_pin);
	
	sei();
	
	sound_play(200);
	
    while(1) {
		if (check_btn(btn_sel_pin)) {
			if (btn_flags[0] > btn_sel_delay) {
				btn_sel_handler(1);
			} else {
				btn_flags[0]++;
			}
		} else {
			if (btn_flags[0] && btn_flags[0] <= btn_sel_delay) {
				btn_sel_handler(0);
			}
			btn_flags[0] = 0;
			stop_sel_handler = 0;
		}
		
		if (check_btn(btn_up_pin)) {
			if (btn_flags[1] > btn_delay) {
				btn_up_handler();
			} else {
				btn_flags[1]++;
			}			
		} else {
			if (btn_flags[1] && btn_flags[1] <= btn_delay) {
				btn_up_handler();
			}
			btn_flags[1] = 0;
		}
		
		if (check_btn(btn_down_pin)) {
			if (btn_flags[2] > btn_delay) {
				btn_down_handler();
			} else {
				btn_flags[2]++;
			}			
		} else {
			if (btn_flags[2] && btn_flags[2] <= btn_delay) {
				btn_down_handler();
			}
			btn_flags[2] = 0;
		}
		
		switch (regim) {
			case 0:
			case 21:
				checkTemp();
				for (unsigned char i = 0; i < 5; i++)
					write_num(i, ow_master_values[i]);
				break;
			case 10:
				break;
		}
		
		if (regim == 0) checkQuery();
				
		_delay_ms(main_loop_delay);
    }
}