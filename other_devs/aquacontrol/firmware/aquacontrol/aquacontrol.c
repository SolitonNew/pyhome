/*
 * aquacontrol.c
 *
 * Created: 04.02.2017 22:26:42
 *  Author: Александр
 */ 

#define F_CPU 11059010UL

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <avr/eeprom.h>
#include "LCD.h"
#include "onewire.h"

#define LED_DDR DDRA
#define LED_PORT PORTA
#define LED_1 0
#define LED_2 1
#define LED_3 2
#define LED_4 3
#define LED_5 4
#define LED_6 5

#define HEAT_DDR DDRC
#define HEAT_PORT PORTC
#define HEAT_PIN 3

#define BTN_DDR DDRC
#define BTN_PORT PORTC
#define BTN_PIN PINC
#define BTN_PAUSE 10

#define BTN_IN 7
#define BTN_UP 6
#define BTN_DOWN 5
#define BTN_OUT 4

#define SPIN(port, pin) port |= (1<<pin)
#define CPIN(port, pin) port &= ~(1<<pin)
#define GPIN(port, pin) port & (1<<pin)

#define NUM_2_CHAR(num) num + 48;
#define TIME_STEP 1200 
#define TEMP_STEP 5
#define MAX_TIME 172800 - 1
#define LED_TIMEOUT 120

char *menu[3] = {"Температура",
                 "Подсветка",
				 "Часы"};
				 
long int time = 0;
int curr_temp = 0;
int set_temp = 0;
long int on_time = 0;
long int off_time = 0;
unsigned char blink = 0;
unsigned char led_state = 0;

unsigned char one_second = 0;
unsigned int half_hour = 0;
unsigned char half_hour_flag = 0;
unsigned int lcd_led_timeout = 0;

char *on_label = "ВКЛ.";
char *off_label = "ВЫКЛ.";
char *set_label = "Уст.";
char *curr_label = "Тек.";
				 
char _view_menu = 100; // То шо отображаем 
int _sel_menu = 0; // То шо выбрано кнопками в текущем отображении

void decodeFloat(char text[], int val) {
	int t1 = 0;
	t1 = val / 100;
	val = val - t1 * 100;
	if (t1 > 0) {
		text[0] = NUM_2_CHAR(t1);
	} else
		text[0] = 32;
	t1 = val / 10;
	val = val - t1 * 10;
	text[1] = NUM_2_CHAR(t1);
	text[3] = NUM_2_CHAR(val);
}

void decodeTime(char text[], unsigned long int val) {
	unsigned char hour = 0;
	unsigned char minute = 0;
	unsigned long int time_tmp = 0;	
	
	time_tmp = val / 120; // Получаем количество минут
	hour = time_tmp / 60; // Часов
	minute = time_tmp - (hour * 60);
			
	text[0] = NUM_2_CHAR(hour / 10);
	text[1] = NUM_2_CHAR(hour - (hour / 10) * 10);
	text[3] = NUM_2_CHAR(minute / 10);
	text[4] = NUM_2_CHAR(minute - (minute / 10) * 10);
}

void redrawSubMenu(unsigned char i) {
	LCD_rect(0, 0, 83, 14, 1);
	LCD_rect(0, 13, 83, 34, 0);
	LCD_text(4, 1, menu[i - 1], 1, 0, 1);
}

