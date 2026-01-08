#!/bin/bash
# make_bundle.sh - Post-build script for hbmk2 to create macOS App Bundle
# Usage: ./make_bundle.sh <AppName>

if [ -z "$1" ]; then
    echo "Usage: ./make_bundle.sh <AppName>"
    exit 1
fi

APPName=$1

# Identify Source Files (Re-used for version scanning)
PRG_FILES=""
if [ -f "$APPName.hbp" ]; then
    PRG_FILES=$(grep -E "\.prg$" "$APPName.hbp" | grep -v "^#" | tr -d ' \r')
else
    if [ -f "$APPName.prg" ]; then PRG_FILES="$APPName.prg"; fi
fi

# Extract VERSION from source code
# Looks for: #define VERSION "1.0"
VERSION="1.0"
if [ ! -z "$PRG_FILES" ]; then
    DETECTED_VER=$(cat $PRG_FILES 2>/dev/null | grep -E "^\s*#\s*define\s+VERSION\s+" | head -n 1 | grep -o "\".*\"" | tr -d '"')
    if [ ! -z "$DETECTED_VER" ]; then
        VERSION="$DETECTED_VER"
        echo "  Detected Version in source: $VERSION"
    fi
fi

echo "Bundling $APPName.app (Version: $VERSION)..."

# Create directory structure
mkdir -p "$APPName.app/Contents/MacOS"
mkdir -p "$APPName.app/Contents/Resources"
mkdir -p "$APPName.app/Contents/Frameworks"

# Generate Info.plist
PLIST="$APPName.app/Contents/Info.plist"
echo '<?xml version="1.0" encoding="UTF-8"?>' > "$PLIST"
echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> "$PLIST"
echo '<plist version="1.0">' >> "$PLIST"
echo '<dict>' >> "$PLIST"
echo '   <key>CFBundleExecutable</key>' >> "$PLIST"
echo "   <string>$APPName</string>" >> "$PLIST"
echo '   <key>CFBundleName</key>' >> "$PLIST"
echo "   <string>$APPName</string>" >> "$PLIST"
echo '   <key>CFBundleIdentifier</key>' >> "$PLIST"
echo "   <string>com.fivetech.$APPName</string>" >> "$PLIST"
echo '   <key>CFBundlePackageType</key>' >> "$PLIST"
echo '   <string>APPL</string>' >> "$PLIST"
echo '   <key>CFBundleShortVersionString</key>' >> "$PLIST"
echo "   <string>$VERSION</string>" >> "$PLIST"
echo '   <key>CFBundleVersion</key>' >> "$PLIST"
echo "   <string>$VERSION</string>" >> "$PLIST"
echo '   <key>CFBundleInfoDictionaryVersion</key>' >> "$PLIST"
echo '   <string>6.0</string>' >> "$PLIST"
echo '   <key>CFBundleIconFile</key>' >> "$PLIST"
echo '   <string>fivetech.icns</string>' >> "$PLIST"
echo '   <key>NSHighResolutionCapable</key>' >> "$PLIST"
echo '   <true/>' >> "$PLIST"
echo '   <key>NSPrincipalClass</key>' >> "$PLIST"
echo '   <string>NSApplication</string>' >> "$PLIST"
echo '</dict>' >> "$PLIST"
echo '</plist>' >> "$PLIST"

# Copy Executable (created by hbmk2)
if [ -f "$APPName" ]; then
    cp "$APPName" "$APPName.app/Contents/MacOS/"
else
    echo "Error: Executable '$APPName' not found!"
    exit 1
fi

# Copy Resources
cp ../icons/fivetech.icns "$APPName.app/Contents/Resources/" 2>/dev/null

# Copy Frameworks (Generic copy from ../frameworks)
if [ -d "../frameworks" ]; then
    cp -r ../frameworks/* "$APPName.app/Contents/Frameworks/"
fi

# Smart Copy: Only copy images referenced in the source code
# 1. Clean destination
if [ -d "$APPName.app/Contents/Resources/bitmaps" ]; then
   rm -rf "$APPName.app/Contents/Resources/bitmaps"
fi
mkdir -p "$APPName.app/Contents/Resources/bitmaps"

# 2. Identify Source Files
# If .hbp file exists, search for .prg files inside it. Otherwise, assume $APPName.prg
PRG_FILES=""
if [ -f "$APPName.hbp" ]; then
    # Extract .prg files from hbp (files ending in .prg, ignoring comments)
    # This regex looks for lines ending in .prg, removing whitespace
    PRG_FILES=$(grep -E "\.prg$" "$APPName.hbp" | grep -v "^#" | tr -d ' \r')
else
    # Fallback if no named hbp, assume matching prg
    if [ -f "$APPName.prg" ]; then
        PRG_FILES="$APPName.prg"
    fi
fi

echo "Scanning for images in sources..."
# 3. Scan and Copy
count=0
if [ ! -z "$PRG_FILES" ]; then
    # Find all quoted strings ending in common image extensions across identified Prg files
    # We use 'cat' to feed grep to handle multiple files easily
    IMAGES=$(cat $PRG_FILES 2>/dev/null | grep -E -o "\"[^\"]+\.(png|jpg|tif|tiff|gif|bmp|icns)\"" | tr -d '"' | sort | uniq)

    if [ -z "$IMAGES" ]; then
        echo "  No explicit image references found."
    else
        for img in $IMAGES; do
            # Check source directory (../bitmaps)
            if [ -f "./../bitmaps/$img" ]; then
                cp "./../bitmaps/$img" "$APPName.app/Contents/Resources/bitmaps/"
                ((count++))
            fi
        done
        echo "  Bundled $count images."
    fi
else
    echo "  Warning: Source files not found to scan for images."
fi

# Fallback: If 0 images found, user might want all? (Uncomment if needed)
# if [ $count -eq 0 ]; then cp -R ../bitmaps/* "$APPName.app/Contents/Resources/bitmaps/" 2>/dev/null; fi

echo "Done! $APPName.app created."
