# R36S Specific Troubleshooting for Greenlight

This guide provides specific troubleshooting steps for running Greenlight on the Anbernic R36S device.

## Common R36S Issues

### Black Screen Blinking and Returning to Main Menu

If Greenlight starts but immediately shows a black screen that blinks twice before returning to the main menu, try these R36S-specific fixes:

## 1. Check for Missing Libraries

The R36S may be missing some libraries required by Greenlight. Check the debug log at `/tmp/greenlight_debug.log` after attempting to run the app.

Common missing libraries on R36S include:
- libvulkan.so.1
- libEGL.so.1
- libGLESv2.so.2
- libxcb.so.1

### Solution:

Create a `libs` directory in your port folder and copy the missing libraries from your system:

```bash
# On your Linux PC, find the libraries
find /usr/lib -name "libvulkan.so.1"
find /usr/lib -name "libEGL.so.1"
# etc.

# Copy them to a USB drive, then to your R36S in the port's libs directory
mkdir -p /path/to/portmaster/ports/greenlight/libs
cp /path/from/usb/lib*.so* /path/to/portmaster/ports/greenlight/libs/
```

## 2. Try Alternative Display Settings

The R36S may need different display settings. Edit the `greenlight.sh` script and try these alternatives:

```bash
# Try these different display settings one at a time
export DISPLAY=:1
# or
export SDL_VIDEODRIVER=wayland
# or
export SDL_VIDEODRIVER=kms
# or
export QT_QPA_PLATFORM=wayland
```

## 3. Check Westonpack Configuration

Make sure Westonpack is properly configured on your R36S:

1. Go to Portmaster settings
2. Check that Westonpack runtime is installed and up to date
3. Try reinstalling Westonpack if necessary

## 4. Memory Management

The R36S has limited RAM. Before launching Greenlight:

1. Close all other applications
2. Restart your device to clear memory
3. Edit `greenlight.sh` to add memory optimization:

```bash
# Add before launching Greenlight
sync
echo 3 > /proc/sys/vm/drop_caches  # Requires root
```

## 5. GPU Driver Issues

The R36S uses Mali GPU which may have compatibility issues with Greenlight:

1. Check your GPU driver in the debug log
2. Try updating your R36S firmware to the latest version
3. If using a custom firmware, ensure it has proper GPU drivers

## 6. Try Different Greenlight Version

If the latest version doesn't work, try an older version:

1. Download an older version of Greenlight for Linux
2. Replace the binary in the `greenlight-bin` directory
3. Make sure to set executable permissions:
   ```bash
   chmod +x /path/to/portmaster/ports/greenlight/greenlight-bin/opt/Greenlight/greenlight
   ```

## 7. Check Resource Usage

If Greenlight is crashing due to resource limitations:

1. Edit `greenlight.sh` to monitor resource usage:
   ```bash
   # Add before launching Greenlight
   echo "CPU usage:"
   top -n 1 -b | head -n 20
   echo "Memory usage:"
   free -m
   ```

2. Check the log after a crash to see if you're running out of resources

## 8. File a Detailed Bug Report

If you still can't get Greenlight working on your R36S:

1. Collect the debug log from `/tmp/greenlight_debug.log`
2. Note your R36S firmware version and any modifications
3. Describe the exact behavior (black screen, crash, etc.)
4. Submit this information to help improve compatibility

## Additional R36S Tips

- The R36S performs best with lightweight applications
- Make sure your device is not overheating during use
- Consider using a cooling fan if available
- Keep your R36S firmware updated to the latest version
- Some users report better results with custom firmware like JELOS