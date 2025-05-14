
import ftd2xx as ft

# ftd_devices = ft.listDevices()
# print(f"{ftd_devices=}")
# if ftd_devices:
#     print(f"{type(ftd_devices[0])=}")
#     print(f"{ftd_devices[0]=}")

# Get the number of connected FTDI devices

num_devices = ft.createDeviceInfoList()

if num_devices == 0:
    print("No FTDI devices found.")
else:
    print(f"Found {num_devices} FTDI device(s):")
    
    for i in range(num_devices):
        info = ft.getDeviceInfoDetail(i)
        print(f"Device {i}:")
        print(f"  {type(info)=}")
        print(f"  {info=}")
        # print(f"  Serial Number: {info['serial']}")
        # print(f"  Description: {info['description']}")
        # print(f"  Vendor ID: {hex(info['ID'][0])}")
        # print(f"  Product ID: {hex(info['ID'][1])}")
