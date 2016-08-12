/*
 * ow_utils.h
 *
 * Created: 05.08.2016 8:29:58
 *  Author: Александр
 */ 

#define OW_SEARCH_ROM 0xF0
#define OW_ALARM_SEARCH 0xEC
#define OW_MATCH_ROM 0x55
#define OW_READ_DATA 0xA0
#define OW_WRITE_DATA 0xB0

unsigned char crc_table(unsigned char data) {
	unsigned char crc = 0x0;
	unsigned char fb_bit = 0;
	for (unsigned char b = 0; b < 8; b++) { 
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