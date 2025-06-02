import winreg
import wmi

def get_usb_serial_devices():
    c = wmi.WMI()
    for device in c.Win32_PnPEntity():
        if device.Name and "COM" in device.Name:
            print(f"Detected: {device.Name}")
            # Get the device ID (e.g. USB\VID_0403&PID_6001\FT123456)
            device_id = device.PNPDeviceID
            print(f"  Device ID: {device_id}")
            
            # Parse registry to find manufacturer/product strings
            try:
                reg_path = f"SYSTEM\\CurrentControlSet\\Enum\\{device_id.replace('\\', '\\\\')}"
                with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, reg_path) as key:
                    mfg, _ = winreg.QueryValueEx(key, "Mfg")
                    desc, _ = winreg.QueryValueEx(key, "DeviceDesc")
                    friendly, _ = winreg.QueryValueEx(key, "FriendlyName")
                    print(f"  Manufacturer: {mfg}")
                    print(f"  Product: {desc}")
                    print(f"  Friendly Name: {friendly}")
            except Exception as e:
                print(f"  [!] Failed to read registry: {e}")
            print()

get_usb_serial_devices()

