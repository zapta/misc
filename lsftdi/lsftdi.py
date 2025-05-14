
from pyftdi.ftdi import Ftdi

devices = Ftdi.list_devices()
if not devices:
    print("No FTDI devices found.")
else:
    for device in devices:
        print(device)
        # Each device is a tuple: (vendor, product, serial)
        #print(f"Vendor: {device[0]}")
        #print(f"Product: {device[1]}")
        #print(f"Serial: {device[2]}")

