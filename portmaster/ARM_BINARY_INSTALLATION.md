# ARM Binary Installation Guide

This guide explains how to extract and install the native ARM build of Greenlight for use with the Portmaster port.

## Prerequisites

- ARM-based device (like R36S, RG552, etc.)
- Linux operating system (ArkOS, JelOS, etc.)
- Basic command line knowledge

## Extracting the ARM Binary

The Greenlight ARM binary is packaged as a .deb file. Follow these steps to extract it:

### Method 1: Using dpkg (Recommended)

If your system has `dpkg` installed:

1. Navigate to the directory containing the .deb file:
   ```bash
   cd /path/to/greenlight/greenlight-bin
   ```

2. Extract the binary using dpkg:
   ```bash
   dpkg -x greenlight_2.3.2_arm64.deb ./extracted
   ```

3. Copy the extracted binary to the correct location:
   ```bash
   cp ./extracted/opt/Greenlight/greenlight ./
   ```

4. Make the binary executable:
   ```bash
   chmod +x ./greenlight
   ```

### Method 2: Using ar and tar

If your system doesn't have dpkg:

1. Install the required tools:
   ```bash
   sudo apt-get install binutils
   # or
   sudo pacman -S binutils
   ```

2. Extract the .deb file:
   ```bash
   ar x greenlight_2.3.2_arm64.deb
   ```

3. Extract the data archive:
   ```bash
   tar xf data.tar.xz
   ```

4. Copy the binary to the correct location:
   ```bash
   cp ./opt/Greenlight/greenlight ./
   ```

5. Make the binary executable:
   ```bash
   chmod +x ./greenlight
   ```

## Launching Greenlight

After extracting the binary, you can launch Greenlight using the provided script:

```bash
./greenlight-native-arm.sh
```

This script will automatically detect your environment and launch Greenlight with the appropriate settings.

## Troubleshooting

If you encounter issues with the ARM binary:

1. Check the debug log at `/tmp/greenlight_debug.log`
2. Ensure your system is using an ARM64 architecture:
   ```bash
   uname -m
   ```
   It should return `aarch64` or `arm64`

3. Check if the binary has the correct permissions:
   ```bash
   ls -la ./greenlight
   ```
   It should have execute permissions (`-rwxr-xr-x`)

4. Verify that all dependencies are installed:
   ```bash
   ldd ./greenlight
   ```
   Install any missing dependencies using your system's package manager

## Additional Resources

- See `DEBUG_LOGS.md` for information on accessing and interpreting debug logs
- See `WESTONPACK_INSTALLATION.md` for information on installing the Westonpack runtime
- See `R36S_TROUBLESHOOTING.md` for R36S-specific troubleshooting tips