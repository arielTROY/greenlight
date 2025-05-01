# GBM Library Troubleshooting Guide

If you encounter the error `undefined symbol: gbm_bo_get_modifier` when running Greenlight on ARM devices, follow this troubleshooting guide.

## What is the GBM Library?

GBM (Generic Buffer Management) is a library that provides a mechanism for allocating buffers for graphics rendering. It's commonly used by graphics applications, including Electron-based applications like Greenlight.

## Common Error Messages

- `undefined symbol: gbm_bo_get_modifier`
- `error while loading shared libraries: libgbm.so.1: cannot open shared object file: No such file or directory`

## Automatic Fixes

The `greenlight-native-arm.sh` script includes automatic fixes for GBM library issues:

1. It searches for GBM libraries in common system locations
2. It adds these libraries to the `LD_LIBRARY_PATH`
3. If no GBM library is found, it attempts to create a symbolic link to any available GBM library

## Manual Fixes

If the automatic fixes don't work, try these manual steps:

### 1. Install the GBM Library

On Debian/Ubuntu-based systems:
```bash
sudo apt-get update
sudo apt-get install libgbm1
```

On other systems, the package name might be different.

### 2. Create a Symbolic Link

If the library exists but is not in the expected location:

```bash
# Find the GBM library
find /usr -name "libgbm.so*"

# Create a symbolic link in the libs directory
mkdir -p /path/to/greenlight/libs
ln -sf /path/to/found/libgbm.so.1 /path/to/greenlight/libs/libgbm.so.1
```

### 3. Set LD_LIBRARY_PATH Manually

Before running Greenlight, set the library path:

```bash
export LD_LIBRARY_PATH=/path/to/gbm/library:$LD_LIBRARY_PATH
```

## Device-Specific Solutions

### R36S / ArkOS

On R36S devices running ArkOS, the GBM library is typically located at:
```
/usr/lib/aarch64-linux-gnu/libgbm.so.1
```

If it's not there, you can install it with:
```bash
sudo apt-get update
sudo apt-get install libgbm1
```

### Other ARM Devices

For other ARM devices, check your distribution's package manager for the appropriate GBM library package.

## Checking If GBM Is Installed

To check if the GBM library is installed and accessible:

```bash
# Check if the library exists
find /usr -name "libgbm.so*"

# Check if the library is in the library path
ldconfig -p | grep gbm
```

## Debug Information

If you're still having issues, run the script with debugging enabled and check the log file at `/tmp/greenlight_debug.log` for more information about library paths and errors.

The debug log will show:
- System architecture
- Library paths searched
- Libraries found
- Final LD_LIBRARY_PATH setting

## Contact Support

If you continue to experience issues after trying these solutions, please file an issue on the GitHub repository with your debug log attached.