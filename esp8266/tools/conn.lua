-- Cloud connection module. Responsible for connecting to the WIFI access
-- point and maintaining a persistent connection with the cloud server.
--
-- Uses timer 1.

local conn = {}

-- Credentials are comming from a seperate file that is not checkedin in git
-- and can be customized for each deployment.
credentials = require "_credentials"

-- Connection states
STATE_IDLE = 0
STATE_CONNECT_WIFI = 1
STATE_WAIT_WIFI = 2
STATE_WAIT_SOCKET = 3
STATE_CONNECTED = 4
STATE_DISCONNECTED = 5

state = STATE_IDLE

ticks_in_state = 0

socket = nil

function setState(new_state)
  print("state "..state.." -> "..new_state)
  state = new_state
  ticks_in_state = 0
end

function disconnect()
  if socket then
    socket:close()
    socket = nil;
  end
  wifi.sta.disconnect()
  setState(STATE_DISCONNECTED)
end

function conn.start()
  print("conn.start")

  wifi.setmode(wifi.STATION)
  wifi.sta.autoconnect(0)
  disconnect()
  
  ssid, password = credentials.wifi()
  -- print("["..ssid.."]["..password.."]")
  wifi.sta.config(ssid, password)

  setState(STATE_CONNECT_WIFI)
  tmr.alarm(1, 1000, 1, onTick)
end

function onTickStateConnectWifi()
  print("# CONNECT_WIFI")
  wifi.sta.connect()
  setState(STATE_WAIT_WIFI)
end

function onTickStateWaitWifi()
  status = wifi.sta.status()
  print("# WAIT_WIFI " .. ticks_in_state .. " " .. status)
  if status == 1 then
    return 
  end

  if status == 5 then
    setState(STATE_WAIT_SOCKET)
    socket = net.createConnection(net.TCP, 0)
    socket:on("receive", function(socket, str) print(string.format("RECEIVED %04d", string.len(str))) end)
    socket:on("connection", function(socket) print("CONNECTED") setState(STATE_CONNECTED) end)
    socket:on("reconnection", function(socket) print("RECONNECTED") setState(STATE_CONNECTED) end)
    socket:on("disconnection", function(socket) print("DISCONNECTED") disconnect() end)
    socket:on("sent", function(socket) print("SENT") end) 
    print("Connecting TCP")
    socket:connect(9000, "192.168.0.90")
    return
  end

  print("AP connection error (" .. status .. ")")
  disconnect()
end

function onTickStateWaitSocket()
  print("# WAIT_SOCKET " .. ticks_in_state)
  -- This state is exit by the on:connection event.
end

function onTickStateConnected()
  if (ticks_in_state % 10) == 0 then
    print("# CONNECTED " .. ticks_in_state)
  end
end

function onTickStateDisconnected()
  if (ticks_in_state % 10) == 0 then
    print("# DISCONNECTED " .. ticks_in_state)
  end
  -- TODO: initiate auto reconnection
end

state_table = {
  [STATE_IDLE] = onTickStateIdle,
  [STATE_CONNECT_WIFI] = onTickStateConnectWifi,
  [STATE_WAIT_WIFI] = onTickStateWaitWifi,
  [STATE_WAIT_SOCKET] = onTickStateWaitSocket,
  [STATE_CONNECTED] = onTickStateConnected,
  [STATE_DISCONNECTED] = onTickStateDisconnected,
}

function onTick()
  state_table[state]()
  ticks_in_state = ticks_in_state + 1
end


return conn
