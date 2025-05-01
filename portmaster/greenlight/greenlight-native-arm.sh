#!/bin/bash

# Greenlight launch script for native ARM builds
# This script is designed to run the native ARM build of Greenlight on ARM devices

# Enable debugging
DEBUG_MODE=1  # Set to 0 to disable debugging
DEBUG_LOG="/tmp/greenlight_debug.log"

if [ $DEBUG_MODE -eq 1 ]; then
    rm -f "$DEBUG_LOG"  # Clear previous log
    exec > >(tee -a "$DEBUG_LOG") 2>&1
    echo "=== Greenlight Native ARM Debug Log $(date) ==="
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
    echo "Architecture: $(uname -m)"
fi

# Set up environment variables
export PORTMASTER="$SCRIPT_DIR"

# Try to detect the Portmaster directory structure
# First check if we're in the standard Portmaster structure
if [ -d "$(dirname "$(dirname "$SCRIPT_DIR")")/runtime" ]; then
    export PORTMASTER_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
    echo "Found standard Portmaster directory structure: $PORTMASTER_DIR"
else
    # Check common Portmaster locations
    for pm_dir in "/storage/roms/ports/PortMaster" "/roms/ports/PortMaster" "/opt/system/Tools/PortMaster" "/userdata/system/portmaster"; do
        if [ -d "$pm_dir" ]; then
            export PORTMASTER_DIR="$pm_dir"
            echo "Found Portmaster at: $PORTMASTER_DIR"
            break
        fi
    done
    
    # If still not found, use a default
    if [ -z "$PORTMASTER_DIR" ]; then
        export PORTMASTER_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
        echo "Using default Portmaster directory: $PORTMASTER_DIR"
    fi
fi

export GREENLIGHT_DIR="$SCRIPT_DIR/greenlight-bin"

# Check if the ARM binary exists
if [ ! -f "$GREENLIGHT_DIR/greenlight" ]; then
    echo "Error: Greenlight ARM binary not found at $GREENLIGHT_DIR/greenlight"
    echo "Please extract the ARM package first. See docs/ARM_BINARY_INSTALLATION.md for instructions."
    exit 1
fi

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
    # Standard Portmaster paths
    "$PORTMASTER_DIR/runtime/westonpack"
    "/opt/system/Tools/PortMaster/runtime/westonpack"
    "/roms/ports/runtime/westonpack"
    "/roms/tools/PortMaster/runtime/westonpack"
    "/userdata/system/portmaster/runtime/westonpack"
    # Additional Portmaster paths
    "/storage/.config/PortMaster/runtime/westonpack"
    "/storage/roms/ports/PortMaster/runtime/westonpack"
    "/storage/roms/tools/PortMaster/runtime/westonpack"
    "/storage/roms/ports/PortMaster/runtime/weston"
    # System paths
    "/opt/westonpack"
    "/usr/share/westonpack"
    "/storage/roms/ports/westonpack"
    "/opt/system/westonpack"
    # Generic weston paths
    "/opt/weston"
    "/usr/share/weston"
    "/storage/roms/ports/weston"
    "/opt/system/weston"
)

# Debug: List all possible Westonpack paths
if [ $DEBUG_MODE -eq 1 ]; then
    echo "Searching for Westonpack in the following locations:"
    for path in "${WESTONPACK_PATHS[@]}"; do
        echo "  - $path"
    done
fi

WESTONPACK_FOUND=0
for path in "${WESTONPACK_PATHS[@]}"; do
    if [ -d "$path" ]; then
        # Check for different possible Westonpack launcher scripts
        if [ -f "$path/start.sh" ]; then
            export WESTONPACK_RUNTIME="$path"
            export WESTONPACK_LAUNCHER="$path/start.sh"
            WESTONPACK_FOUND=1
            if [ $DEBUG_MODE -eq 1 ]; then
                echo "Found Westonpack at: $WESTONPACK_RUNTIME with start.sh"
            fi
            break
        elif [ -f "$path/westonwrap.sh" ]; then
            export WESTONPACK_RUNTIME="$path"
            export WESTONPACK_LAUNCHER="$path/westonwrap.sh"
            WESTONPACK_FOUND=1
            if [ $DEBUG_MODE -eq 1 ]; then
                echo "Found Westonpack at: $WESTONPACK_RUNTIME with westonwrap.sh"
            fi
            break
        elif [ -f "$path/wp_weston" ] && [ -x "$path/wp_weston" ]; then
            export WESTONPACK_RUNTIME="$path"
            export WESTONPACK_LAUNCHER="$path/wp_weston"
            WESTONPACK_FOUND=1
            if [ $DEBUG_MODE -eq 1 ]; then
                echo "Found Westonpack at: $WESTONPACK_RUNTIME with wp_weston"
            fi
            break
        elif [ -f "$path/westonwrap32.sh" ]; then
            export WESTONPACK_RUNTIME="$path"
            export WESTONPACK_LAUNCHER="$path/westonwrap32.sh"
            WESTONPACK_FOUND=1
            if [ $DEBUG_MODE -eq 1 ]; then
                echo "Found Westonpack at: $WESTONPACK_RUNTIME with westonwrap32.sh"
            fi
            break
        else
            if [ $DEBUG_MODE -eq 1 ]; then
                echo "Found directory $path but no launcher script"
                echo "Contents of $path:"
                ls -la "$path"
            fi
        fi
    fi
