# Debugging the Greenlight Port

If you're experiencing issues with the Greenlight port, such as black screens, crashes, or returning to the main menu, follow this debugging guide to identify and fix the problem.

## Common Issues and Solutions

### Black Screen Blinking and Returning to Main Menu

This typically indicates that the application is starting but crashing immediately. Here are steps to diagnose and fix:

1. **Enable Debug Logging**

   Edit the `greenlight.sh` script to add debug output:

   ```bash
   # Add these lines near the top of the script
   DEBUG_LOG="$SCRIPT_DIR/greenlight_debug.log"
   exec > >(tee -a "$DEBUG_LOG") 2>&1
   echo "=== Greenlight Debug Log $(date) ==="
   ```

2. **Check Binary Permissions**

   Make sure the Greenlight binary is executable:

   ```bash
   chmod +x "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight"
   ```

3. **Check Library Dependencies**

   The most common cause of immediate crashes is missing libraries. Run:

   ```bash
   cd "$SCRIPT_DIR"
   ldd ./greenlight-bin/opt/Greenlight/greenlight
   ```

   Look for any "not found" entries and install the missing libraries.

4. **Run Directly with Westonpack**

   Try running the binary directly with Westonpack to see error messages:

   ```bash
   cd "$SCRIPT_DIR"
   WESTONPACK_RUNTIME="$PORTMASTER_DIR/runtime/westonpack"
   "$WESTONPACK_RUNTIME/start.sh" ./greenlight-bin/opt/Greenlight/greenlight --verbose
   ```

5. **Check for X11 Support**

   Greenlight requires X11. Make sure Westonpack is properly installed and configured.

## Specific Debugging for R36S Devices

The R36S may have specific issues:

1. **Check GPU Driver**

   Ensure the device has proper GPU drivers installed:

   ```bash
   # Add to greenlight.sh before launching the app
   echo "GPU Information:"
   glxinfo | grep "OpenGL renderer"
   ```

2. **Try Different Display Settings**

   Edit the `greenlight.sh` script to try different display settings:

   ```bash
   # Try these alternative settings
   export DISPLAY=:1
   # or
   export SDL_VIDEODRIVER=x11
   ```

3. **Check Available Memory**

   Low memory can cause crashes. Add to your script:

   ```bash
   echo "Available memory:"
   free -m
   ```

## Creating a Complete Debug Log

For thorough debugging, modify your `greenlight.sh` script with this section:

```bash
# Add near the top of the script
DEBUG_LOG="$SCRIPT_DIR/greenlight_debug.log"
rm -f "$DEBUG_LOG"  # Clear previous log
exec > >(tee -a "$DEBUG_LOG") 2>&1

echo "=== Greenlight Debug Log $(date) ==="
echo "System information:"
uname -a
echo "Memory:"
free -m
echo "Display settings:"
echo "DISPLAY=$DISPLAY"
echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
echo "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
echo "Checking Greenlight binary:"
ls -la "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight"
echo "Library dependencies:"
ldd "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight" || echo "ldd command failed"
echo "GPU information:"
glxinfo | grep "OpenGL renderer" || echo "glxinfo not available"
```

After running the app and experiencing the crash, check the `greenlight_debug.log` file for clues.

## Fixing Common Issues

1. **Missing Libraries**

   If you identify missing libraries, you can either:
   - Install them on your device
   - Copy the libraries into the port's `libs` directory and modify `greenlight.sh` to add:
     ```bash
     export LD_LIBRARY_PATH="$SCRIPT_DIR/libs:$LD_LIBRARY_PATH"
     ```

2. **X11 Issues**

   If X11 is not working properly:
   - Make sure Westonpack is correctly installed
   - Try adding these environment variables:
     ```bash
     export SDL_VIDEODRIVER=x11
     export QT_QPA_PLATFORM=xcb
     ```

3. **Permission Issues**

   Fix any permission problems:
   ```bash
   find "$SCRIPT_DIR" -type f -name "*.sh" -exec chmod +x {} \;
   chmod +x "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight"
   ```

## Submitting Debug Information

If you're still experiencing issues, please submit:
1. The `greenlight_debug.log` file
2. Your device model and OS version
3. A description of the exact behavior you're seeing

This will help us improve the port for your specific device.