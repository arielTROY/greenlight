# R36S Troubleshooting Guide for Greenlight

This guide provides solutions for common issues when running Greenlight on the Anbernic R36S device.

## Issue: "Cannot find Westonpack"

### Solution 1: Install Westonpack

Follow the instructions in the `WESTONPACK_INSTALLATION.md` file to install Westonpack on your R36S.

### Solution 2: Use the Alternative Launch Script

If you cannot install Westonpack, use the alternative launch script:

1. Rename the original script:
   ```bash
   mv greenlight.sh greenlight.sh.original
   ```

2. Copy the alternative script:
   ```bash
   cp greenlight-alt.sh greenlight.sh
   ```

3. Make it executable:
   ```bash
   chmod +x greenlight.sh
   ```

## Issue: Black Screen or Crash on Launch

### Solution 1: Check X11 Configuration

The R36S may need specific X11 configuration:

1. SSH into your R36S:
   ```bash
   ssh root@[your-r36s-ip]
   ```

2. Check if X11 is running:
   ```bash
   ps aux | grep X
   ```

3. If X11 is not running, start it:
   ```bash
   startx &
   ```

### Solution 2: Check Graphics Libraries

Greenlight requires specific graphics libraries:

1. Install required libraries:
   ```bash
   apt update
   apt install libgl1 libvulkan1 libegl1 libxkbcommon0
   ```

### Solution 3: Run in Compatibility Mode

Add these environment variables to the launch script:

```bash
export LIBGL_ALWAYS_SOFTWARE=1
export MESA_GL_VERSION_OVERRIDE=3.3
```

## Issue: No Controller Input

### Solution 1: Check gptokeyb

1. Make sure gptokeyb is installed:
   ```bash
   ls -la /opt/system/Tools/PortMaster/helper/gptokeyb
   ```

2. If missing, download it:
   ```bash
   wget -O /opt/system/Tools/PortMaster/helper/gptokeyb https://github.com/PortsMaster/PortMaster-Helper/raw/main/gptokeyb
   chmod +x /opt/system/Tools/PortMaster/helper/gptokeyb
   ```

### Solution 2: Update Controller Mapping

If your controller isn't working correctly:

1. Edit the `greenlight.gptk` file
2. Update the button mappings to match your controller
3. Save and try again

## Issue: Performance Problems

### Solution 1: Lower Resolution

Edit the launch script to add these environment variables:

```bash
export GDK_SCALE=0.75
export QT_SCALE_FACTOR=0.75
```

### Solution 2: Disable Effects

Add these environment variables:

```bash
export GREENLIGHT_DISABLE_EFFECTS=1
export GREENLIGHT_LOW_PERFORMANCE=1
```

## Issue: Network Connection Problems

### Solution 1: Check WiFi

1. Make sure your R36S is connected to WiFi
2. Test the connection:
   ```bash
   ping -c 3 xbox.com
   ```

### Solution 2: Update DNS

If you have connection issues:

1. Edit `/etc/resolv.conf`
2. Add these lines:
   ```
   nameserver 1.1.1.1
   nameserver 8.8.8.8
   ```

## Issue: Audio Problems

### Solution 1: Check Audio Device

1. List audio devices:
   ```bash
   aplay -l
   ```

2. Set the correct audio device:
   ```bash
   export ALSA_CARD=0
   export ALSA_PCM_CARD=0
   ```

### Solution 2: Fix PulseAudio

If using PulseAudio:

1. Restart PulseAudio:
   ```bash
   pulseaudio -k
   pulseaudio --start
   ```

## Getting Logs for Debugging

If you need to troubleshoot further:

1. Modify the launch script to save logs:
   ```bash
   ./greenlight "$@" > /tmp/greenlight.log 2>&1
   ```

2. Check the logs:
   ```bash
   cat /tmp/greenlight.log
   ```

3. Share these logs when asking for help

## Contact for Support

If you continue to have issues, please:

1. Create an issue on the GitHub repository
2. Include your R36S model and firmware version
3. Attach any error logs
4. Describe the steps you've already tried