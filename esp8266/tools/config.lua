print("config")

wifi.setmode(wifi.STATION)
wifi.sta.autoconnect(0)
  
file.open("_config", "r")
local ssid = file.readline():gsub("%c", "")
local password = file.readline():gsub("%c", "")
file.close()
print("["..ssid.."]["..password.."]")
wifi.sta.config(ssid, password)

