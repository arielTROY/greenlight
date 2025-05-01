# Greenlight Documentation

This directory contains documentation for the Greenlight port for Portmaster.

## Available Documentation

- **ARM_BINARY_INSTALLATION.md**: Guide for installing the ARM binary
- **ARM_BUILD_GUIDE.md**: Guide for building Greenlight for ARM from source
- **DEBUG_LOGS.md**: Guide for accessing and interpreting debug logs
- **WESTONPACK_INSTALLATION.md**: Guide for installing the Westonpack runtime
- **R36S_TROUBLESHOOTING.md**: Solutions for common issues on R36S devices
- **BINARY_INSTALLATION.md**: Guide for installing the Greenlight binary
- **BOX86_BOX64_INSTALLATION.md**: Guide for installing Box86/Box64 on ARM devices

## Launch Scripts

The port includes multiple launch scripts:
- `greenlight.sh`: Main launch script using Westonpack runtime
- `greenlight-alt.sh`: Alternative launch script that works without Westonpack
- `greenlight-arm.sh`: ARM-specific launch script using Box86/Box64 for x86_64 emulation
- `greenlight-native-arm.sh`: Launch script for native ARM builds

## Architecture Support

This port supports both x86_64 and ARM64 architectures:

- **x86_64 devices**: Uses the official Greenlight Linux binary
- **ARM64 devices**: Can use either:
  - The official x86_64 binary through Box86/Box64 emulation (slower)
  - A native ARM64 build (better performance)

## Troubleshooting

If you encounter issues with the port, check the following:

1. Debug logs at `/tmp/greenlight_debug.log`
2. Westonpack installation status
3. Controller mapping configuration
4. Network connectivity

For ARM-specific issues, refer to the ARM documentation files.