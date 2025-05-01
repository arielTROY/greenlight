# Testing and Debugging Greenlight on R36S

This guide will help you test and debug the Greenlight port on your R36S handheld device.

## Prerequisites

1. R36S with a compatible CFW (Custom Firmware) that supports Portmaster
2. Portmaster installed on your device
3. Westonpack runtime installed through Portmaster
4. SSH access to your device (optional but recommended for debugging)

## Installation for Testing

1. Connect your R36S to your computer or use a USB drive to transfer files
2. Copy the entire `greenlight` directory to your device's Portmaster ports directory
   - Typically located at `/roms/ports/` or `/opt/system/Tools/PortMaster/ports/`
3. Download the latest Linux x64 release of Greenlight from https://github.com/unknownskl/greenlight/releases
4. Extract the downloaded file on your computer
5. Copy all files from the extracted Greenlight release to the `greenlight-bin` directory in the port on your device

## Testing

1. Launch Portmaster on your R36S
2. Find and select Greenlight from the list of ports
3. The application should start using the Westonpack runtime
4. Sign in with your Microsoft account
5. Test streaming from Xbox Cloud Gaming or your home Xbox

## Debugging

If you encounter issues, here are some debugging steps:

### SSH Debugging

1. SSH into your R36S: `ssh root@[your-r36s-ip-address]`
2. Navigate to the Portmaster logs directory: `cd /opt/system/Tools/PortMaster/logs/` or similar
3. Check the logs for Greenlight: `cat greenlight.log`

### Common Issues and Solutions

1. **Westonpack not starting:**
   - Verify Westonpack runtime is installed
   - Check Westonpack logs for errors
   - Try reinstalling the Westonpack runtime

2. **Controller not working:**
   - Check if gptokeyb is running: `ps aux | grep gptokeyb`
   - Verify the greenlight.gptk file is correctly formatted
   - Try updating gptokeyb to the latest version

3. **Application crashes:**
   - Run the script manually to see error output:
     ```
     cd /path/to/greenlight
     ./greenlight.sh
     ```
   - Check for missing dependencies
   - Verify the Greenlight binary is compatible with your device

4. **Streaming issues:**
   - Test your internet connection
   - Try lowering the streaming quality in Greenlight settings
   - Verify your Xbox Game Pass Ultimate subscription is active

## Advanced Debugging

For more advanced debugging, you can modify the `greenlight.sh` script to output more information:

1. Add `set -x` at the beginning of the script to show all commands being executed
2. Redirect output to a file: `./greenlight-bin > debug.log 2>&1`
3. Add more echo statements to track the execution flow

## Reporting Issues

If you find bugs or have suggestions for improving the port, please:

1. Collect relevant logs and error messages
2. Note the steps to reproduce the issue
3. Document your device specifications and CFW version
4. Submit an issue to the port repository or contact the porter

## Updating the Port

When new versions of Greenlight are released:

1. Download the latest Linux x64 release
2. Replace the files in the `greenlight-bin` directory
3. Test the updated version before distributing