void redrawLCD() {
	LCD_clear();
	unsigned char i = 0;
	unsigned char i1 = 0;
	unsigned char y = 0;
	
	char *time_label = "00:00";
	char *temp_label = "00.0 C";
	
	switch (_view_menu) {
		case 100: // Главный экран
			// Индикация подогрева
			if (GPIN(HEAT_PORT, HEAT_PIN))
				LCD_text(0, 0, "ВКЛ.", 1, 0, 0);
			else
				LCD_text(0, 0, "ВЫКЛ.", 1, 0, 0);
		
			// Индикация температуры
			decodeFloat(temp_label, curr_temp);			
			LCD_text(LCD_W - LCD_text_w(temp_label, 1), 0, temp_label, 1, 0, 0);
			LCD_draw_gradus(75, 1, 3);
			
			// Индикация времени
			decodeTime(time_label, time);
			char s = 7;
			for (i = 0; i < 5; i++) {
				if (i == 2) {
					if (blink)
						LCD_draw_char(s - 1, 6, ":", 2, 0);
					s += 7;
				} else {
					LCD_draw_char(s, 8, time_label[i], 2, 0);
					s += 16;
				}				
			}			
			break;
		case 0: // Меню настроек
			for (i = 0; i < 3; i++) {
				y = (i * 14);
				if (_sel_menu == i) {
					LCD_rect(0, y, 83, 14, 0);
					LCD_text(4, y + 1, menu[i], 1, 0, 0);
				} else {
					LCD_text(4, y + 1, menu[i], 1, 0, 0);
				}				
			}			
			break;
		case 1: // Настройка подогрева
		case 11: // Указываем температуру
			redrawSubMenu(1);
			y = (_view_menu == 11);
			LCD_rect(3, 17, 77, 13, y);
			i = LCD_text(8, 18, set_label, 1, 0, y);
			i = LCD_text(i, 18, ": ", 1, 0, y);
			decodeFloat(temp_label, set_temp);
			i = LCD_text(i, 18, temp_label, 1, 0, y);
			LCD_draw_gradus(i - 9, 19, 3);
			
			i = LCD_text(8, 30, curr_label, 1, 0, 0);
			i = LCD_text(i, 30, ": ", 1, 0, 0);
			decodeFloat(temp_label, curr_temp);
			i = LCD_text(i, 30, temp_label, 1, 0, 0);
			LCD_draw_gradus(i - 9, 31, 3);

			break;
		case 2: // Настройка подсветки
		case 21: // Настройка включения
		case 22: // Настройка выключения
			redrawSubMenu(2);
			
			switch (_view_menu) {
				case 2:
					LCD_rect(3, 17 + _sel_menu * 12, 77, 13, 0);
					break;
				default:
					LCD_rect(3, 17 + (_view_menu - 21) * 12, 77, 13, 1);
			}
			y = (_view_menu == 21);
			i = LCD_text(8, 18, on_label, 1, 0, y);
			i = LCD_text(i, 18, ": ", 1, 0, y);
			decodeTime(time_label, on_time);
			i = LCD_text(i, 18, time_label, 1, 0, y);
			
			y = (_view_menu == 22);
			i = LCD_text(8, 30, off_label, 1, 0, y);
			i = LCD_text(i, 30, ": ", 1, 0, y);
			decodeTime(time_label, off_time);
			i = LCD_text(i, 30, time_label, 1, 0, y);
			break;
		case 3: // Установка времени
		case 31: // Указываем время
			redrawSubMenu(3);
			
			y = (_view_menu == 31);
			LCD_rect(3, 17, 77, 13, y);
			i = LCD_text(8, 18, curr_label, 1, 0, y);
			i = LCD_text(i, 18, ": ", 1, 0, y);
			decodeTime(time_label, time);
			for (i1 = 0; i1 < 5; i1++) {
				if (i1 == 2) {
					if (blink)
						i += LCD_draw_char(i, 18, time_label[i1], 1, y);
					else
						i += font_char_w(1, time_label[i1]);					
				} else {
					i += LCD_draw_char(i, 18, time_label[i1], 1, y);
				}
			}
			break;
	}
	
	LCD_show();
}

unsigned char btn_states[4];

char check_btn(unsigned char b_pin, unsigned char b_num)
{
	unsigned char res = 0; // Не нажато
	if (GPIN(BTN_PIN, b_pin)) {
		if (btn_states[b_num] && btn_states[b_num] < BTN_PAUSE) {
			res = 1; // Короткое нажатие
		}
		btn_states[b_num] = 0;
	} else {
		if (btn_states[b_num] > BTN_PAUSE) {
			_delay_ms(50);
			res = 2; // Длинное нажатие
		} else {
			btn_states[b_num]++;
		}
	}
	
	if (res && led_state == 0 && lcd_led_timeout == LED_TIMEOUT) {
		lcd_led_timeout = 0;
		LCD_led(1);
		res = 0;
	}
	
	if (res) {
		lcd_led_timeout = 0;
		LCD_led(1);
	}	
		
	return res;
}

void checkTimeAction() {
	if (time >= on_time && time < off_time)
		led_state = 1;
	else
		led_state = 0;
}

