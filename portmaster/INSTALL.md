# Greenlight for Portmaster - Installation Guide

## Prerequisites

1. A device supported by Portmaster (see https://portmaster.games/supported-devices.html)
2. Portmaster installed on your device
3. Westonpack runtime installed through Portmaster
4. An active Xbox Game Pass Ultimate subscription (for Xbox Cloud Gaming)
5. A Microsoft account

## Installation Steps

1. Download the latest Linux x64 release of Greenlight from https://github.com/unknownskl/greenlight/releases
2. Extract the downloaded file on your computer
3. Download and extract the Greenlight port for Portmaster
4. Copy all files from the extracted Greenlight release to the `greenlight-bin` directory in the port
5. Copy the entire `greenlight` directory to your device's Portmaster ports directory
6. Launch Portmaster on your device and find Greenlight in the list of ports
7. Launch Greenlight and sign in with your Microsoft account

## Troubleshooting

- If Greenlight doesn't start, make sure the Westonpack runtime is installed
- If you encounter controller issues, check the gptokeyb configuration
- For performance issues, ensure you have a stable internet connection

## Notes

- The first launch may take longer as the Westonpack runtime initializes
- Performance depends on your internet connection quality
- Some Xbox Cloud Gaming features may not be available on all devices