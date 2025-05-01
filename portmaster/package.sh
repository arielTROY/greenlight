#!/bin/bash

# Package the Greenlight port for Portmaster
cd "$(dirname "$0")"

# Create the documentation directory if it doesn't exist
mkdir -p greenlight/docs

# Copy documentation files
cp ARM_BINARY_INSTALLATION.md greenlight/docs/
cp ARM_BUILD_GUIDE.md greenlight/docs/

# Create the zip file
zip -r greenlight.zip greenlight/

echo "Port packaged as greenlight.zip"
echo "To complete the port, you need to:"
echo "1. For x86_64 devices:"
echo "   a. Download the latest Linux x64 release of Greenlight from https://github.com/unknownskl/greenlight/releases"
echo "   b. Extract the downloaded file"
echo "   c. Copy all the extracted files to the greenlight-bin directory in the port"
echo "2. For ARM devices:"
echo "   a. Build Greenlight for ARM using the build-arm.sh script"
echo "   b. Extract the ARM binary following the instructions in ARM_BINARY_INSTALLATION.md"
echo "   c. Use the greenlight-native-arm.sh script to launch Greenlight"
echo "3. Make sure the Westonpack runtime is installed in Portmaster"

exit 0