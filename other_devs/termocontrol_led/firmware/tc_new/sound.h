/*
 * sound.h
 *
 * Created: 02.08.2016 18:53:43
 *  Author: Александр
 */

#define speak_ddr DDRD
#define speak_port PORTD
#define speak_pin 7

unsigned char signals[3] = {0, 0, 0};

unsigned char signal_1_trak[2] = {2,60};
unsigned char signal_2_trak[4] = {2,1,2,60};
unsigned char signal_3_trak[2] = {2,2};
	
char signals_pos[3] = {-1, -1, -1};
unsigned char signals_val[3] = {0, 0, 0};
	
#define one_second 2 //494
unsigned int current_time = 0;

void sound_init() {
	OCR2 = 190; // 190
	TCCR2 = (1<<COM21)|(1<<WGM20)|(1<<WGM21)|(1<<CS22)|(1<<CS20);
	TIMSK |= (1<<TOIE2);
}

unsigned int sound_duration = 0;

void sound_play(int duration) {
	//sound_duration = 0.494 * duration;
	sound_duration = duration / 100;
}

unsigned char check_signal(unsigned char num, unsigned char trak[], unsigned char len, unsigned int dur) {
	if (signals[num]) {
		if (signals_pos[num] == -1) {
			signals_pos[num] = 0;
			signals_val[num] = 0;
		}
			
		if (signals_val[num] == 0) {
			signals_pos[num]++;
			if (signals_pos[num] > len - 1)
				signals_pos[num] = 0;
			signals_val[num] = trak[signals_pos[num]];
		} else {
			signals_val[num]--;
			if (signals_pos[num]%2 == 0)
				sound_play(dur);
		}
	} else {
		signals_pos[num] = -1;
	}
	
	return signals[num];
}

void sound_player() {
	if (sound_duration > 0) {
		speak_ddr |= (1<<speak_pin);
		sound_duration--;
	} else {
		speak_ddr &= ~(1<<speak_pin);
	}
	
	if (!sound_mute) {
		if (current_time == 0) {
			current_time = one_second;
			if (!check_signal(2, signal_3_trak, 2, 500))
				if (!check_signal(1, signal_2_trak, 4, 250))			
					check_signal(0, signal_1_trak, 2, 500);
		} else {
			current_time--;
		}
	} else 
		sound_mute--;
}

ISR(TIMER2_OVF_vect) {
	TCNT2 = 127; //выставляем начальное значение TCNT2
}