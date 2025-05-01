#!/bin/bash

# Greenlight - Xbox Cloud Gaming Client for Portmaster
# Port by OpenHands

# Enable debugging
DEBUG_MODE=1  # Set to 0 to disable debugging
DEBUG_LOG="/tmp/greenlight_debug.log"

if [ $DEBUG_MODE -eq 1 ]; then
    rm -f "$DEBUG_LOG"  # Clear previous log
    exec > >(tee -a "$DEBUG_LOG") 2>&1
    echo "=== Greenlight Debug Log $(date) ==="
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ $DEBUG_MODE -eq 1 ]; then
    echo "Script directory: $SCRIPT_DIR"
    echo "System information:"
    uname -a
    echo "Memory:"
    free -m || echo "free command not available"
fi

# Set up environment variables
export PORTMASTER="$SCRIPT_DIR"
export PORTMASTER_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
export WESTONPACK_RUNTIME="$PORTMASTER_DIR/runtime/westonpack"

# Add libs directory to library path if it exists
if [ -d "$SCRIPT_DIR/libs" ]; then
    export LD_LIBRARY_PATH="$SCRIPT_DIR/libs:$LD_LIBRARY_PATH"
    if [ $DEBUG_MODE -eq 1 ]; then
        echo "Added libs directory to LD_LIBRARY_PATH"
        echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
    fi
fi

# Check if Westonpack runtime is installed
if [ ! -d "$WESTONPACK_RUNTIME" ]; then
    echo "Westonpack runtime not found. Please install it from Portmaster."
    echo "Press any button to exit."
    read -n 1
    exit 1
fi

# Set up Westonpack environment
export XDG_RUNTIME_DIR="/tmp"
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0
export SDL_VIDEODRIVER=x11
export QT_QPA_PLATFORM=xcb

if [ $DEBUG_MODE -eq 1 ]; then
    echo "Display settings:"
    echo "DISPLAY=$DISPLAY"
    echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
    echo "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
    echo "SDL_VIDEODRIVER=$SDL_VIDEODRIVER"
    echo "QT_QPA_PLATFORM=$QT_QPA_PLATFORM"
    
    echo "Checking Greenlight binary:"
    ls -la "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight" || echo "Binary not found!"
    
    echo "Setting executable permissions:"
    chmod +x "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight"
    ls -la "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight"
    
    echo "Library dependencies:"
    ldd "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight" || echo "ldd command failed or not available"
    
    echo "GPU information:"
    glxinfo | grep "OpenGL renderer" || echo "glxinfo not available"
fi

# Start gptokeyb for controller support
"$PORTMASTER_DIR/gptokeyb" -c "$SCRIPT_DIR/greenlight.gptk" &
GPTOKEYB_PID=$!

# Ensure gptokeyb is killed when the script exits
trap "kill $GPTOKEYB_PID" EXIT

if [ $DEBUG_MODE -eq 1 ]; then
    echo "Starting Greenlight with Westonpack..."
fi

# Launch Greenlight using Westonpack with verbose flag for debugging
if [ $DEBUG_MODE -eq 1 ]; then
    "$WESTONPACK_RUNTIME/start.sh" "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight" --verbose
else
    "$WESTONPACK_RUNTIME/start.sh" "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight"
fi

EXIT_CODE=$?
if [ $DEBUG_MODE -eq 1 ]; then
    echo "Greenlight exited with code: $EXIT_CODE"
    echo "Debug log saved to: $DEBUG_LOG"
    echo "Please check this file if you encountered any issues."
fi

# Exit
exit $EXIT_CODE