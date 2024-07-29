#include "lcd1602_Module.h"

uint8_t _showfunction;
uint8_t _showcontrol;
uint8_t _showmode;
uint8_t _numlines;
uint8_t _currline;

int fd;

void LCD1602_init(uint8_t col,uint8_t row)
{
    if ((fd = open(IIC_Dev, O_RDWR)) < 0) {
        printf("Failed to open the i2c bus\n");
    }
    if (ioctl(fd, I2C_SLAVE, LCD_ADDRESS) < 0) {
        printf("Failed to acquire bus access and/or talk to slave.\n");
        }
    _showfunction = LCD_4BITMODE | LCD_1LINE | LCD_5x8DOTS;
    begin(col,row);
}

void begin(uint8_t col, uint8_t lines)
{
    if (lines > 1) {
        _showfunction |= LCD_2LINE;
    }
    _numlines = lines;
    _currline = 0;
    
    ///< SEE PAGE 45/46 FOR INITIALIZATION SPECIFICATION!
    ///< according to datasheet, we need at least 40ms after power rises above 2.7V
    ///< before sending commands. Arduino can turn on way befer 4.5V so we'll wait 50
    usleep(50*1000);


    ///< this is according to the hitachi HD44780 datasheet
    ///< page 45 figure 23

    ///< Send function set command sequence
    command(LCD_FUNCTIONSET | _showfunction);
    usleep(10*1000);  // wait more than 4.1ms

	///< second try
    command(LCD_FUNCTIONSET | _showfunction);
    usleep(10*1000);

    ///< third go
    command(LCD_FUNCTIONSET | _showfunction);

    //command(LCD_FUNCTIONSET | _showfunction);


    ///< turn the display on with no cursor or blinking default
    _showcontrol = LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF;
    display();

    ///< clear it off
    clear();

    ///< Initialize to default text direction (for romance languages)
    _showmode = LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT;
    ///< set the entry mode
    command(LCD_ENTRYMODESET | _showmode);
}

void command(uint8_t cmd)
{
    uint8_t val[2] = {0x80,cmd};
    write(fd,val,2);
}

void display()
{
    command(LCD_DISPLAYCONTROL | _showcontrol);
    usleep(2*1000);
}

void clear()
{
    command(LCD_CLEARDISPLAY);
    usleep(2*1000);
}

void write_char(uint8_t data)
{
    uint8_t val[2] = {0x40,data};
    write(fd,val,2);
}

void send_string(const char *str)
{
	uint8_t i;
	for(i = 0; str[i] != '\0';i++)
		write_char(str[i]);
}
void setCursor(uint8_t col, uint8_t row)
{
    if(row == 0)
    {
        col |= 0x80;
    }
    else
    {
        col |= 0xc0;
    }
    command(col);
}
