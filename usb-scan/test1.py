import ftd2xx

for i in range(30):
  dev = ftd2xx.open(i)
  info = dev.getDeviceInfo()
  print(info)

