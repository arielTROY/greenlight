#!/bin/bash

# Greenlight - Xbox Cloud Gaming Client for Portmaster (ARM version)
# This script is specifically for ARM devices like the R36S
# It uses Box86/Box64 for x86/x64 emulation

# Enable debugging
DEBUG_MODE=1  # Set to 0 to disable debugging
DEBUG_LOG="/tmp/greenlight_debug.log"  # Save to /tmp for easy access

if [ $DEBUG_MODE -eq 1 ]; then
    rm -f "$DEBUG_LOG"  # Clear previous log
    exec > >(tee -a "$DEBUG_LOG") 2>&1
    echo "=== Greenlight ARM Debug Log $(date) ==="
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ $DEBUG_MODE -eq 1 ]; then
    echo "Script directory: $SCRIPT_DIR"
    echo "System information:"
    uname -a
    echo "Architecture: $(arch)"
    echo "Memory:"
    free -m || echo "free command not available"
fi

# Set up environment variables
export PORTMASTER="$SCRIPT_DIR"
export PORTMASTER_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Add libs directory to library path if it exists
if [ -d "$SCRIPT_DIR/libs" ]; then
    export LD_LIBRARY_PATH="$SCRIPT_DIR/libs:$LD_LIBRARY_PATH"
    if [ $DEBUG_MODE -eq 1 ]; then
        echo "Added libs directory to LD_LIBRARY_PATH"
        echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
    fi
fi

# Find Box86/Box64 in possible locations
BOX86_PATHS=(
    "$PORTMASTER_DIR/runtime/box86/box86"
    "/opt/system/Tools/PortMaster/runtime/box86/box86"
    "/roms/ports/runtime/box86/box86"
    "/roms/tools/PortMaster/runtime/box86/box86"
    "/storage/roms/ports/runtime/box86/box86"
    "/usr/bin/box86"
    "/usr/local/bin/box86"
)

BOX64_PATHS=(
    "$PORTMASTER_DIR/runtime/box64/box64"
    "/opt/system/Tools/PortMaster/runtime/box64/box64"
    "/roms/ports/runtime/box64/box64"
    "/roms/tools/PortMaster/runtime/box64/box64"
    "/storage/roms/ports/runtime/box64/box64"
    "/usr/bin/box64"
    "/usr/local/bin/box64"
)

# Find Box86
BOX86_PATH=""
for path in "${BOX86_PATHS[@]}"; do
    if [ -f "$path" ]; then
        BOX86_PATH="$path"
        if [ $DEBUG_MODE -eq 1 ]; then
            echo "Found Box86 at: $BOX86_PATH"
        fi
        break
    fi
done

# Find Box64
BOX64_PATH=""
for path in "${BOX64_PATHS[@]}"; do
    if [ -f "$path" ]; then
        BOX64_PATH="$path"
        if [ $DEBUG_MODE -eq 1 ]; then
            echo "Found Box64 at: $BOX64_PATH"
        fi
        break
    fi
done

# Check if we found Box86 or Box64
if [ -z "$BOX86_PATH" ] && [ -z "$BOX64_PATH" ]; then
    echo "ERROR: Neither Box86 nor Box64 found. These are required to run x86/x64 applications on ARM."
    echo "Please install Box86/Box64 through Portmaster's runtime manager."
    echo "Press any button to exit."
    read -n 1
    exit 1
fi

# Set up X11 environment
export XDG_RUNTIME_DIR="/tmp"
export DISPLAY=:0
export SDL_VIDEODRIVER=x11
export QT_QPA_PLATFORM=xcb
export GDK_BACKEND=x11