done

# Check if Westonpack runtime is installed
if [ $WESTONPACK_FOUND -eq 0 ]; then
    echo "Westonpack runtime not found in any of the standard locations."
    echo "Checking for alternative runtimes..."
    
    # Try to find any X11 or Wayland runtime
    for runtime_dir in "$PORTMASTER_DIR/runtime/"* "/opt/system/Tools/PortMaster/runtime/"* "/roms/ports/runtime/"* "/storage/roms/ports/PortMaster/runtime/"*; do
        if [ -d "$runtime_dir" ]; then
            # Check for different possible launcher scripts
            if [ -f "$runtime_dir/start.sh" ]; then
                export WESTONPACK_RUNTIME="$runtime_dir"
                export WESTONPACK_LAUNCHER="$runtime_dir/start.sh"
                WESTONPACK_FOUND=1
                echo "Found alternative runtime at: $WESTONPACK_RUNTIME with start.sh"
                break
            elif [ -f "$runtime_dir/westonwrap.sh" ]; then
                export WESTONPACK_RUNTIME="$runtime_dir"
                export WESTONPACK_LAUNCHER="$runtime_dir/westonwrap.sh"
                WESTONPACK_FOUND=1
                echo "Found alternative runtime at: $WESTONPACK_RUNTIME with westonwrap.sh"
                break
            elif [ -f "$runtime_dir/wp_weston" ] && [ -x "$runtime_dir/wp_weston" ]; then
                export WESTONPACK_RUNTIME="$runtime_dir"
                export WESTONPACK_LAUNCHER="$runtime_dir/wp_weston"
                WESTONPACK_FOUND=1
                echo "Found alternative runtime at: $WESTONPACK_RUNTIME with wp_weston"
                break
            elif [ -f "$runtime_dir/westonwrap32.sh" ]; then
                export WESTONPACK_RUNTIME="$runtime_dir"
                export WESTONPACK_LAUNCHER="$runtime_dir/westonwrap32.sh"
                WESTONPACK_FOUND=1
                echo "Found alternative runtime at: $WESTONPACK_RUNTIME with westonwrap32.sh"
                break
            fi
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
    ls -la "$GREENLIGHT_DIR/greenlight" || echo "Binary not found!"
    
    echo "Setting executable permissions:"
    chmod +x "$GREENLIGHT_DIR/greenlight"
    ls -la "$GREENLIGHT_DIR/greenlight"
fi

