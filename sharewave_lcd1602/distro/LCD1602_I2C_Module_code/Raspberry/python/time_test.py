import LCD1602
import time

lcd=LCD1602.LCD1602(16,2)

try:
    while True:
        # set the cursor to column 0, line 1
        lcd.setCursor(0, 0)
        # print the number of seconds since reset:

        # print the number of seconds since reset:
        T=time.ctime().split()
        lcd.printout(T[-1]+' '+T[1]+' '+T[2]+' '+T[0])

        lcd.setCursor(0, 1)

        lcd.printout(T[3])
        time.sleep(0.1)
except(KeyboardInterrupt):
    lcd.clear()
    del lcd
