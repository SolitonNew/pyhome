/*
 * ow_slave.h
 *
 * Created: 05.08.2016 8:11:24
 *  Author: Александр
 */ 

#define OW_S_DDR DDRD
#define OW_S_READ PIND
#define OW_S_PIN 3

#define OW_S_UP OW_S_DDR &= ~(1 << OW_S_PIN)
#define OW_S_DOWN OW_S_DDR |= (1 << OW_S_PIN)
#define IS_S_LOW ((OW_S_READ & (1 << OW_S_PIN)) == 0)
#define IS_S_HIGH (OW_S_READ & (1 << OW_S_PIN))

#define WAIT_S_COUNT 1000
#define WAIT_S_FOR_LOW for (int i = 0; i < WAIT_S_COUNT && IS_S_HIGH; i++)
#define WAIT_S_FOR_HIGH for (int i = 0; i < WAIT_S_COUNT && IS_S_LOW; i++)

unsigned int ow_s_alarm_interval = 0;
unsigned char cancel_slave_ow = 0;

unsigned char OW_S_ROM[8] = {0xE0,0x00,0x00,0x00,0x00,0x00,0x01,0x0};
	
void ow_slave_init() {
	unsigned char crc = 0;
	for (unsigned char i = 0; i < 7; i++)
		crc = (crc_table(crc ^ OW_S_ROM[i]));
	OW_S_ROM[7] = crc;
	// Шина
	OW_S_DDR &= ~(1<<OW_S_PIN);
	
	
	MCUCR = (1<<ISC11); //Сброс ISC00 - прерывание по \__
	GICR |= (1<<INT1);
	
	/*TIFR |= 1<<TOV0;
	GIFR |= 1<<INTF0;
	TIMSK |= (1<<TOIE0);*/
}

unsigned char OW_S_readBit() {
	unsigned char res = 0;
	WAIT_S_FOR_LOW;
	_delay_us(20);	
	if (IS_S_HIGH) res = 1;
	WAIT_S_FOR_HIGH;
	return res;
}

unsigned char OW_S_readByte() {
	unsigned char res = 0;
	WAIT_S_FOR_HIGH;
	for (unsigned char i = 0; i < 8; i++) {
		res = res >> 1;
		if (OW_S_readBit())
			res |= 0x80;
	}
	return res;
}

void OW_S_writeBit(unsigned char b) {	
	WAIT_S_FOR_LOW;
	OW_S_UP;
	//_delay_us(1);
	if (b == 0) OW_S_DOWN;	
	_delay_us(60);
	OW_S_UP;
	WAIT_S_FOR_HIGH;
}

void OW_S_writeByte(unsigned char data) {
	WAIT_S_FOR_HIGH;
	for (unsigned char i = 0; i < 8; i++) {
		OW_S_writeBit(data & 1);
		data >>= 1;
	}
}

void OW_S_action() {
	WAIT_S_FOR_HIGH;
	_delay_us(30);
	OW_S_DOWN;
	_delay_us(100);
	OW_S_UP;		
	WAIT_S_FOR_HIGH;
	
	unsigned char i;
	unsigned char k;
	unsigned char count;
	unsigned char crc = 0;
	
	unsigned char rom_cmd = OW_S_readByte();
	
	// -----------------------------------
	//ow_master_values[4] = rom_cmd / 10.0;
	// -----------------------------------

	switch (rom_cmd) {
		case OW_SEARCH_ROM: // Поиск устройств на шине
		case OW_ALARM_SEARCH: // Поиск устройств с флагом ALARM
			if (rom_cmd == OW_ALARM_SEARCH && cancel_slave_ow)
				return ;
		
			for (i = 0; i < 8; i++) {	
				unsigned char b = OW_S_ROM[i];
				for (k = 0; k < 8; k++) {			
					unsigned char wb = (b & 1);
					OW_S_writeBit(wb);
					OW_S_writeBit(!wb);									
					unsigned char rb = OW_S_readBit();
					if (rb != wb)
						return ;			
					b >>= 1;
				}
			}				
			break; 
		
		case OW_MATCH_ROM: // Выбор устройства
			// Проверем ключ устройства
			for (i = 0; i < 8; i++) 
				if (OW_S_readByte() != OW_S_ROM[i])
					return ;
									
			// Читаем комманду для этого устройства			
			switch (OW_S_readByte()) {
				case OW_READ_DATA: // Чтение данных для мастера
					crc = 0;
					for (unsigned char i = 0; i < 5; i++) {
						float v = ow_master_values[i];
						char v1 = ceil(v);
						char v2 = floor((v - v1) * 100);
						OW_S_writeByte(v1);
						crc = crc_table(crc ^ v1);
						OW_S_writeByte(v2);
						crc = crc_table(crc ^ v2);
					}				
					OW_S_writeByte(crc);
					ow_s_alarm_interval = 0;
					break; 
			}			
			break;			
		default: ;
	}
}

unsigned char ow_s_timer_on = 1;
	
ISR (INT1_vect) {
	if ((MCUCR & (1<<ISC10))!=0) {
		ow_s_timer_on = 0;
		//TCNT0 = 0;
		//TCCR0 = 0; //Выключаем таймер
		//TIFR |= (1<<TOV0);
		MCUCR = (1<<ISC11); //Сброс ISC00 - прерывание по \__
	} else {		
		TCNT0 = 255-50;
		ow_s_timer_on = 1;
		//TIFR |= (1<<TOV0); //Сброс флага TOV0
		TIMSK |= (1<<TOIE0);
		MCUCR = (1<<ISC11)|(1<<ISC10); // прерывание по __/
		//TCCR0 = (1<<CS01)|(1<<CS00); //Делитель на 64		
	}
}

ISR (TIMER0_OVF_vect) {
	if (regim != 0) return ;
	if (ow_s_alarm_interval < 60000 && !cancel_slave_ow) {
		ow_s_alarm_interval++;
		return ;
	}	
	
	if (ow_s_timer_on) {
		ow_s_timer_on = 0;		
		PORTC = 0x0;
		OW_S_action();
	}
	//TCCR0 = 0;
	//TIFR |= 1<<TOV0;
}
