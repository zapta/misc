#ifndef __Waveshare_LCD1602_H__
#define __Waveshare_LCD1602_H__

#include <inttypes.h>
#include "Print.h"

/*!
 *   Device I2C Arress
 */
#define LCD_ADDRESS     (0x7c>>1)

/*!
 *   commands
 */
#define LCD_CLEARDISPLAY 0x01
#define LCD_RETURNHOME 0x02
#define LCD_ENTRYMODESET 0x04
#define LCD_DISPLAYCONTROL 0x08
#define LCD_CURSORSHIFT 0x10
#define LCD_FUNCTIONSET 0x20
#define LCD_SETCGRAMADDR 0x40
#define LCD_SETDDRAMADDR 0x80

/*!
 *   flags for display entry mode
 */
#define LCD_ENTRYRIGHT 0x00
#define LCD_ENTRYLEFT 0x02
#define LCD_ENTRYSHIFTINCREMENT 0x01
#define LCD_ENTRYSHIFTDECREMENT 0x00

/*!
 *   flags for display on/off control
 */
#define LCD_DISPLAYON 0x04
#define LCD_DISPLAYOFF 0x00
#define LCD_CURSORON 0x02
#define LCD_CURSOROFF 0x00
#define LCD_BLINKON 0x01
#define LCD_BLINKOFF 0x00

/*!
 *   flags for display/cursor shift
 */
#define LCD_DISPLAYMOVE 0x08
#define LCD_CURSORMOVE 0x00
#define LCD_MOVERIGHT 0x04
#define LCD_MOVELEFT 0x00

/*!
 *   flags for function set
 */
#define LCD_8BITMODE 0x10
#define LCD_4BITMODE 0x00
#define LCD_2LINE 0x08
#define LCD_1LINE 0x00
#define LCD_5x8DOTS 0x00


class Waveshare_LCD1602
{
public:
	Waveshare_LCD1602(uint8_t lcd_cols,uint8_t lcd_rows);
	
	void init();
	void home();
	void display();
	void command(uint8_t);
	void send(uint8_t *data, uint8_t len);
	void setCursor(uint8_t col, uint8_t row);
	void clear();
	void write_char(uint8_t value);
	void send_string(const char *str);
	void stopBlink();
	void blink();
	void noCursor();
	void cursor();
	void scrollDisplayLeft();
	void scrollDisplayRight();
	void leftToRight();
	void rightToLeft();
	void noAutoscroll();
	void autoscroll();
	void customSymbol(uint8_t location, uint8_t charmap[]);
private:
	void begin(uint8_t cols, uint8_t rows);
	uint8_t _showfunction;
	uint8_t _showcontrol;
	uint8_t _showmode;
	uint8_t _initialized;
	uint8_t _numlines,_currline;
	uint8_t _lcdAddr;
	uint8_t _RGBAddr;
	uint8_t _cols;
	uint8_t _rows;
	uint8_t _backlightval;
};
#endif