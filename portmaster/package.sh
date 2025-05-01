#!/bin/bash

# Package the Greenlight port for Portmaster
cd "$(dirname "$0")"

# Create the zip file
zip -r greenlight.zip greenlight/

echo "Port packaged as greenlight.zip"
echo "To complete the port, you need to:"
echo "1. Download the latest Linux x64 release of Greenlight from https://github.com/unknownskl/greenlight/releases"
echo "2. Extract the downloaded file"
echo "3. Copy all the extracted files to the greenlight-bin directory in the port"
echo "4. Make sure the Westonpack runtime is installed in Portmaster"

exit 0