# Find gptokeyb in possible locations
GPTOKEYB_PATHS=(
    "$PORTMASTER_DIR/gptokeyb"
    "$PORTMASTER_DIR/helper/gptokeyb"
    "/opt/system/Tools/PortMaster/helper/gptokeyb"
    "/roms/ports/gptokeyb"
    "/roms/tools/PortMaster/helper/gptokeyb"
    "/userdata/system/portmaster/helper/gptokeyb"
    "/opt/system/tools/gptokeyb"
    "/opt/system/gptokeyb"
    "/opt/retrodeck/tools/gptokeyb"
    "/storage/roms/ports/tools/gptokeyb"
    "/usr/local/bin/gptokeyb"
    "/usr/bin/gptokeyb"
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
    echo "Starting Greenlight Native ARM with Westonpack..."
fi

# Check for GBM libraries to fix "undefined symbol: gbm_bo_get_modifier" error
GBM_PATHS=(
    "/usr/lib/aarch64-linux-gnu"
    "/usr/lib/arm-linux-gnueabihf"
    "/lib/aarch64-linux-gnu"
    "/lib/arm-linux-gnueabihf"
    "/usr/lib"
    "/lib"
)

GBM_FOUND=0
for path in "${GBM_PATHS[@]}"; do
    if [ -d "$path" ] && ([ -f "$path/libgbm.so.1" ] || [ -f "$path/libgbm.so" ]); then
        if [ $DEBUG_MODE -eq 1 ]; then
            echo "Found GBM library at: $path"
            ls -la $path/libgbm*
        fi
        export LD_LIBRARY_PATH="$path:$LD_LIBRARY_PATH"
        GBM_FOUND=1
    fi
done

# Create a local libs directory and symlink GBM if not found
if [ $GBM_FOUND -eq 0 ]; then
    echo "GBM library not found in standard locations. Checking for alternative libraries..."
    
    # Create a local libs directory if it doesn't exist
    mkdir -p "$SCRIPT_DIR/libs"
    
    # Try to find any GBM library on the system
    GBM_LIB=$(find /usr -name "libgbm.so*" | head -n 1)
    if [ -n "$GBM_LIB" ]; then
        echo "Found GBM library at: $GBM_LIB"
        ln -sf "$GBM_LIB" "$SCRIPT_DIR/libs/libgbm.so.1"
        echo "Created symlink to GBM library in $SCRIPT_DIR/libs"
        export LD_LIBRARY_PATH="$SCRIPT_DIR/libs:$LD_LIBRARY_PATH"
    else
        echo "Warning: Could not find GBM library on the system"
    fi
fi

# Create a stub library for the missing gbm_bo_get_modifier symbol
# This is a workaround for the "undefined symbol: gbm_bo_get_modifier" error
echo "Creating stub library for GBM..."
mkdir -p "$SCRIPT_DIR/libs/stubs"

# Create a C file with the missing symbol
cat > "$SCRIPT_DIR/libs/stubs/gbm_stub.c" << 'EOF'
#include <stdint.h>
#include <stddef.h>

// Stub implementation of the missing function
uint64_t gbm_bo_get_modifier(void *bo) {
    // Return a default value that should be safe
    return 0;
}
EOF

# Try to compile the stub library if gcc is available
if command -v gcc >/dev/null 2>&1; then
    echo "Compiling GBM stub library..."
    gcc -shared -fPIC "$SCRIPT_DIR/libs/stubs/gbm_stub.c" -o "$SCRIPT_DIR/libs/stubs/libgbm_stub.so"
    if [ -f "$SCRIPT_DIR/libs/stubs/libgbm_stub.so" ]; then
        echo "Successfully created GBM stub library"
        # Add the stub library to LD_PRELOAD to override the missing symbol
        export LD_PRELOAD="$SCRIPT_DIR/libs/stubs/libgbm_stub.so:$LD_PRELOAD"
    else
        echo "Failed to compile GBM stub library"
    fi
else
    echo "gcc not found, cannot create GBM stub library"
fi

# Add system graphics libraries to path
for lib_path in "/usr/lib/aarch64-linux-gnu" "/usr/lib/arm-linux-gnueabihf" "/usr/lib/mesa" "/usr/lib/mesa-egl"; do
    if [ -d "$lib_path" ]; then
        export LD_LIBRARY_PATH="$lib_path:$LD_LIBRARY_PATH"
        if [ $DEBUG_MODE -eq 1 ]; then
            echo "Added graphics library path: $lib_path"
        fi
    fi
done

# Add Portmaster runtime libraries if available
if [ -d "$PORTMASTER_DIR/runtime/libs" ]; then
    export LD_LIBRARY_PATH="$PORTMASTER_DIR/runtime/libs:$LD_LIBRARY_PATH"
    echo "Added Portmaster runtime libraries to path"
fi

# Check for Mesa libraries
MESA_PATHS=(
    "/usr/lib/aarch64-linux-gnu/mesa"
    "/usr/lib/arm-linux-gnueabihf/mesa"
    "/usr/lib/mesa"
    "/usr/lib/mesa-egl"
)

for path in "${MESA_PATHS[@]}"; do
    if [ -d "$path" ]; then
        export LD_LIBRARY_PATH="$path:$LD_LIBRARY_PATH"
        if [ $DEBUG_MODE -eq 1 ]; then
            echo "Found Mesa libraries at: $path"
        fi
    fi
done

if [ $DEBUG_MODE -eq 1 ]; then
    echo "Final LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
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
    
    # Disable GPU acceleration completely for Electron
    export ELECTRON_DISABLE_GPU=1
    export ELECTRON_NO_ASAR=1
    export ELECTRON_NO_ATTACH_CONSOLE=1
    export ELECTRON_ENABLE_LOGGING=1
    
    # Disable hardware acceleration
    export DISABLE_GPU=1
    export DISABLE_DIRECTWRITE=1
    export DISABLE_PEPPER_3D=1
    export DISABLE_GPU_COMPOSITING=1
    export DISABLE_GPU_RASTERIZATION=1
    export DISABLE_GPU_SANDBOX=1
    
    # Add Greenlight binary directory to library path
    export LD_LIBRARY_PATH="$GREENLIGHT_DIR:$GREENLIGHT_DIR/lib:$LD_LIBRARY_PATH"
    
    # Launch directly with all GPU acceleration disabled
    cd "$GREENLIGHT_DIR"
    if [ $DEBUG_MODE -eq 1 ]; then
        echo "Launching greenlight with verbose mode and GPU acceleration disabled..."
        ./greenlight --verbose --no-sandbox --disable-gpu --disable-software-rasterizer --disable-dev-shm-usage --disable-gpu-compositing --disable-gpu-rasterization
    else
        ./greenlight --no-sandbox --disable-gpu --disable-software-rasterizer --disable-dev-shm-usage --disable-gpu-compositing --disable-gpu-rasterization
    fi
else
    # Westonpack mode
    
    # Disable GPU acceleration completely for Electron
    export ELECTRON_DISABLE_GPU=1
    export ELECTRON_NO_ASAR=1
    export ELECTRON_NO_ATTACH_CONSOLE=1
    export ELECTRON_ENABLE_LOGGING=1
    
    # Disable hardware acceleration
    export DISABLE_GPU=1
    export DISABLE_DIRECTWRITE=1
    export DISABLE_PEPPER_3D=1
    export DISABLE_GPU_COMPOSITING=1
    export DISABLE_GPU_RASTERIZATION=1
    export DISABLE_GPU_SANDBOX=1
    
    # Set GPU disable flags for Greenlight
    GREENLIGHT_FLAGS="--no-sandbox --disable-gpu --disable-software-rasterizer --disable-dev-shm-usage --disable-gpu-compositing --disable-gpu-rasterization"
    
    if [ $DEBUG_MODE -eq 1 ]; then
        echo "Launching with runtime launcher: $WESTONPACK_LAUNCHER"
        GREENLIGHT_FLAGS="$GREENLIGHT_FLAGS --verbose"
        
        # Check if the launcher script exists and is executable
        if [ ! -f "$WESTONPACK_LAUNCHER" ]; then
            echo "Error: Launcher script $WESTONPACK_LAUNCHER not found!"
            echo "Contents of $WESTONPACK_RUNTIME:"
            ls -la "$WESTONPACK_RUNTIME"
            echo "Switching to direct X11 mode..."
            
            # Set up for direct X11 mode
            export GDK_BACKEND=x11
            export QT_QPA_PLATFORM=xcb
            export SDL_VIDEODRIVER=x11
            
            # Launch directly
            cd "$GREENLIGHT_DIR"
            echo "Launching with flags: $GREENLIGHT_FLAGS"
            ./greenlight $GREENLIGHT_FLAGS
        elif [ ! -x "$WESTONPACK_LAUNCHER" ]; then
            echo "Error: Launcher script $WESTONPACK_LAUNCHER is not executable!"
            echo "Making it executable..."
            chmod +x "$WESTONPACK_LAUNCHER"
            
            # Try to launch with the now-executable script
            echo "Launching with flags: $GREENLIGHT_FLAGS"
            "$WESTONPACK_LAUNCHER" "$GREENLIGHT_DIR/greenlight" $GREENLIGHT_FLAGS
        else
            # Launch with the detected launcher script
            echo "Launching with flags: $GREENLIGHT_FLAGS"
            "$WESTONPACK_LAUNCHER" "$GREENLIGHT_DIR/greenlight" $GREENLIGHT_FLAGS
        fi
    else
        # Check if the launcher script exists and is executable
        if [ ! -f "$WESTONPACK_LAUNCHER" ]; then
            echo "Error: Launcher script $WESTONPACK_LAUNCHER not found!"
            echo "Switching to direct X11 mode..."
            
            # Set up for direct X11 mode
            export GDK_BACKEND=x11
            export QT_QPA_PLATFORM=xcb
            export SDL_VIDEODRIVER=x11
            
            # Launch directly
            cd "$GREENLIGHT_DIR"
            ./greenlight $GREENLIGHT_FLAGS
        elif [ ! -x "$WESTONPACK_LAUNCHER" ]; then
            echo "Error: Launcher script $WESTONPACK_LAUNCHER is not executable!"
            echo "Making it executable..."
            chmod +x "$WESTONPACK_LAUNCHER"
            
            # Try to launch with the now-executable script
            "$WESTONPACK_LAUNCHER" "$GREENLIGHT_DIR/greenlight" $GREENLIGHT_FLAGS
        else
            # Launch with the detected launcher script
            "$WESTONPACK_LAUNCHER" "$GREENLIGHT_DIR/greenlight" $GREENLIGHT_FLAGS
        fi
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