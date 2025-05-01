# Installing the Greenlight Binary

This guide explains how to properly extract and install the Greenlight Linux binary into your Portmaster port.

## Step 1: Download the Greenlight Linux Package

Download the `greenlight_2.3.2_amd64.deb` file (or the latest version) from the Greenlight GitHub releases page:
https://github.com/unknownskl/greenlight/releases

## Step 2: Extract the .deb Package

The .deb package is an archive that contains the application files. You need to extract it using the following commands:

```bash
# Create a temporary directory for extraction
mkdir -p /tmp/greenlight-extract
cd /tmp/greenlight-extract

# Extract the .deb package
ar x /path/to/greenlight_2.3.2_amd64.deb

# Extract the data archive (might be .tar.xz or .tar.gz)
tar xf data.tar.xz  # or tar xf data.tar.gz
```

## Step 3: Copy Files to the Port Directory

After extraction, you should have `opt` and `usr` directories. Copy these to your port's `greenlight-bin` directory:

```bash
# Create the destination directories
mkdir -p /path/to/greenlight/greenlight-bin/opt
mkdir -p /path/to/greenlight/greenlight-bin/usr

# Copy the files
cp -r opt/* /path/to/greenlight/greenlight-bin/opt/
cp -r usr/* /path/to/greenlight/greenlight-bin/usr/
```

## Step 4: Verify the Installation

The main Greenlight executable should be located at:
`/path/to/greenlight/greenlight-bin/opt/Greenlight/greenlight`

Make sure this file exists and is executable:

```bash
chmod +x /path/to/greenlight/greenlight-bin/opt/Greenlight/greenlight
```

## Step 5: Verify the Launch Script Path

The `greenlight.sh` script is configured to look for the Greenlight executable at:
```
greenlight-bin/opt/Greenlight/greenlight
```

If your extracted files have a different path structure, you'll need to update the script. The relevant line in `greenlight.sh` is:
```bash
"$WESTONPACK_RUNTIME/start.sh" "$SCRIPT_DIR/greenlight-bin/opt/Greenlight/greenlight"
```

## Directory Structure

After installation, your port directory should have this structure:

```
greenlight/
├── greenlight.sh
├── greenlight.gptk
├── port.json
├── metadata.txt
├── README.md
└── greenlight-bin/
    ├── opt/
    │   └── Greenlight/
    │       ├── greenlight (main executable)
    │       ├── resources/
    │       └── ... (other application files)
    └── usr/
        ├── bin/
        ├── share/
        └── ... (other system files)
```

## Troubleshooting

If you encounter issues:

1. Make sure the Greenlight executable has execute permissions
2. Check that all required libraries are included
3. Verify the paths in the `greenlight.sh` script match your actual file structure
4. If the application requires additional dependencies, they may need to be installed on your device