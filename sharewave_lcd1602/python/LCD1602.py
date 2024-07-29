# -*- coding: utf-8 -*-
import time
from i2c_adapter import I2cAdapter


# from smbus import SMBus

port = "/dev/tty.usbmodem1401"
d = I2cAdapter(port="/dev/tty.usbmodem1401")

# b = SMBus(1)

# Device I2C Arress
LCD_ADDRESS = 0x7C >> 1

LCD_CLEARDISPLAY = 0x01
LCD_RETURNHOME = 0x02
LCD_ENTRYMODESET = 0x04
LCD_DISPLAYCONTROL = 0x08
LCD_CURSORSHIFT = 0x10
LCD_FUNCTIONSET = 0x20
LCD_SETCGRAMADDR = 0x40
LCD_SETDDRAMADDR = 0x80

# flags for display entry mode
LCD_ENTRYRIGHT = 0x00
LCD_ENTRYLEFT = 0x02
LCD_ENTRYSHIFTINCREMENT = 0x01
LCD_ENTRYSHIFTDECREMENT = 0x00

# flags for display on/off control
LCD_DISPLAYON = 0x04
LCD_DISPLAYOFF = 0x00
LCD_CURSORON = 0x02
LCD_CURSOROFF = 0x00
LCD_BLINKON = 0x01
LCD_BLINKOFF = 0x00

# flags for display/cursor shift
LCD_DISPLAYMOVE = 0x08
LCD_CURSORMOVE = 0x00
LCD_MOVERIGHT = 0x04
LCD_MOVELEFT = 0x00

# flags for function set
LCD_8BITMODE = 0x10
LCD_4BITMODE = 0x00
LCD_2LINE = 0x08
LCD_1LINE = 0x00
LCD_5x8DOTS = 0x00


class LCD1602:
    def __init__(self, col, row):
        self._row = row
        self._col = col
        self._showfunction = LCD_4BITMODE | LCD_1LINE | LCD_5x8DOTS
        self.begin(self._row, self._col)

    def _write_command_byte(self, cmd):
        # b.write_byte_data(LCD_ADDRESS,0x80,cmd)
        ok = d.write(LCD_ADDRESS, bytearray([0x80, cmd]))
        assert ok

    def _write_data_byte(self, data):
        # b.write_byte_data(LCD_ADDRESS,0x40,data)
        ok = d.write(LCD_ADDRESS, bytearray([0x40, data]))
        assert ok

    def setCursor(self, col, row):
        if row == 0:
            col |= 0x80
        else:
            col |= 0xC0
        self._write_command_byte(col)

    def clear(self):
        self._write_command_byte(LCD_CLEARDISPLAY)
        time.sleep(0.002)

    def printout(self, arg):
        if isinstance(arg, int):
            arg = str(arg)

        for x in bytearray(arg, "utf-8"):
            self._write_data_byte(x)

    def display(self):
        self._showcontrol |= LCD_DISPLAYON
        self._write_command_byte(LCD_DISPLAYCONTROL | self._showcontrol)

    def begin(self, cols, lines):
        if lines > 1:
            self._showfunction |= LCD_2LINE

        self._numlines = lines
        self._currline = 0

        time.sleep(0.05)

        # Send function set command sequence
        self._write_command_byte(LCD_FUNCTIONSET | self._showfunction)
        # delayMicroseconds(4500);  # wait more than 4.1ms
        time.sleep(0.005)
        # second try
        self._write_command_byte(LCD_FUNCTIONSET | self._showfunction)
        # delayMicroseconds(150);
        time.sleep(0.005)
        # third go
        self._write_command_byte(LCD_FUNCTIONSET | self._showfunction)
        # finally, set # lines, font size, etc.
        self._write_command_byte(LCD_FUNCTIONSET | self._showfunction)
        # turn the display on with no cursor or blinking default
        self._showcontrol = LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF
        self.display()
        # clear it off
        self.clear()
        # Initialize to default text direction (for romance languages)
        self._showmode = LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT
        # set the entry mode
        self._write_command_byte(LCD_ENTRYMODESET | self._showmode)
