
# Usage:
#   pip install pyserial
#   python comports-test.py

from serial.tools.list_ports import comports

ports = comports()

for port in ports:
  if port.device and port.vid and port.pid:
    print(
        f"ID=[{port.vid:04X}:{port.pid:04X}] " + 
        f"Port=[{port.device}] " + 
        f"Manuf=[{port.manufacturer}] " + 
        f"Prod=[{port.product}] " +
        f"Ifc=[{port.interface}] " +
        f"S/N=[{port.serial_number}]")


