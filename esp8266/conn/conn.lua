-- Cloud connection module. Responsible for connecting to the WIFI access
-- point and maintaining a persistent connection with the cloud server.
--
-- Uses timer #1.
--
-- Usage:
--   node.restart()
--   dofile("config.lua")
--   dofile("conn.lua")
--
-- TX:
--   sock:send(data_str)
--
-- RX line:
--   +xx   // xx is the byte hex value (lower case).
--
-- State line:
--   !c    // c = 0(disconnection), 1(connected)
--
--
-- When parsing lines, first strip 1 or more occurances of '> ' at the 
-- begining of the file. These are caused by the Lua prompt as result to 
-- commands such as send().
-- Lines that don't start with '+' or '!' after stripping the prompt should be ignored.
--
-- NOTE: using shorter than desired function and variable names and printed
-- messages to reduce the runtime memory footprint.

-- Connection states
S_IDLE = 0
S_CON_WIFI = 1
S_WAIT_WIFI = 2
S_WAIT_SOCK = 3
S_CONN = 4
S_DISCONN = 5

-- The socket used for the TCPIP connection.
state = S_IDLE

-- Number of ticks while in this state. 0 for first ticker
-- call, 1 for next, etc.
s_sticks = 0

sock = nil

-----------------------------------------------------------

function setState(new_state)
  --print("#"..state.."->#"..new_state)
  state = new_state
  report() 
  s_sticks = 0
end

function close()
  if sock then
    sock:close()
    sock = nil;
  end
  wifi.sta.disconnect()
end

-- Report state to the client.
function report() 
  -- Field1: '1' connected, '0' disconnected. A new connection is guaranteed
  -- to have a report transitioning from '0' to '1' so clients can detect new
  -- connections.
  local f1 = 0
  if state == S_CONN then 
    f1 = 1
  end
  print("!"..f1)
end

-----------------------------------------------------------

-- Handle the connect to WIFI event
function sConnectWifi()
  wifi.sta.connect()
  setState(S_WAIT_WIFI)
end

-- Callback for sock:on("recieve"). 
-- Assuming without verification that it's comes from the current socket.
function onRx(sock, str) 
  for i = 1, #str do
    local b = string.byte(str, i)
    print(string.format("+%02x", b))
  end
end

 -- Set event callbacks for a new socket.
function setEvents(sock)
  sock:on("receive", onRx)
  sock:on("connection", 
      function(sock) 
        print("CON") 
        setState(S_CONN) 
      end)
  sock:on("reconnection", 
      function(sock) 
        print("RECON") 
        setState(S_CONN) 
      end)
  sock:on("disconnection", 
      function(sock) 
        print("DISCON") 
        setState(S_DISCONN)
      end)
  -- NOTE: not using the "sent" callback.
end

-- Handle wait for wifi connection state.
function sWaitWifi()
  local st = wifi.sta.status()
  -- 1 is the 'connecting' state.
  if st == 1 then
    return 
  end

  -- 5 is the 'connected' state.
  if st == 5 then
    sock = net.createConnection(net.TCP, 0)
    setEvents(sock)
    setState(S_WAIT_SOCK)
    sock:connect(gw_port, gw_host)
    return
  end

  -- The rest are error.
  print("WIFI ERR " .. st)
  setState(S_DISCONN)
end

-- Handle wait for socket connection.
function sWaitSock()
  -- Exit by the on connection event.
end

-- Handle the connected state.
function sConn()
  -- Exit by connection failure or stop.
end

-- Handle the disconnected state.
function sDisconn()
  -- Clear resources at first tick.
  if s_sticks == 0 then
    close()
  -- Reconnect after 10 ticks.
  elseif s_sticks == 10 then
    setState(S_CON_WIFI)
  end
end

-----------------------------------------------------------

state_table = {
  [S_CON_WIFI] = sConnectWifi,
  [S_WAIT_WIFI] = sWaitWifi,
  [S_WAIT_SOCK] = sWaitSock,
  [S_CONN] = sConn,
  [S_DISCONN] = sDisconn,
}

-- Periodic ticks handler/dispatcher.
function onTick()
  report() 
  state_table[state]()
  s_sticks = s_sticks + 1
end

-- Assumes dofile("config.lua") was run.
print("conn.start")
close()
setState(S_CON_WIFI)
tmr.alarm(1, 1000, 1, onTick)
