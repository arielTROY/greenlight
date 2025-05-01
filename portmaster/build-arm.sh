#!/bin/bash

# Build script for compiling Greenlight for ARM64 architecture
# This script will build Greenlight from source for ARM64 devices

set -e

echo "=== Greenlight ARM64 Build Script ==="
echo "This script will build Greenlight from source for ARM64 devices"
echo ""

# Check if we're in the right directory
if [ ! -d "/workspace/greenlight" ]; then
  echo "Error: Please run this script from the greenlight repository root"
  exit 1
fi

# Install dependencies
echo "=== Installing build dependencies ==="
npm install -g yarn
npm install -g nextron

# Navigate to the desktop package
cd /workspace/greenlight

# Install project dependencies
echo "=== Installing project dependencies ==="
yarn install

# Build the ARM64 version
echo "=== Building Greenlight for ARM64 ==="
cd packages/desktop
yarn build:arm64

# Check if the build was successful
if [ -f "dist/greenlight_2.3.2_arm64.deb" ]; then
  echo "=== Build successful! ==="
  echo "ARM64 package created at: packages/desktop/dist/greenlight_2.3.2_arm64.deb"
  
  # Copy the ARM64 package to the portmaster directory
  mkdir -p /workspace/greenlight/portmaster/greenlight/greenlight-bin
  cp dist/greenlight_2.3.2_arm64.deb /workspace/greenlight/portmaster/greenlight/greenlight-bin/
  
  echo "=== Package copied to portmaster directory ==="
  echo "You can now update the portmaster package with the ARM64 binary"
else
  echo "=== Build failed! ==="
  echo "Could not find the ARM64 package. Check the build logs for errors."
  exit 1
fi