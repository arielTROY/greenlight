# Greenlight Port for Portmaster

This is a port of [Greenlight](https://github.com/unknownskl/greenlight), an open-source client for Xbox Cloud Gaming (xCloud) and Xbox home streaming, for Portmaster-compatible devices.

## What is Greenlight?

Greenlight allows you to stream Xbox games from either:
- Xbox Cloud Gaming (requires Xbox Game Pass Ultimate)
- Your own Xbox console (for home streaming)

## Port Details

This port uses the Westonpack runtime to provide the X11 environment needed by Electron applications. It includes controller mapping through gptokeyb to make the application fully usable with handheld device controls.

### Architecture Support

This port now supports both x86_64 and ARM64 architectures:

- **x86_64 devices**: Uses the official Greenlight Linux binary with Box86/Box64 for ARM devices
- **ARM64 devices**: Can use either:
  - The official x86_64 binary through Box86/Box64 emulation (slower)
  - A native ARM64 build (better performance)

## Files Included

- `greenlight.zip` - The packaged port ready for installation
- `INSTALL.md` - Detailed installation instructions
- `package.sh` - Script to create the port package
- `build-arm.sh` - Script to build Greenlight for ARM64 architecture
- `ARM_BINARY_INSTALLATION.md` - Guide for installing the ARM binary
- `ARM_BUILD_GUIDE.md` - Guide for building Greenlight for ARM from source

## Installation

See the [INSTALL.md](INSTALL.md) file for detailed installation instructions.

For ARM devices, additional documentation is available:
- [ARM Binary Installation Guide](ARM_BINARY_INSTALLATION.md)
- [ARM Build Guide](ARM_BUILD_GUIDE.md)

## Launch Scripts

The port includes multiple launch scripts:
- `greenlight.sh` - Main launch script using Westonpack runtime
- `greenlight-alt.sh` - Alternative launch script that works without Westonpack
- `greenlight-arm.sh` - ARM-specific launch script using Box86/Box64 for x86_64 emulation
- `greenlight-native-arm.sh` - Launch script for native ARM builds

## Requirements

- A device supported by Portmaster
- Portmaster installed
- Westonpack runtime installed
- An active Xbox Game Pass Ultimate subscription (for cloud gaming)
- A Microsoft account
- Internet connection

## Known Issues

- Performance depends on your internet connection quality
- Some Xbox Cloud Gaming features may not be available on all devices
- First launch may take longer as Westonpack initializes
- ARM emulation using Box86/Box64 may have performance limitations
- Native ARM builds require compilation from source

## Credits

- Original application by [UnknownSKL](https://github.com/unknownskl)
- Ported to Portmaster by OpenHands

## License

This port is distributed under the same license as the original application.