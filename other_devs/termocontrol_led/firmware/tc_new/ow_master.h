/*
 * one_wire.h
 *
 * Created: 03.08.2016 8:15:10
 *  Author: Александр
 */ 

#define F_CPU 8000000UL

#define OW_M_DDR DDRD
#define OW_M_PORT PORTD
#define OW_M_PIN PIND
#define OW_M_BIT 2

#define	OW_M_SEARCH_FIRST	0xFF		// start new search
#define	OW_M_PRESENCE_ERR	0xFF
#define	OW_M_DATA_ERR	    0xFE
#define OW_M_LAST_DEVICE	0x00

#define THERM_CMD_CONVERTTEMP 0x44
#define THERM_CMD_RSCRATCHPAD 0xBE

unsigned char ow_master_roms[5][8];
float ow_master_values[5] = {-100, -100, -100, -100, -100};

void ow_master_init() {
	OW_M_DDR &= ~(1<<OW_M_PIN);
}

void OW_M_set(unsigned char mode) {
	if (mode) {
		OW_M_PORT &= ~(1<<OW_M_BIT);
		OW_M_DDR |= (1<<OW_M_BIT);
	} else {
		OW_M_PORT &= ~(1<<OW_M_BIT);
		OW_M_DDR &= ~(1<<OW_M_BIT);
	}
}

unsigned char OW_M_checkIn(void)
{
	return OW_M_PIN & (1<<OW_M_BIT);
}

unsigned char OW_M_reset(void)
{
	unsigned char status;
	OW_M_set(1);
	_delay_us(480);
	OW_M_set(0);
	_delay_us(60);	
	status = OW_M_checkIn();
	_delay_us(420);
	return !status;
}


void OW_M_writeBit(unsigned char bit)
{
	OW_M_set(1);
	_delay_us(1);
	if(bit) 
		OW_M_set(0); 
	_delay_us(60);	
	OW_M_set(0);
}

unsigned char OW_M_readBit(void)
{
	unsigned char bit=0;
	OW_M_set(1);
	_delay_us(1);	
	OW_M_set(0);
	_delay_us(14);	
	if(OW_M_checkIn()) 
		bit=1;
	_delay_us(45);
	return bit;
}

void OW_M_writeByte(unsigned char byte)
{
	for (unsigned char i=0; i<8; i++) 
		OW_M_writeBit(byte & (1<<i));
}

unsigned char OW_M_readByte(void)
{
	unsigned char n=0;
	for (unsigned char i=0; i<8; i++) 
		if (OW_M_readBit()) 
			n |= (1<<i);	
	return n;
}

unsigned char OW_M_searchROM( unsigned char diff, unsigned char *id ) { 	
	unsigned char i, j, next_diff;
	unsigned char b;

	if(!OW_M_reset())
		return OW_M_PRESENCE_ERR;       // error, no device found

	OW_M_writeByte(OW_SEARCH_ROM);     // ROM search command
	next_diff = OW_M_LAST_DEVICE;      // unchanged on last device
	
	i = 64;
	do {	
		j = 8;
		do { 
			b = OW_M_readBit();
			if (OW_M_readBit()) {
				if (b)
					return OW_M_DATA_ERR;
			} else { 
				if (!b) { 
					if (diff > i || ((*id & 1) && diff != i)) { 
						b = 1;
						next_diff = i;
					}
				}
			}
			OW_M_writeBit(b);
			*id >>= 1;
			if( b ) 
				*id |= 0x80;
			i--;
		} while(--j);
		id++;
    } while(i);
	return next_diff;
}

void OW_M_scan_devs() {
	cli();
	
   	unsigned char id[8];
   	unsigned char diff, count;
	count = 0;

	for (diff = OW_M_SEARCH_FIRST; diff != OW_M_LAST_DEVICE && count < 5;) {
		diff = OW_M_searchROM(diff, &id[0]);

      	if (diff == OW_M_PRESENCE_ERR) break;
      	if (diff == OW_M_DATA_ERR) break;
		  		 
		for (char i=0; i<8; i++)
			ow_master_roms[count][i] = id[i];
		count++;
    }

	for (char i=count; i<5; i++)
		ow_master_roms[i][0] = 0x0;
		
	sei();
}

unsigned char OW_M_matchROM(unsigned char *rom) {
 	if (!OW_M_reset()) return 0;
	OW_M_writeByte(OW_MATCH_ROM);	
	for(unsigned char i=0; i<8; i++)
		OW_M_writeByte(rom[i]);
	return 1;
}


unsigned char OW_M_set_measPause = 1;
unsigned char OW_M_measPause = 0;
unsigned char OW_M_currDev = 0;

float getTemp(unsigned char *rom) {
	if (!OW_M_reset()) {
		return -100;
	}
	OW_M_matchROM(rom);
	OW_M_writeByte(THERM_CMD_RSCRATCHPAD);	
	unsigned char d[8];
	unsigned char crc = 0;
	for (unsigned char i = 0; i < 8; i++) {
		d[i] = OW_M_readByte();
		crc = crc_table(crc ^ d[i]);
	}	
	
	if (crc == OW_M_readByte()) {
		return (d[1] << 8 | d[0]) / 16.0;
	}	
	return -100;
}

void checkTemp() {
	OW_M_measPause--;
	if (OW_M_measPause > 0)
		return 0;
	cli();
	PORTC = 0;
	OW_M_measPause = OW_M_set_measPause;
	unsigned char data[2];
	if (ow_master_roms[OW_M_currDev][0] != 0) {
		ow_master_values[OW_M_currDev] = getTemp(ow_master_roms[OW_M_currDev]);
	} else
		ow_master_values[OW_M_currDev] = -100;
	
	OW_M_currDev++;
	if (OW_M_currDev > 4)
		OW_M_currDev = 0;
		
	if (ow_master_roms[OW_M_currDev][0] != 0 && OW_M_reset()) {
		OW_M_matchROM(ow_master_roms[OW_M_currDev]);
		OW_M_writeByte(THERM_CMD_CONVERTTEMP);
	}
	sei();
}

void OW_M_startLoading() {
	for (unsigned char i = 0; i < 10; i++) {
		OW_M_measPause = 1;
		checkTemp();
		_delay_ms(100);
	}
}


