

cd
esp_dir="AppData/Local/Arduino15/packages/esp32"
esp_bin="${esp_dir}/tools/esptool_py/2.6.1/esptool.exe"

pwd
ls -l $esp_bin


exit 1

cd %userprofile%
cd AppData\Local\Arduino15\packages\esp32

tools\esptool_py\2.6.1\esptool.exe

--chip esp32

--port COM3

--baud 921600 
--before default_reset
--after hard_reset write flash
-s 
--flash_mode dio
--flash_freq 80m
--flash_size detect 

0xe000 hardware\esp32\1.0.4\tools\partitions\boot_app0.bin
0x100 hardware\esp32\1.0.4\tools\sdk\bin\bootloader_qio_80m.bin
0x10000 ???
0x8000


