#!/bin/bash

# Greenlight launch script for native ARM builds
# This script is designed to run the native ARM build of Greenlight on ARM devices

# Set up environment
export PORTMASTER_DIR="$(dirname "$(readlink -f "$0")")"
export GREENLIGHT_DIR="$PORTMASTER_DIR/greenlight-bin"
export DEBUG_LOG="/tmp/greenlight_debug.log"

# Start logging
echo "Starting Greenlight (Native ARM) on $(date)" > "$DEBUG_LOG"
echo "System architecture: $(uname -m)" >> "$DEBUG_LOG"
echo "Portmaster directory: $PORTMASTER_DIR" >> "$DEBUG_LOG"
echo "Greenlight directory: $GREENLIGHT_DIR" >> "$DEBUG_LOG"

# Check if the ARM binary exists
if [ ! -f "$GREENLIGHT_DIR/greenlight" ]; then
    echo "Error: Greenlight ARM binary not found at $GREENLIGHT_DIR/greenlight" >> "$DEBUG_LOG"
    echo "Please extract the ARM package first. See BINARY_INSTALLATION.md for instructions."
    exit 1
fi

# Check for gptokeyb for controller support
GPTOKEYB=""
for dir in "/opt/system/tools" "/opt/system" "/opt/retrodeck/tools" "/storage/roms/ports/tools" "/usr/local/bin" "/usr/bin"; do
    if [ -f "$dir/gptokeyb" ]; then
        GPTOKEYB="$dir/gptokeyb"
        break
    fi
done

if [ "$GPTOKEYB" != "" ]; then
    echo "Found gptokeyb at $GPTOKEYB" >> "$DEBUG_LOG"
    
    # Kill any existing gptokeyb processes
    killall gptokeyb 2>/dev/null || true
    
    # Start gptokeyb with our configuration
    "$GPTOKEYB" "greenlight" -c "$PORTMASTER_DIR/greenlight.gptk" &
    GPTOKEYB_PID=$!
    echo "Started gptokeyb with PID $GPTOKEYB_PID" >> "$DEBUG_LOG"
else
    echo "Warning: gptokeyb not found, controller support may be limited" >> "$DEBUG_LOG"
fi

# Check for Westonpack runtime
WESTONPACK=""
for dir in "/opt/westonpack" "/usr/share/westonpack" "/storage/roms/ports/westonpack" "/opt/system/westonpack"; do
    if [ -d "$dir" ]; then
        WESTONPACK="$dir"
        break
    fi
done

# Launch Greenlight
cd "$GREENLIGHT_DIR"
if [ "$WESTONPACK" != "" ]; then
    echo "Found Westonpack at $WESTONPACK, launching with Westonpack runtime" >> "$DEBUG_LOG"
    "$WESTONPACK/start.sh" "$GREENLIGHT_DIR/greenlight" >> "$DEBUG_LOG" 2>&1
else
    echo "Westonpack not found, launching directly with X11" >> "$DEBUG_LOG"
    "$GREENLIGHT_DIR/greenlight" >> "$DEBUG_LOG" 2>&1
fi

# Clean up
if [ "$GPTOKEYB" != "" ]; then
    echo "Killing gptokeyb process" >> "$DEBUG_LOG"
    killall gptokeyb 2>/dev/null || true
fi

echo "Greenlight session ended at $(date)" >> "$DEBUG_LOG"
exit 0