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

# Add libs directory to library path if it exists
if [ -d "$SCRIPT_DIR/libs" ]; then
    export LD_LIBRARY_PATH="$SCRIPT_DIR/libs:$LD_LIBRARY_PATH"
    if [ $DEBUG_MODE -eq 1 ]; then
        echo "Added libs directory to LD_LIBRARY_PATH"
        echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
    fi
fi

# Check for Westonpack in multiple possible locations
WESTONPACK_PATHS=(
    "$PORTMASTER_DIR/runtime/westonpack"
    "/opt/system/Tools/PortMaster/runtime/westonpack"
    "/roms/ports/runtime/westonpack"
    "/roms/tools/PortMaster/runtime/westonpack"
    "/userdata/system/portmaster/runtime/westonpack"
)

WESTONPACK_FOUND=0
for path in "${WESTONPACK_PATHS[@]}"; do
    if [ -d "$path" ]; then
        export WESTONPACK_RUNTIME="$path"
        WESTONPACK_FOUND=1
        if [ $DEBUG_MODE -eq 1 ]; then
            echo "Found Westonpack at: $WESTONPACK_RUNTIME"
        fi
        break
    fi
done

# Check if Westonpack runtime is installed
if [ $WESTONPACK_FOUND -eq 0 ]; then
    echo "Westonpack runtime not found in any of the standard locations."
    echo "Checking for alternative runtimes..."
    
    # Try to find any X11 or Wayland runtime
    for runtime_dir in "$PORTMASTER_DIR/runtime/"* "/opt/system/Tools/PortMaster/runtime/"* "/roms/ports/runtime/"*; do
        if [ -d "$runtime_dir" ] && [ -f "$runtime_dir/start.sh" ]; then
            export WESTONPACK_RUNTIME="$runtime_dir"
            WESTONPACK_FOUND=1
            echo "Found alternative runtime at: $WESTONPACK_RUNTIME"
            break
        fi
    done
    
    if [ $WESTONPACK_FOUND -eq 0 ]; then
        echo "No compatible runtime found. Switching to alternative launch method."
        echo "Using direct X11 mode..."
        export DIRECT_X11=1
    fi
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

# Find gptokeyb in possible locations
GPTOKEYB_PATHS=(
    "$PORTMASTER_DIR/gptokeyb"
    "$PORTMASTER_DIR/helper/gptokeyb"
    "/opt/system/Tools/PortMaster/helper/gptokeyb"
    "/roms/ports/gptokeyb"
    "/roms/tools/PortMaster/helper/gptokeyb"
    "/userdata/system/portmaster/helper/gptokeyb"
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

if [ $DEBUG_MODE -eq 1 ]; then
    echo "Starting Greenlight with Westonpack..."
fi

# Launch Greenlight
if [ "$DIRECT_X11" = "1" ]; then
    # Direct X11 mode (no Westonpack)
    if [ $DEBUG_MODE -eq 1 ]; then
        echo "Launching in direct X11 mode..."
        echo "DISPLAY=$DISPLAY"
        echo "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
    fi
    
    # Set up additional environment for direct X11
    export GDK_BACKEND=x11
    export QT_QPA_PLATFORM=xcb
    export SDL_VIDEODRIVER=x11
    
    # Add Greenlight binary directory to library path
    export LD_LIBRARY_PATH="$SCRIPT_DIR/greenlight-bin/opt/Greenlight:$SCRIPT_DIR/greenlight-bin/opt/Greenlight/lib:$SCRIPT_DIR/greenlight-bin/usr/lib:$LD_LIBRARY_PATH"
    
    # Launch directly
    cd "$SCRIPT_DIR/greenlight-bin/opt/Greenlight"
    if [ $DEBUG_MODE -eq 1 ]; then
        ./greenlight --verbose
    else
        ./greenlight
    fi
else
    # Westonpack mode
    if [ $DEBUG_MODE -eq 1 ]; then
        echo "Launching with runtime: $WESTONPACK_RUNTIME"
        "$WESTONPACK_RUNTIME/start.sh" "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight" --verbose
    else
        "$WESTONPACK_RUNTIME/start.sh" "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight"
    fi
fi

EXIT_CODE=$?
if [ $DEBUG_MODE -eq 1 ]; then
    echo "Greenlight exited with code: $EXIT_CODE"
    echo "Debug log saved to: $DEBUG_LOG"
    echo "Please check this file if you encountered any issues."
fi

# Exit
exit $EXIT_CODE