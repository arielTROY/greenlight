# Building Greenlight for ARM from Source

This guide explains how to build Greenlight from source for ARM architecture.

## Prerequisites

- Linux development environment (Ubuntu 20.04+ recommended)
- Node.js 16+ and npm
- Git
- Build tools (build-essential, etc.)

## Setting Up the Build Environment

1. Clone the Greenlight repository:
   ```bash
   git clone https://github.com/unknownskl/greenlight.git
   cd greenlight
   ```

2. Install global dependencies:
   ```bash
   npm install -g yarn
   npm install -g nextron
   ```

3. Install project dependencies:
   ```bash
   yarn install
   ```

## Building for ARM64

We've added a custom build script to simplify the ARM64 build process:

1. Navigate to the portmaster directory:
   ```bash
   cd portmaster
   ```

2. Run the ARM build script:
   ```bash
   ./build-arm.sh
   ```

This script will:
- Install necessary dependencies
- Build Greenlight for ARM64 architecture
- Create a .deb package for ARM64
- Copy the package to the portmaster directory

## Manual Build Process

If you prefer to build manually or need to customize the build:

1. Navigate to the desktop package:
   ```bash
   cd packages/desktop
   ```

2. Build the application without packaging:
   ```bash
   yarn nextron build --no-pack
   ```

3. Build the ARM64 package:
   ```bash
   yarn electron-builder --linux --arm64
   ```

The built package will be available in the `dist` directory.

## Cross-Compiling

To cross-compile for ARM64 on an x86_64 system:

1. Install cross-compilation tools:
   ```bash
   sudo apt-get install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
   ```

2. Set up environment variables:
   ```bash
   export CC=aarch64-linux-gnu-gcc
   export CXX=aarch64-linux-gnu-g++
   ```

3. Follow the build steps above

## Testing the Build

After building, you can test the ARM64 package on an ARM device:

1. Copy the .deb package to your ARM device
2. Install it using:
   ```bash
   sudo dpkg -i greenlight_2.3.2_arm64.deb
   ```
   
   Or extract it following the instructions in `ARM_BINARY_INSTALLATION.md`

## Troubleshooting

- **Missing dependencies**: If you encounter missing dependencies during the build, install them using your package manager
- **Node.js version issues**: Ensure you're using a compatible Node.js version (16+)
- **Electron build errors**: Check the Electron documentation for ARM64-specific build requirements

## Integrating with Portmaster

After building, follow these steps to integrate with the Portmaster port:

1. Extract the binary from the .deb package as described in `ARM_BINARY_INSTALLATION.md`
2. Place the binary in the `portmaster/greenlight/greenlight-bin` directory
3. Use the `greenlight-native-arm.sh` script to launch the application

## Additional Resources

- [Electron Builder Documentation](https://www.electron.build/)
- [Cross-Compiling for ARM](https://github.com/electron/electron/blob/main/docs/development/build-instructions-linux.md#cross-compiling)
- [Nextron Documentation](https://github.com/saltyshiomix/nextron)