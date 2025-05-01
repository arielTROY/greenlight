# Installing Box86/Box64 on R36S for Greenlight

This guide explains how to install Box86/Box64 on your R36S device to run the Greenlight x86_64 binary.

## What are Box86 and Box64?

Box86 and Box64 are userspace emulation tools that allow you to run x86 (32-bit) and x64 (64-bit) Linux applications on ARM devices like the R36S. They're essential for running Greenlight, which is compiled for x86_64 architecture.

## Installation Methods

### Method 1: Install via Portmaster Runtime Manager (Recommended)

1. Launch Portmaster on your R36S
2. Navigate to "Runtime Manager" or "Runtime Environments" in the Portmaster menu
3. Find "Box86" and "Box64" in the list of available runtimes
4. Select them and choose "Install"
5. Wait for the installation to complete

### Method 2: Manual Installation on ArkOS

If you're using ArkOS on your R36S, you can install Box86/Box64 using these commands:

```bash
# SSH into your R36S or open a terminal
ssh root@[your-r36s-ip]

# Update package lists
sudo apt update

# Install dependencies
sudo apt install build-essential cmake git

# Create a directory for Box86/Box64
mkdir -p ~/emulation
cd ~/emulation

# Clone and build Box86
git clone https://github.com/ptitSeb/box86
cd box86
mkdir build
cd build
cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j4
sudo make install

# Clone and build Box64
cd ~/emulation
git clone https://github.com/ptitSeb/box64
cd box64
mkdir build
cd build
cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j4
sudo make install

# Restart the system or reload libraries
sudo ldconfig
```

### Method 3: Download Pre-built Binaries

If building from source is too complex, you can download pre-built binaries:

1. Visit the Box86/Box64 releases page:
   - Box86: https://github.com/ptitSeb/box86/releases
   - Box64: https://github.com/ptitSeb/box64/releases

2. Download the appropriate ARM64 binaries for your device

3. Copy them to your R36S:
   ```bash
   # Create directories
   mkdir -p /opt/system/Tools/PortMaster/runtime/box86
   mkdir -p /opt/system/Tools/PortMaster/runtime/box64
   
   # Copy the binaries
   cp box86 /opt/system/Tools/PortMaster/runtime/box86/
   cp box64 /opt/system/Tools/PortMaster/runtime/box64/
   
   # Make them executable
   chmod +x /opt/system/Tools/PortMaster/runtime/box86/box86
   chmod +x /opt/system/Tools/PortMaster/runtime/box64/box64
   ```

## Using the ARM-specific Launch Script

Once Box86/Box64 is installed, use the ARM-specific launch script:

1. Navigate to your Greenlight port directory
2. Rename the original script:
   ```bash
   mv greenlight.sh greenlight.sh.original
   ```
3. Copy the ARM-specific script:
   ```bash
   cp greenlight-arm.sh greenlight.sh
   ```
4. Make it executable:
   ```bash
   chmod +x greenlight.sh
   ```

## Troubleshooting Box86/Box64

If you encounter issues:

### Check if Box86/Box64 is installed correctly:
```bash
which box86
which box64
```

### Test with a simple x86 application:
```bash
box86 /bin/ls
```

### Check for missing libraries:
```bash
box86 --list-libraries
box64 --list-libraries
```

### Install additional libraries if needed:
```bash
sudo apt install libc6:armhf libstdc++6:armhf
```

## Performance Considerations

Running x86_64 applications on ARM through emulation will have some performance impact. To improve performance:

1. Close other applications before running Greenlight
2. Reduce the resolution in the Greenlight settings
3. Disable visual effects in Greenlight
4. Make sure your R36S has good cooling

## Getting Help

If you continue to have issues with Box86/Box64:

1. Check the Box86/Box64 GitHub repositories for troubleshooting tips
2. Join the Box86/Box64 Discord server for community support
3. Post in the ArkOS or Portmaster forums with specific error messages