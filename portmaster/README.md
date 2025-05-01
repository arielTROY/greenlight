# Greenlight Port for Portmaster

This is a port of [Greenlight](https://github.com/unknownskl/greenlight), an open-source client for Xbox Cloud Gaming (xCloud) and Xbox home streaming, for Portmaster-compatible devices.

## What is Greenlight?

Greenlight allows you to stream Xbox games from either:
- Xbox Cloud Gaming (requires Xbox Game Pass Ultimate)
- Your own Xbox console (for home streaming)

## Port Details

This port uses the Westonpack runtime to provide the X11 environment needed by Electron applications. It includes controller mapping through gptokeyb to make the application fully usable with handheld device controls.

## Files Included

- `greenlight.zip` - The packaged port ready for installation
- `INSTALL.md` - Detailed installation instructions
- `package.sh` - Script to create the port package

## Installation

See the [INSTALL.md](INSTALL.md) file for detailed installation instructions.

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

## Credits

- Original application by [UnknownSKL](https://github.com/unknownskl)
- Ported to Portmaster by OpenHands

## License

This port is distributed under the same license as the original application.