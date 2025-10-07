![QuantumROM Logo](QuantumROM/logo/QuantumROM.jpg)

# Tools Features:
**Direct Firmware Download:**
Seamlessly fetch the latest firmware directly from Samsung’s official servers.

**Image Unpack & Repack:**
Efficiently extract and reassemble .img files with precision and ease.

**Security Removal:**
Tools to bypass or remove security restrictions for enhanced customization.

**ROM Debloat:**
Remove unwanted pre-installed apps and optimize device performance.

![QuantumROM Logo](QuantumROM/logo/linux.jpeg)
# Usage: #
**First-time setup – install required packages:**
```bash
sudo chmod +x ./scripts/install_packages.sh && sudo bash ./scripts/install_packages.sh
```

1:  **Download and modify the ROM:**
```bash
sudo chmod +x mod_rom_1.sh
```
```bash
sudo bash mod_rom_1.sh DEVICE_MODEL CSC IMEI
```

2:  **Modifying a previously downloaded ROM:**

Run ```setup_directories.sh``` to create the necessary directories.

Copy the firmware ZIP file into the ```fw_download``` folder.

```DEVICE_MODEL``` refers to the firmware file name. Rename the firmware ZIP to match your actual device model, for example: ```SM-A225F.zip```.

In the command line, use the firmware file name without the .zip extension as ```DEVICE_MODEL```.

```bash
sudo chmod +x ./scripts/setup_directories.sh &&
sudo bash ./scripts/setup_directories.sh fw_download work out
```

```bash
sudo chmod +x mod_rom_2.sh
```
```bash
sudo bash mod_rom_2.sh DEVICE_MODEL
```

# Credits:
Salvo Giangreco: https://github.com/salvogiangri


