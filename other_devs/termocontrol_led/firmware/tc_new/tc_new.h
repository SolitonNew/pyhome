/*
 * tc_new.h
 *
 * Created: 05.08.2016 20:49:53
 *  Author: Александр
 */ 


#define switch_ddr DDRB
#define switch_port PORTB
#define switch_pin 3
#define switch_delta 5 // Коридор для клапана в градусах

#define rele_ddr DDRA
#define rele_port PORTA
#define rele_main_pin PORTA0
#define rele_tp_pin PORTA1

#define btn_ddr DDRD
#define btn_pin PIND
#define btn_port PORTD
#define btn_sel_pin 4
#define btn_up_pin 5
#define btn_down_pin 6
#define btn_sel_delay 20
#define btn_delay 5

#define btns_is_push (~btn_pin & ((1<<btn_up_pin)|(1<<btn_down_pin)))

/* 
0 - рабочий режим; 
10 - настройка условий;
20 - сканирование OW; 21 - настройка термометров; 
*/
unsigned char regim = 0; 
unsigned char cancel_slave_ow = 0;

#define sound_mute_time 1500;
unsigned int sound_mute = 0;