char termPresc = 0;

void checkTempAction() {
	if (termPresc == 0) {
		termPresc = 5;
		curr_temp = getTemp();
		startTemp();
		
		if (GPIN(HEAT_PORT, HEAT_PIN)) {
			if (curr_temp > set_temp + 2) {
				CPIN(HEAT_PORT, HEAT_PIN);
			}			
		} else {
			if (curr_temp < (set_temp - 2))
				SPIN(HEAT_PORT, HEAT_PIN);
		}
	}
	termPresc--;
}

ISR (TIMER1_OVF_vect)
{	
	TCNT1 = 0xffff - 5400; // Один тик в пол секунды
	TIFR |= 1<<TOV1;
	one_second = 1;
	blink = ~blink; 
	time += 1;
	if (time > MAX_TIME) // Прошли сутки
		time = 0;
		
	if (half_hour == 0) { // Случается раз в пол часа
		half_hour = 3600;
		half_hour_flag = 1;
	}
	half_hour--;
	
	if (lcd_led_timeout < LED_TIMEOUT) { // Случается раз в минуту
		lcd_led_timeout++;
	}
}

EEMEM int eep_set_temp;
EEMEM long int eep_on_time;
EEMEM long int eep_off_time;
EEMEM long int eep_time;

void load_props() {
	eeprom_read_block(&set_temp, &eep_set_temp, sizeof(set_temp));
	eeprom_read_block(&on_time, &eep_on_time, sizeof(on_time));
	eeprom_read_block(&off_time, &eep_off_time, sizeof(off_time));
	eeprom_read_block(&time, &eep_time, sizeof(time));
}

void save_props() {
	eeprom_update_block(&set_temp, &eep_set_temp, sizeof(set_temp));
	eeprom_update_block(&on_time, &eep_on_time, sizeof(on_time));
	eeprom_update_block(&off_time, &eep_off_time, sizeof(off_time));
	eeprom_update_block(&time, &eep_time, sizeof(time));
}

