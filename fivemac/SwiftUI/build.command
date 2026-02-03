#!/bin/bash
# Set working directory to the script's location
cd "$(dirname "$0")"

echo "Starting build process for SwiftUI..."
echo "------------------------------------"

# Run make
make

# Provide feedback
if [ $? -eq 0 ]; then
    echo "------------------------------------"
    echo "Build successful!"
   else
    echo "------------------------------------"
    echo "Build failed. Check the errors above."
fi

# Keep terminal open for inspection
echo ""
echo "Press any key to close this window..."
read -n 1 -s
