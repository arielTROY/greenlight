#!/bin/bash

# Greenlight - Xbox Cloud Gaming Client for Portmaster
# Port by OpenHands

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Set up environment variables
export PORTMASTER="$SCRIPT_DIR"
export PORTMASTER_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
export WESTONPACK_RUNTIME="$PORTMASTER_DIR/runtime/westonpack"

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

# Start gptokeyb for controller support
"$PORTMASTER_DIR/gptokeyb" -c "$SCRIPT_DIR/greenlight.gptk" &
GPTOKEYB_PID=$!

# Ensure gptokeyb is killed when the script exits
trap "kill $GPTOKEYB_PID" EXIT

# Launch Greenlight using Westonpack
"$WESTONPACK_RUNTIME/start.sh" "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight"

# Exit
exit 0