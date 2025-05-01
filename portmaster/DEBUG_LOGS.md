# Accessing Debug Logs for Greenlight on R36S

This guide explains how to access the debug logs for Greenlight on your R36S device.

## Log Locations

The Greenlight port creates several debug logs:

1. **Main Debug Log**: `/tmp/greenlight_debug.log`
2. **Box86 Log**: `/tmp/greenlight_box86.log` (if using Box86)
3. **Box64 Log**: `/tmp/greenlight_box64.log` (if using Box64)

## Accessing Logs on ArkOS

### Method 1: Using File Manager

1. After running Greenlight and experiencing any issues, return to the main menu
2. Open the File Manager app
3. Navigate to the `/tmp` directory
4. Look for the files:
   - `greenlight_debug.log`
   - `greenlight_box86.log`
   - `greenlight_box64.log`
5. Open them with a text editor to view the contents

### Method 2: Using Terminal

If your R36S has terminal access:

1. Open the terminal application
2. Run the following commands to view the logs:
   ```bash
   # View the main debug log
   cat /tmp/greenlight_debug.log
   
   # View the Box86 log
   cat /tmp/greenlight_box86.log
   
   # View the Box64 log
   cat /tmp/greenlight_box64.log
   ```

3. To see just the last 50 lines of a log:
   ```bash
   tail -n 50 /tmp/greenlight_debug.log
   ```

4. To search for error messages:
   ```bash
   grep -i error /tmp/greenlight_debug.log
   ```

### Method 3: Copy to External Storage

If you want to analyze the logs on another device:

1. Insert a USB drive into your R36S
2. Open the terminal and run:
   ```bash
   # Create a directory on your USB drive
   mkdir -p /path/to/usb/logs
   
   # Copy all logs to the USB drive
   cp /tmp/greenlight*.log /path/to/usb/logs/
   ```

## What to Look For in the Logs

### In the Main Debug Log (`greenlight_debug.log`):

1. **System Information**: Architecture, memory, and display settings
2. **Binary Information**: File type and permissions
3. **Runtime Detection**: Whether Box86/Box64 was found
4. **Error Messages**: Any lines containing "error", "failed", or "segmentation fault"

### In Box86/Box64 Logs:

1. **Missing Libraries**: Look for "missing library" or "cannot open shared object" messages
2. **Emulation Errors**: Issues with the emulation layer
3. **Memory Errors**: Out of memory or segmentation faults

## Common Error Messages and Solutions

### "Exec format error"
This means the binary architecture doesn't match your device. Make sure you're using the ARM-specific script with Box86/Box64.

### "Cannot open shared object file"
Missing libraries. Check which libraries are missing and install them:
```bash
sudo apt install [library-name]
```

### "Segmentation fault"
This could be due to memory issues or incompatible libraries. Try:
1. Closing other applications to free memory
2. Updating Box86/Box64 to the latest version

## Getting Help with Logs

If you need assistance interpreting the logs:

1. Copy the relevant portions of the logs
2. Share them in the Portmaster forums or Discord
3. Include information about your R36S model and OS version

Remember that logs in `/tmp` are temporary and will be cleared when you reboot your device. If you need to keep them for troubleshooting, copy them to permanent storage before rebooting.