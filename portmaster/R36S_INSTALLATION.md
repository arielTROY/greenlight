# Greenlight Installation Guide for Anbernic R36S

This guide provides step-by-step instructions for installing and running Greenlight on the Anbernic R36S device.

## Prerequisites

- Anbernic R36S with Portmaster installed
- Internet connection for downloading files
- USB drive or SD card for transferring files

## Installation Steps

### Step 1: Download the Greenlight Port

1. Download the Greenlight port package (`greenlight.zip`) from:
   https://github.com/arielTROY/greenlight/raw/portmaster-port/portmaster/greenlight.zip

2. Download the Greenlight Linux binary (`greenlight_2.3.2_amd64.deb`) from:
   https://github.com/unknownskl/greenlight/releases

### Step 2: Extract the Port Package

1. Connect your R36S to your computer or use a file manager on the device
2. Copy `greenlight.zip` to the Portmaster ports directory:
   - Typically: `/roms/ports/` or `/opt/system/Tools/PortMaster/ports/`
3. Extract the zip file:
   ```bash
   cd /roms/ports/
   unzip greenlight.zip -d .
   ```

### Step 3: Install the Greenlight Binary

1. Create a temporary directory for extraction:
   ```bash
   mkdir -p /tmp/greenlight-extract
   cd /tmp/greenlight-extract
   ```

2. Copy the `greenlight_2.3.2_amd64.deb` file to this directory

3. Extract the .deb package:
   ```bash
   ar x greenlight_2.3.2_amd64.deb
   tar xf data.tar.xz  # or tar xf data.tar.gz
   ```

4. Copy the extracted files to the port directory:
   ```bash
   mkdir -p /roms/ports/greenlight/greenlight-bin/opt
   mkdir -p /roms/ports/greenlight/greenlight-bin/usr
   cp -r opt/* /roms/ports/greenlight/greenlight-bin/opt/
   cp -r usr/* /roms/ports/greenlight/greenlight-bin/usr/
   ```

5. Make the Greenlight binary executable:
   ```bash
   chmod +x /roms/ports/greenlight/greenlight-bin/opt/Greenlight/greenlight
   ```

### Step 4: Configure for R36S

The R36S has specific requirements for running X11 applications. The port includes an auto-detection system that will try to find the best way to run Greenlight on your device.

If you encounter issues, try these steps:

1. Check if Westonpack is installed:
   ```bash
   ls -la /opt/system/Tools/PortMaster/runtime/westonpack
   ```

2. If Westonpack is not installed, you can:
   - Install it from Portmaster's runtime manager
   - Or use the direct X11 mode (automatically enabled if Westonpack is not found)

3. For direct X11 mode, make sure X11 is running:
   ```bash
   ps aux | grep X
   ```

4. If X11 is not running, start it:
   ```bash
   startx &
   ```

## Running Greenlight

1. Launch Portmaster on your R36S
2. Find "Greenlight" in the list of ports
3. Select it to launch

## Troubleshooting

If you encounter issues:

1. Check the debug log:
   ```bash
   cat /tmp/greenlight_debug.log
   ```

2. Make sure all required libraries are installed:
   ```bash
   apt update
   apt install libgl1 libvulkan1 libegl1 libxkbcommon0
   ```

3. Try the alternative launch script:
   ```bash
   cd /roms/ports/greenlight
   ./greenlight-alt.sh
   ```

4. If you see "Westonpack not found" but you know it's installed, check the paths in the script:
   ```bash
   nano /roms/ports/greenlight/greenlight.sh
   ```
   
   Look for the `WESTONPACK_PATHS` array and add your specific path if needed.

5. For more detailed troubleshooting, refer to the `R36S_TROUBLESHOOTING.md` file.

## Controller Configuration

The port includes a default controller mapping for the R36S. If you need to customize it:

1. Edit the controller mapping file:
   ```bash
   nano /roms/ports/greenlight/greenlight.gptk
   ```

2. Adjust the button mappings to match your preferences

## Updating

To update the port:

1. Download the latest version of the port
2. Extract it to replace the existing files
3. Keep your existing `greenlight-bin` directory to avoid having to reinstall the binary

## Uninstalling

To uninstall:

1. Delete the port directory:
   ```bash
   rm -rf /roms/ports/greenlight
   ```

2. Remove any runtime dependencies if no longer needed