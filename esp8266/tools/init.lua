uart.setup(0, 115200, 8, 0, 1, 1)
-- Using Pin 4 (GPIO 2) to disable app activation if something
-- go wrong. To disable, pull it down to ground.
gpio.mode(4, gpio.INPUT, gpio.PULLUP)
-- Let the uart and the GPIO pin stabalize.
tmr.delay(100000)
print("\n\ninit.lua 115200")
local pin_value = gpio.read(4)
print("gpio2 level: " .. pin_value)
if (gpio.read(4) == 1) then
  dofile("config.lua")
  dofile("conn.lua")
end