if [ $DEBUG_MODE -eq 1 ]; then
    echo "Display settings:"
    echo "DISPLAY=$DISPLAY"
    echo "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
    echo "SDL_VIDEODRIVER=$SDL_VIDEODRIVER"
    echo "QT_QPA_PLATFORM=$QT_QPA_PLATFORM"
    
    echo "Checking Greenlight binary:"
    ls -la "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight" || echo "Binary not found!"
    
    echo "Setting executable permissions:"
    chmod +x "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight"
    ls -la "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight"
    
    echo "File type:"
    file "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight" || echo "file command failed or not available"
fi

# Find gptokeyb in possible locations
GPTOKEYB_PATHS=(
    "$PORTMASTER_DIR/gptokeyb"
    "$PORTMASTER_DIR/helper/gptokeyb"
    "/opt/system/Tools/PortMaster/helper/gptokeyb"
    "/roms/ports/gptokeyb"
    "/roms/tools/PortMaster/helper/gptokeyb"
    "/userdata/system/portmaster/helper/gptokeyb"
    "/storage/roms/ports/gptokeyb"
)

GPTOKEYB_PATH=""
for path in "${GPTOKEYB_PATHS[@]}"; do
    if [ -f "$path" ]; then
        GPTOKEYB_PATH="$path"
        if [ $DEBUG_MODE -eq 1 ]; then
            echo "Found gptokeyb at: $GPTOKEYB_PATH"
        fi
        break
    fi
done

# Start gptokeyb for controller support
if [ -n "$GPTOKEYB_PATH" ]; then
    if [ $DEBUG_MODE -eq 1 ]; then
        echo "Starting gptokeyb with config: $SCRIPT_DIR/greenlight.gptk"
    fi
    "$GPTOKEYB_PATH" -c "$SCRIPT_DIR/greenlight.gptk" &
    GPTOKEYB_PID=$!
    
    # Ensure gptokeyb is killed when the script exits
    trap "kill $GPTOKEYB_PID 2>/dev/null" EXIT
else
    echo "Warning: gptokeyb not found. Controller support may not work."
fi

# Set up Box86/Box64 environment
export BOX86_NOBANNER=1
export BOX64_NOBANNER=1
export BOX86_LOG=0
export BOX64_LOG=0

if [ $DEBUG_MODE -eq 1 ]; then
    # Enable Box86/Box64 logging for debugging
    export BOX86_LOG=1
    export BOX64_LOG=1
    export BOX86_LOG_FILE="/tmp/greenlight_box86.log"
    export BOX64_LOG_FILE="/tmp/greenlight_box64.log"
fi

# Add Greenlight binary directory to library path
export LD_LIBRARY_PATH="$SCRIPT_DIR/greenlight-bin/opt/Greenlight:$SCRIPT_DIR/greenlight-bin/opt/Greenlight/lib:$SCRIPT_DIR/greenlight-bin/usr/lib:$LD_LIBRARY_PATH"

# Launch Greenlight with appropriate emulator
cd "$SCRIPT_DIR/greenlight-bin/opt/Greenlight"

if [ $DEBUG_MODE -eq 1 ]; then
    echo "Starting Greenlight with Box86/Box64 emulation..."
fi

# Determine which emulator to use based on binary type
if [ -n "$BOX64_PATH" ]; then
    if [ $DEBUG_MODE -eq 1 ]; then
        echo "Using Box64 for x86_64 emulation"
        $BOX64_PATH ./greenlight --verbose
    else
        $BOX64_PATH ./greenlight
    fi
elif [ -n "$BOX86_PATH" ]; then
    if [ $DEBUG_MODE -eq 1 ]; then
        echo "Using Box86 for x86 emulation"
        $BOX86_PATH ./greenlight --verbose
    else
        $BOX86_PATH ./greenlight
    fi
else
    echo "ERROR: No compatible emulator found"
    exit 1
fi

EXIT_CODE=$?
if [ $DEBUG_MODE -eq 1 ]; then
    echo "Greenlight exited with code: $EXIT_CODE"
    echo "Debug log saved to: $DEBUG_LOG"
    echo "Please check this file if you encountered any issues."
fi

# Exit
exit $EXIT_CODE