#!/bin/bash
# buildmk2.sh - Integrated build script using hbmk2 and make_bundle.sh
# Usage: ./buildmk2.sh <ProjectName> (without .hbp extension)

if [ -z "$1" ]; then
    echo "Usage: ./buildmk2.sh <ProjectName>"
    echo "Example: ./buildmk2.sh test_multi"
    exit 1
fi

PROJECT=$1

# 1. Locate Harbour
# Assuming standard FiveMac directory structure: fivemac/samples -> fivemac/harbour
HB_ROOT="./../../harbour"
HBMK2="$HB_ROOT/bin/hbmk2"

if [ ! -f "$HBMK2" ]; then
    echo "Error: hbmk2 build tool not found at: $HBMK2"
    echo "Please check your Harbour installation path."
    exit 1
fi

# 2. Run hbmk2 Build
if [ ! -f "$PROJECT.hbp" ]; then
    echo "Error: Project file '$PROJECT.hbp' not found."
    exit 1
fi

echo "=========================================="
echo "Step 1: Building Binary with hbmk2..."
echo "=========================================="
"$HBMK2" "$PROJECT.hbp"

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# 3. Create App Bundle
echo ""
echo "=========================================="
echo "Step 2: Creating macOS App Bundle..."
echo "=========================================="

if [ -f "./make_bundle.sh" ]; then
    chmod +x ./make_bundle.sh
    ./make_bundle.sh "$PROJECT"
else
    echo "Error: make_bundle.sh script not found."
    exit 1
fi

echo ""
echo "Build Complete: $PROJECT.app"
