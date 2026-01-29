#!/bin/bash

# Configuration
APP_NAME="Fivedit"
HBP_FILE="fivedit.hbp"
HARBOUR_BIN="../../../harbour/bin"
FIVEMAC_BASE="../.."
RESOURCES_BASE="$FIVEMAC_BASE/Resources"

echo "Building $APP_NAME..."

# 1. Build binary with hbmk2
echo "== Compiling $APP_NAME with hbmk2 =="
if [ ! -f "$HARBOUR_BIN/hbmk2" ]; then
    echo "Error: hbmk2 not found at $HARBOUR_BIN/hbmk2"
    exit 1
fi

"$HARBOUR_BIN/hbmk2" "$HBP_FILE"
if [ $? -ne 0 ]; then echo "hbmk2 build failed"; exit 1; fi

# 2. Create Folders
echo "== Creating App Bundle structure =="
rm -rf "$APP_NAME.app"
mkdir -p "$APP_NAME.app/Contents/MacOS"
mkdir -p "$APP_NAME.app/Contents/Resources"
mkdir -p "$APP_NAME.app/Contents/Frameworks"

# 3. Move binary
mv "$APP_NAME" "$APP_NAME.app/Contents/MacOS/"

# 4. Create Info.plist
echo "== Generating Info.plist =="
PLIST="$APP_NAME.app/Contents/Info.plist"
echo '<?xml version="1.0" encoding="UTF-8"?>' > "$PLIST"
echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> "$PLIST"
echo '<plist version="1.0">' >> "$PLIST"
echo '<dict>' >> "$PLIST"
echo '    <key>CFBundleExecutable</key>' >> "$PLIST"
echo '    <string>'$APP_NAME'</string>' >> "$PLIST"
echo '    <key>CFBundleIdentifier</key>' >> "$PLIST"
echo '    <string>com.fivetech.'$APP_NAME'</string>' >> "$PLIST"
echo '    <key>CFBundleName</key>' >> "$PLIST"
echo '    <string>'$APP_NAME'</string>' >> "$PLIST"
echo '    <key>CFBundlePackageType</key>' >> "$PLIST"
echo '    <string>APPL</string>' >> "$PLIST"
echo '    <key>CFBundleIconFile</key>' >> "$PLIST"
echo '    <string>fivetech.icns</string>' >> "$PLIST"
echo '    <key>NSHighResolutionCapable</key>' >> "$PLIST"
echo '    <true/>' >> "$PLIST"
echo '    <key>NSPrincipalClass</key>' >> "$PLIST"
echo '    <string>NSApplication</string>' >> "$PLIST"
echo '    <key>NSAppTransportSecurity</key>' >> "$PLIST"
echo '    <dict>' >> "$PLIST"
echo '        <key>NSAllowsArbitraryLoads</key>' >> "$PLIST"
echo '        <true/>' >> "$PLIST"
echo '    </dict>' >> "$PLIST"
echo '</dict>' >> "$PLIST"
echo '</plist>' >> "$PLIST"

# 5. Copy Core Resources
echo "== Copying Resources =="
cp snippets.json "$APP_NAME.app/Contents/Resources/" 2>/dev/null
cp hbdocs.json "$APP_NAME.app/Contents/Resources/" 2>/dev/null
cp hbdocs.missing "$APP_NAME.app/Contents/Resources/" 2>/dev/null
cp ../../Resources/icons/fivetech.icns "$APP_NAME.app/Contents/Resources/" 2>/dev/null
if [ -d "img" ]; then
    cp -r img/* "$APP_NAME.app/Contents/Resources/"
fi

# 6. Copy Frameworks
echo "== Bundling Frameworks =="
if [ -d "$RESOURCES_BASE/frameworks/Scintilla.framework" ]; then
    cp -r "$RESOURCES_BASE/frameworks/Scintilla.framework" "$APP_NAME.app/Contents/Frameworks/"
else
    echo "Warning: Scintilla.framework not found in $RESOURCES_BASE/frameworks/"
fi

# 7. Smart Bundling Images
echo "== Smart bundling images =="
mkdir -p "$APP_NAME.app/Contents/Resources/bitmaps"
PRG_FILES="fivedit.prg CreaForm.prg CreaBuilder.prg"
IMAGES=$(grep -E -o "\"[^\"]+\.(png|jpg|tif|tiff|gif|bmp|icns)\"" $PRG_FILES | tr -d '"' | sort | uniq)

count=0
for img in $IMAGES; do
    if [ -f "../../../bitmaps/$img" ]; then
        cp "../../../bitmaps/$img" "$APP_NAME.app/Contents/Resources/bitmaps/"
        ((count++))
    fi
done
echo "  Bundled $count images."

echo "Done! Run with: open $APP_NAME.app"