int main(void)
{
	load_props();
	
	DDRA = 0xff;
	DDRB = 0xff;
	DDRC = 0xff;
	DDRD = 0xff;
	
	// Включаем таймер часов
	TCCR1B |= (1<<CS12)|(1<<CS10);
	TIMSK |= (1<<TOIE1);
	TIFR |= 1<<TOV1; //Сброс флага TOV0
	TCNT1 = 0xffff - 5400; // Один тик в пол секунды
	// ---------------------	
	
	LCD_init();
	redrawLCD();
	LCD_led(1);
	
	BTN_DDR |= (1<<BTN_UP)|(1<<BTN_DOWN)|(1<<BTN_IN)|(1<<BTN_OUT);
	BTN_PORT |= (1<<BTN_UP)|(1<<BTN_DOWN)|(1<<BTN_IN)|(1<<BTN_OUT);
	
	sei();
	
	ow_init();
	startTemp();
	termPresc = 5;
	
	char cb = 0;
    while(1)
    {
		cb = check_btn(BTN_UP, 0);
		if (cb) {
			switch (_view_menu) {
				case 100:
					_view_menu = 0;
					redrawLCD();
					break;
				case 0:
					_sel_menu--;
					if (_sel_menu < 0)
						_sel_menu = 2;
					redrawLCD();
					break;
				case 1:
					break;
				case 11:
					if (cb == 1)
						set_temp++;
					else
						set_temp += TEMP_STEP;
					if (set_temp > 400)
						set_temp = 100;
					redrawLCD();
					break;
				case 2:
					_sel_menu--;
					if (_sel_menu < 0)
						_sel_menu = 1;
					redrawLCD();
					break;
				case 21:
					if (cb == 1)
						on_time += 120;
					else
						on_time += TIME_STEP;
					if (on_time > MAX_TIME)
						on_time = 0;
					redrawLCD();
					break;
				case 22:
					if (cb == 1)
						off_time += 120;
					else
						off_time += TIME_STEP;
					if (off_time > MAX_TIME)
						off_time = 0;
					redrawLCD();
					break;
				case 3:
					break;
				case 31:
					if (cb == 1)
						time += 120;
					else
						time += TIME_STEP;
					if (time > MAX_TIME)
						time = 0;
					redrawLCD();
					break;
			}
		}
		
		cb = check_btn(BTN_DOWN, 1);
		if (cb) {
			switch (_view_menu) {
				case 100:
					_view_menu = 0;
					redrawLCD();
					break;
				case 0:
					_sel_menu++;
					if (_sel_menu > 2)
						_sel_menu = 0;
					redrawLCD();
					break;
				case 1:
					break;
				case 11:
					if (cb == 1)
						set_temp--;
					else
						set_temp -= TEMP_STEP;
					if (set_temp < 100)
						set_temp = 400;
					redrawLCD();
					break;
				case 2:
					_sel_menu++;
					if (_sel_menu > 1)
						_sel_menu = 0;
					redrawLCD();
					break;
				case 21:
					if (cb == 1)
						on_time -= 120;
					else
						on_time -= TIME_STEP;
					if (on_time < 0)
						on_time = MAX_TIME;
					redrawLCD();
					break;
				case 22:
					if (cb == 1)
						off_time -= 120;
					else
						off_time -= TIME_STEP;
					if (off_time < 0)
						off_time = MAX_TIME;
					redrawLCD();
					break;
				case 3:
					break;
				case 31:
					if (cb == 1)
						time -= 120;
					else
						time -= TIME_STEP;
					if (time < 0)
						time = MAX_TIME;
					redrawLCD();
					break;
			}
		}
		
		cb = check_btn(BTN_IN, 2);
		if (cb == 1) {
			switch (_view_menu) {
				case 100:
					_view_menu = 0;
					_sel_menu = 0;
					redrawLCD();
					break;
				case 0:
					_view_menu = _sel_menu + 1;
					_sel_menu = 0;
					redrawLCD();
					break;
				case 1:
					_view_menu = 11;
					_sel_menu = 0;
					redrawLCD();
					break;
					
				case 2:
					_view_menu = 20 + _sel_menu + 1;
					_sel_menu = 0;
					redrawLCD();
					break;
					
				case 3:
					_view_menu = 31;
					_sel_menu = 0;
					redrawLCD();
					break;
			}
		}
		
		cb = check_btn(BTN_OUT, 3);
		if (cb == 1) {
			switch (_view_menu) {
				case 100:
					_view_menu = 0;
					_sel_menu = 0;
					redrawLCD();
					break;
				case 0:
					_view_menu = 100;
					_sel_menu = 0;
					redrawLCD();
					break;
					
				case 1:
					_view_menu = 0;
					_sel_menu = 0;
					redrawLCD();
					break;
					
				case 11:
					_view_menu = 1;
					_sel_menu = 0;
					redrawLCD();
					save_props();
					break;
					
				case 2:
					_view_menu = 0;
					_sel_menu = 1;
					redrawLCD();
					break;
					
				case 21:
					_view_menu = 2;
					_sel_menu = 0;
					redrawLCD();
					save_props();
					break;
					
				case 22:
					_view_menu = 2;
					_sel_menu = 1;
					redrawLCD();
					save_props();
					break;
					
				case 3:
					_view_menu = 0;
					_sel_menu = 2;
					redrawLCD();
					break;
					
				case 31:
					_view_menu = 3;
					_sel_menu = 0;
					redrawLCD();
					save_props();
					break;				
			}
		}
		
		if (one_second) {
			one_second = 0;
			switch (_view_menu) {
				case 100:
				case 1:
				case 11:
				case 3:
				case 31:
					redrawLCD();
					break;
			}			
			checkTimeAction();
			checkTempAction();
			
			if (half_hour_flag) {
				half_hour_flag = 0;
				save_props();
			}
			
			if (led_state)
				LED_PORT = 0xff;
			else
				LED_PORT = 0x0;
				
			// Таймаут перехода к главному экрану
			if (lcd_led_timeout == LED_TIMEOUT && _view_menu != 100) {
				_view_menu = 100;
				save_props();
				redrawLCD();
			}
		
			// Управляем подсветкой экрана
			if (led_state || lcd_led_timeout != LED_TIMEOUT) {
				LCD_led(1);
			} else {
				LCD_led(0);
			}
			
		}

        _delay_ms(50);
    }
}