
import usb.core
import os
from glob import glob
from typing import List
from pathlib import Path
import usb.backend.libusb1
#from pyftdi.ftdi import Ftdi
import usb

def main1():
  def find_library(name: str):
          """A callback for looking up the libusb backend file."""
          print(f"{name=}")
          pattern = Path(f"/Users/user/.apio/packages/oss-cad-suite/lib/{name}*")
          files = glob(str(pattern))
          print(f"{files=}")
          #  assert len(files) <= 1, files
          if files:
              print(f"{type(files[0])}")
              print(f"{files[0]}")
              return files[0]
          return None


  backend = usb.backend.libusb1.get_backend(find_library=find_library)

  devices: List[usb.core.Device] = usb.core.find(find_all=True, backend=backend)

  for i, d in enumerate(devices):
    print(f"\n\n==== Device {i}")
    print(str(d))

def main2():
  # def find_library(name: str):
  #         """A callback for looking up the libusb backend file."""
  #         print(f"{name=}")
  #         pattern = Path(f"/Users/user/.apio/packages/oss-cad-suite/lib/{name}*")
  #         files = glob(str(pattern))
  #         print(f"{files=}")
  #         #  assert len(files) <= 1, files
  #         if files:
  #             print(f"{type(files[0])}")
  #             print(f"{files[0]}")
  #             return files[0]
  #         return None


  # backend = usb.backend.libusb1.get_backend(find_library=find_library)

  os.environ["DYLD_LIBRARY_PATH"] = "/Users/user/.apio/packages/oss-cad-suite/lib"
  
  devices: List[usb.core.Device] = usb.core.find(find_all=True)

  for i, d in enumerate(devices):
    print(f"\n\n==== Device {i}")
    print(str(d))


# main1()

main2()