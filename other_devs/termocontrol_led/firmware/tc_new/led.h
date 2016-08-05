/*
 * led.h
 *
 * Created: 01.08.2016 22:54:04
 *  Author: Александр
 */ 


#define d_mask_A 0b11111100
#define d_mask_B 0b11110111
#define d_mask_D 0b00000011

#define TCNT1_VAL 65000

#define BLINK_TIME 5000

unsigned char led_buff[15];
char selected_led = -1;
char selected_led_degs[2] = {-1, -1};
int led_blink = 0;
int hide_not_selected = 0;
unsigned char led_blink_all = 0;

void led_init() {
	for (unsigned char i = 0; i < 15; i++) {
		led_buff[i] = 17;
	}
	
	DDRC = 0xff;
	DDRA = d_mask_A;
	DDRB = d_mask_B;
	DDRD = d_mask_D;
	
	TCCR1B = (1<<CS10); // настраиваем делитель
	TIMSK |= (1<<TOIE1);  // разрешаем прерывание по переполнению таймера
	TCNT1 = TCNT1_VAL;        // выставляем начальное значение TCNT1
}

unsigned char chars[20] = {0b10110111, // 0
                           0b10100000, // 1
 						   0b11000111, // 2
 						   0b11100110, // 3
  						   0b11110000, // 4
						   0b01110110, // 5
						   0b01110111, // 6
						   0b10100100, // 7
						   0b11110111, // 8
						   0b11110110, // 9
						   0b11110101, // A
						   0b01110011, // B
						   0b00010111, // C
						   0b11100011, // D
						   0b01010111, // E
						   0b01010101, // F
						   0b00000000, // " "
						   0b01000000, // -
						   0b10010100, // >
						   0b00100011};// <
						   
void outChar(unsigned char num) {	
	PORTA |= d_mask_A;
	PORTB |= d_mask_B;
	PORTD |= d_mask_D;
	PORTC = 0;
	switch (num) {
		case 0:
			PORTB &= ~(1<<7);
			break;
		case 1:
			PORTD &= ~(1<<0);
			break;
		case 2:
			PORTD &= ~(1<<1);
			break;
		case 3:
			PORTB &= ~(1<<4);
			break;
		case 4:
			PORTB &= ~(1<<5);
			break;
		case 5:
			PORTB &= ~(1<<6);
			break;
		case 6:
			PORTB &= ~(1<<0);
			break;
		case 7:
			PORTB &= ~(1<<1);
			break;
		case 8:
			PORTB &= ~(1<<2);
			break;
		case 9:
			PORTA &= ~(1<<2);
			break;
		case 10:
			PORTA &= ~(1<<3);
			break;
		case 11:
			PORTA &= ~(1<<4);
			break;
		case 12:
			PORTA &= ~(1<<5);
			break;
		case 13:
			PORTA &= ~(1<<6);
			break;
		case 14:
			PORTA &= ~(1<<7);
			break;
	}
	
	unsigned char draw_led = 0;
	
	led_blink++;
	char led_num = num / 3;
	
	if (!hide_not_selected) {
		if (!led_blink_all) {
			if ((selected_led == led_num || selected_led_degs[0] == num || selected_led_degs[1] == num) && led_blink > BLINK_TIME) {
				//
			} else {
				if (led_blink > (BLINK_TIME + BLINK_TIME))
					led_blink = 0;
				draw_led = 1;
			}
		} else {
			if (led_blink < BLINK_TIME) {
				draw_led = 1;
			} else {
				if (led_blink > (BLINK_TIME + BLINK_TIME))
					led_blink = 0;
			}
		}		
	} else {
		if (selected_led == led_num) {
			draw_led = 1;
		}
	}
	
	if (draw_led) {
		PORTC = chars[led_buff[num] & 0b00011111];
	
		if (led_buff[num] & 0b00100000) {
			PORTC |= 0b00001000;
		}
	}
}

void write_num(unsigned char dec_num, float val) {	
	if (val < 0) {
		led_buff[dec_num * 3] = 17;
		led_buff[dec_num * 3 + 1] = 17;
		led_buff[dec_num * 3 + 2] = 17;
		return ;
	}
	
	int v = floor(val * 10);
	unsigned char v1 = v / 100;
	v -= v1 * 100;
	unsigned char v2 = v / 10;
	v -= v2 * 10;
	unsigned char v3 = v;
	
	if (v1 == 0)
		v1 = 16;
	
	led_buff[dec_num * 3] = v1;
	led_buff[dec_num * 3 + 1] = v2 | 0b00100000;
	led_buff[dec_num * 3 + 2] = v3;
}

unsigned char curr_deg = 0;

ISR(TIMER1_OVF_vect)
{
	TCNT1 = TCNT1_VAL; //выставляем начальное значение TCNT1
	outChar(curr_deg);
	curr_deg++;
	
	if (curr_deg > 15) curr_deg = 0;
}