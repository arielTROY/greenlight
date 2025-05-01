# Installing Westonpack on R36S

Westonpack is a runtime environment that provides X11 support for applications on Portmaster-compatible devices. This guide will help you install Westonpack on your R36S device.

## Method 1: Install via Portmaster

The easiest way to install Westonpack is through Portmaster's runtime manager:

1. Launch Portmaster on your R36S
2. Navigate to "Runtime Manager" or "Runtime Environments" in the Portmaster menu
3. Find "Westonpack" in the list of available runtimes
4. Select it and choose "Install"
5. Wait for the installation to complete

## Method 2: Manual Installation

If Westonpack is not available in your Portmaster's runtime manager, you can install it manually:

### Step 1: Download Westonpack

Download the latest Westonpack runtime from the Portmaster repository:
https://github.com/PortsMaster/PortMaster-Runtime/releases

Look for a file named something like `westonpack-x.x.x.squashfs` or `westonpack-x.x.x.tar.gz`

### Step 2: Copy to R36S

1. Connect your R36S to your computer via USB or use a USB drive
2. Copy the downloaded Westonpack file to your R36S
3. Place it in the Portmaster runtimes directory:
   - Typically: `/opt/system/Tools/PortMaster/runtime/` or `/roms/ports/runtime/`

### Step 3: Install the Runtime

If the file is a .squashfs:
```bash
# SSH into your R36S
ssh root@[your-r36s-ip]

# Navigate to the runtime directory
cd /opt/system/Tools/PortMaster/runtime/

# Create a mount point
mkdir -p /opt/system/Tools/PortMaster/runtime/westonpack

# Mount the squashfs file
mount -t squashfs westonpack-x.x.x.squashfs /opt/system/Tools/PortMaster/runtime/westonpack
```

If the file is a .tar.gz:
```bash
# SSH into your R36S
ssh root@[your-r36s-ip]

# Navigate to the runtime directory
cd /opt/system/Tools/PortMaster/runtime/

# Extract the archive
mkdir -p westonpack
tar -xzf westonpack-x.x.x.tar.gz -C westonpack
```

## Method 3: Use Alternative Runtime

If you cannot install Westonpack, you can modify the Greenlight port to use an alternative runtime:

1. Edit the `greenlight.sh` script
2. Replace the Westonpack references with another X11-compatible runtime like Box86/Box64 or Xwayland

### Example modification for Box86/Box64:

```bash
# Find this line in greenlight.sh
export PORTMASTER_PATH="/opt/system/Tools/PortMaster"
export RUNTIME="$PORTMASTER_PATH/runtime/westonpack/usr/bin/westonpack"

# Change it to
export PORTMASTER_PATH="/opt/system/Tools/PortMaster"
export RUNTIME="$PORTMASTER_PATH/runtime/box86"
```

## Troubleshooting

If you encounter issues with Westonpack:

1. **Check if Westonpack is properly installed:**
   ```bash
   ls -la /opt/system/Tools/PortMaster/runtime/westonpack
   ```

2. **Verify Westonpack can run:**
   ```bash
   /opt/system/Tools/PortMaster/runtime/westonpack/usr/bin/westonpack --version
   ```

3. **Check for error messages:**
   ```bash
   dmesg | grep -i weston
   ```

4. **Check system logs:**
   ```bash
   cat /tmp/portmaster.log
   ```

5. **Ensure your device has enough free space:**
   ```bash
   df -h
   ```

## Alternative Approach: Direct X11

If Westonpack continues to cause issues, you can modify the Greenlight port to run directly with X11:

1. Edit the `greenlight.sh` script
2. Replace the Westonpack launch command with direct X11 environment variables:

```bash
# Find the line that launches Greenlight with Westonpack
$RUNTIME -- $GREENLIGHT_PATH/opt/Greenlight/greenlight "$@"

# Replace with direct X11 launch
export DISPLAY=:0
export XAUTHORITY=/home/user/.Xauthority
$GREENLIGHT_PATH/opt/Greenlight/greenlight "$@"
```

Note that this approach may require X11 to be already running on your device.