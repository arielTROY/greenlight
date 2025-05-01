#!/bin/bash
# Greenlight launch script (alternative version without Westonpack)
# This script launches Greenlight using direct X11 or Box86/Box64

# Get the directory where this script is located
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Set up paths
export PORTMASTER_PATH="/opt/system/Tools/PortMaster"
export GREENLIGHT_PATH="$SCRIPT_DIR/greenlight-bin"
export LD_LIBRARY_PATH="$GREENLIGHT_PATH/opt/Greenlight:$GREENLIGHT_PATH/opt/Greenlight/lib:$GREENLIGHT_PATH/usr/lib:$LD_LIBRARY_PATH"
export PATH="$GREENLIGHT_PATH/usr/bin:$PATH"

# Set up controller mapping
GPTK="$PORTMASTER_PATH/helper/gptokeyb"
GPTK_CONFIG="$SCRIPT_DIR/greenlight.gptk"

# Check if we're running on a device with X11 already available
if [ -n "$DISPLAY" ]; then
    echo "X11 display detected: $DISPLAY"
else
    # Try to set up a basic X11 environment
    export DISPLAY=:0
    echo "Setting up X11 display: $DISPLAY"
fi

# Check if Box86/Box64 is available as an alternative to Westonpack
if [ -d "$PORTMASTER_PATH/runtime/box86" ]; then
    echo "Using Box86/Box64 runtime"
    export BOX86_PATH="$PORTMASTER_PATH/runtime/box86"
    export BOX64_PATH="$PORTMASTER_PATH/runtime/box64"
    export BOX86_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
    export BOX64_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
fi

# Kill any existing instances
killall -9 greenlight gptokeyb > /dev/null 2>&1

# Start controller mapping in background
$GPTK -c "$GPTK_CONFIG" greenlight &

# Launch Greenlight
cd "$GREENLIGHT_PATH/opt/Greenlight"
./greenlight "$@"

# Clean up
killall gptokeyb > /dev/null 2>&1