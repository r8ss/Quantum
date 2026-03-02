![QuantumROM Logo](QuantumROM/logo/QuantumROM.jpg)

# 📌 Overview:
- This Custom ROM is built by combining and refining features from multiple projects, including UNICA, Legacy-UI, and AstroRom.
- The goal of this ROM is to provide a clean, optimized, and stable One UI experience with enhanced usability and performance.

## Tools features.
- Download firmware directly from samsung server.
- File config and file contexts generate.
- Extract and img build ( erofs and ext4 supported).

## ✨ Key Features:
- System Optimization.
- Heavy debloated system (removed unnecessary apps & services).
- Improved performance and smoother UI experience.
- Optimized background processes.
- Better battery efficiency.
- Enhanced Functionality.
- Screenshot anywhere (enabled globally).
- Built-in Screen Recorder.
- More floating features enabled.
- Edge features fully working.
- Stock device conig always be added.
- Extra brightness support.
- Object, shadow and reflection remover support.
- Multi user support.
- Camera privacy toggle support
- [BluetoothLibraryPatcher](https://github.com/3arthur6/BluetoothLibraryPatcher) integrated
- [KnoxPatch](https://github.com/salvogiangri/KnoxPatch) integrated

## 🔐 Security & Privacy:
- Secure Folder support.
- Essential security components retained.
- Stable and safe daily-driver experience.

## 📱 One UI Experience:
- Full One UI apps included.
- Important system apps preserved.
- China Smart Manager support.
- AI features enabled.

## 🎯 Project Goal
- To deliver a lightweight yet fully featured Samsung One UI ROM that balances.
- Performance.
- Stability.
- Essential Features.
- Clean User Experience.

# How to Use:
#### 1. Fork the Repository
- Give a ⭐ star to the repository.
- Fork the repository to your GitHub account.

#### 2. Run the Workflow:
- Open your forked repository.
- Go to the Actions tab.
- Select QuantumROM Tools.
- Click Run workflow.

#### 3. Set Your Device Model:
- Update your device model in the STOCK_DEVICE_MODEL option.
- If your model is available in /QuantumROM/Device folder of this repository, the tool will work for your device.
- If your model is not present, set STOCK_DEVICE_MODEL to None.

#### 4. Kernel BPF Version Option:
- Set this option to True if your kernel BPF version is 5.4 (lower than 5.10).
- Otherwise, set it to False.

#### 5. Set Target Device Information:
- Configure the following options:
- TARGET_DEVICE_MODEL
- The device model from which you want to port the ROM.

- TARGET_DEVICE_CSC
- The country/region code used to download the target device firmware.

- TARGET_DEVICE_IMEI
- Required to download the target device firmware from the Samsung server.
- Change the IMEI if you want to change the target device.

#### 6. OUTPUT_FILESYSTEM (erofs / ext4):
- My tool can build images in two formats:
- erofs
- Recommended if your device partition size is small.
- Saves storage space.
- Your kernel must support EROFS.
- ext4
- Use this if your kernel does not support EROFS.
- The generated image will be larger in size.

#### 7. Compress IMG to XZ (True / False):
- If set to True:
The generated image will be compressed to .xz format.
- This reduces file size before uploading.
- If set to False:
- The image will remain in its original format without compression.
   
#### 8: Add git credentials:
In You Forked Repo /Settings/Secret and VariableS/Action option > New repository secret Make A New secret and Set NamE GIT_TOKEN and add git token.
- Search in YouTube how to make github secret token.
- If you don't add token in secret, your Build rom will not upload in your repo release Center.
   
#### 9. How to Get IMG from Split Files:
GitHub does not allow uploading a single file larger than 2GB.
Therefore, any image file larger than 2GB will be automatically split.
Example split files:
- Split files Will Like:
   system.img.xz.part000
   system.img.xz.part001

- Steps to Recreate the Original File
- Download all split files from the Release section.
- Combine them into a single file.
- On Linux or Termux:
```bash
cat system.img.xz.part* > system.img.xz

## Licensing
This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.
- **[android-tools](https://github.com/nmeum/android-tools)** - Licensed under Apache License 2.0
- **[apktool](https://github.com/iBotPeaches/Apktool)** - Licensed under Apache License 2.0  
- **[erofs-utils](https://github.com/sekaiacg/erofs-utils)** - Dual licensed (GPL-2.0, Apache-2.0)
- **[platform_build](https://android.googlesource.com/platform/build)** - Licensed under Apache License 2.0
- **[e2fsprogs](https://github.com/tytso/e2fsprogs)** - Licensed under GPL-2.0 / LGPL-2.1
