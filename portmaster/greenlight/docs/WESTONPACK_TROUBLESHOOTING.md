# Westonpack Troubleshooting Guide

This guide helps you troubleshoot issues with the Westonpack runtime when running Greenlight on Portmaster.

## Common Issues

### 1. "Westonpack runtime not found"

If you see this error, it means the script couldn't find the Westonpack runtime in any of the standard locations.

**Solution:**
- Check if Westonpack is installed on your system
- If it's installed in a non-standard location, you can specify it by setting the `WESTONPACK_RUNTIME` environment variable before running the script:
  ```bash
  export WESTONPACK_RUNTIME=/path/to/your/westonpack
  ./greenlight-native-arm.sh
  ```

### 2. "Launcher script not found"

This error occurs when the script finds the Westonpack directory but can't find a launcher script inside it.

**Solution:**
- Check the contents of your Westonpack directory:
  ```bash
  ls -la /path/to/your/westonpack
  ```
- Look for one of these files:
  - `start.sh`
  - `westonwrap.sh`
  - `westonwrap32.sh`
  - `wp_weston`
- If you find one of these files but the script doesn't detect it, you can specify it manually:
  ```bash
  export WESTONPACK_LAUNCHER=/path/to/your/westonpack/westonwrap.sh
  ./greenlight-native-arm.sh
  ```

### 3. "Launcher script is not executable"

This error means the launcher script was found but doesn't have execute permissions.

**Solution:**
- Make the script executable:
  ```bash
  chmod +x /path/to/your/westonpack/westonwrap.sh
  ```

## Westonpack Structure in Portmaster

The Westonpack runtime in Portmaster typically has the following structure:

```
westonpack/
├── bin/
├── core
├── data/
├── fonts/
├── lib_aarch64/
├── lib_armhf/
├── libexec/
├── seatd
├── share/
├── tools/
├── version.txt
├── weston.ini
├── westonwrap.sh
├── westonwrap32.sh
└── wp_weston
```

The main launcher scripts are:
- `westonwrap.sh`: For 64-bit systems
- `westonwrap32.sh`: For 32-bit systems
- `wp_weston`: Executable that starts Weston

## Manual Launch

If the automatic detection fails, you can try launching Greenlight manually with Westonpack:

```bash
cd /path/to/westonpack
./westonwrap.sh /path/to/greenlight/greenlight-bin/greenlight --no-sandbox
```

Or directly without Westonpack:

```bash
cd /path/to/greenlight/greenlight-bin
export GDK_BACKEND=x11
export QT_QPA_PLATFORM=xcb
export SDL_VIDEODRIVER=x11
./greenlight --no-sandbox
```

## Debugging

To get more information about what's happening, run the script in debug mode:

```bash
DEBUG=1 ./greenlight-native-arm.sh
```

This will show:
- All Westonpack paths being searched
- The contents of any Westonpack directories found
- The launcher script being used
- Any errors encountered during launch

## Alternative X11 Environments

If Westonpack doesn't work for you, you can try these alternatives:

1. **Direct X11**: The script will automatically fall back to direct X11 mode if Westonpack isn't found.

2. **Xwayland**: If available on your system, you can use Xwayland instead:
   ```bash
   export GDK_BACKEND=wayland
   export QT_QPA_PLATFORM=wayland
   export SDL_VIDEODRIVER=wayland
   ./greenlight-native-arm.sh
   ```

3. **Use the alternative launch script**: Try using the `greenlight-alt.sh` script which is designed to work without Westonpack.

## Contact Support

If you continue to experience issues after trying these solutions, please file an issue on the GitHub repository with your debug log attached.