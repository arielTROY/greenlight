# GBM Library Troubleshooting Guide

If you encounter the error `undefined symbol: gbm_bo_get_modifier` when running Greenlight on ARM devices, follow this troubleshooting guide.

## What is the GBM Library?

GBM (Generic Buffer Management) is a library that provides a mechanism for allocating buffers for graphics rendering. It's commonly used by graphics applications, including Electron-based applications like Greenlight.

## Common Error Messages

- `undefined symbol: gbm_bo_get_modifier`
- `error while loading shared libraries: libgbm.so.1: cannot open shared object file: No such file or directory`
- `Greenlight exited with code 127`

## Automatic Fixes in the Latest Version

The latest version of `greenlight-native-arm.sh` includes several advanced fixes for GBM library issues:

1. It searches for GBM libraries in common system locations
2. It adds these libraries to the `LD_LIBRARY_PATH`
3. If no GBM library is found, it attempts to create a symbolic link to any available GBM library
4. It creates a stub library that provides the missing `gbm_bo_get_modifier` symbol
5. It completely disables GPU acceleration to avoid the need for GBM functionality

These fixes should resolve the issue for most users. If you're still experiencing problems, try the manual fixes below.

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

### 3. Create a Stub Library

If you have the GBM library but it's missing the `gbm_bo_get_modifier` function, you can create a stub library:

```bash
# Create a directory for the stub
mkdir -p /path/to/greenlight/libs/stubs

# Create a C file with the missing symbol
cat > /path/to/greenlight/libs/stubs/gbm_stub.c << 'EOF'
#include <stdint.h>
#include <stddef.h>

// Stub implementation of the missing function
uint64_t gbm_bo_get_modifier(void *bo) {
    // Return a default value that should be safe
    return 0;
}
EOF

# Compile the stub library
gcc -shared -fPIC /path/to/greenlight/libs/stubs/gbm_stub.c -o /path/to/greenlight/libs/stubs/libgbm_stub.so

# Use the stub library
export LD_PRELOAD=/path/to/greenlight/libs/stubs/libgbm_stub.so
```

### 4. Disable GPU Acceleration

You can manually disable GPU acceleration by setting these environment variables:

```bash
export ELECTRON_DISABLE_GPU=1
export DISABLE_GPU=1
export DISABLE_GPU_COMPOSITING=1
export DISABLE_GPU_RASTERIZATION=1
```

And launching Greenlight with these flags:

```bash
./greenlight --no-sandbox --disable-gpu --disable-software-rasterizer --disable-dev-shm-usage
```

## Checking If GBM Is Installed

To check if the GBM library is installed and accessible:

```bash
# Check if the library exists
find /usr -name "libgbm.so*"

# Check if the library is in the library path
ldconfig -p | grep gbm

# Check if the library has the missing symbol
nm -D /path/to/libgbm.so.1 | grep gbm_bo_get_modifier
```

## Debug Information

If you're still having issues, run the script with debugging enabled:

```bash
DEBUG=1 ./greenlight-native-arm.sh
```

This will show detailed information about the libraries being used and any errors encountered.

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