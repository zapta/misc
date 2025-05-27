
import usb.core
from glob import glob
from pathlib import Path
import usb.backend.libusb1
from pyftdi.ftdi import Ftdi
import usb

# def find_library(name: str):
#         """A callback for looking up the libusb backend file."""
#         pattern = Path(f"/Users/user/.apio/packages/oss-cad-suite/lib/{name}*")
#         files = glob(str(pattern))
#         print(f"{files=}")
#         assert len(files) <= 1, files
#         if files:
#             return files[0]
#         return None


# backend = usb.backend.libusb1.get_backend(find_library=find_library)

# print(f"{backend=}")

# Ftdi.use_backend(backend)

devices = Ftdi.list_devices()
print(devices)