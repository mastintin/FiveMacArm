#!/bin/bash

# build_app.sh - Fivedit M4 Clean & Build
# (C) 2026 FiveTech Software

APP_NAME="Fivedit"
HBP_FILE="fivedit.hbp"
HARBOUR_BIN="../../../harbour/bin"
FIVEMAC_BASE="../.."

echo "== Cleaning temporary files =="
rm -f fivedit.m fivedit.o scintilla.m scintilla.o CreaForm.m CreaForm.o CreaBuilder.m CreaBuilder.o
rm -f fivedit.c scintilla.c CreaForm.c CreaBuilder.c

echo "== Building $APP_NAME for Apple Silicon (M4) =="

# Use hbmk2 with explicit C and Linker architecture flags
"$HARBOUR_BIN/hbmk2" "$HBP_FILE" -cflag="-arch" -cflag="arm64" -ldflag="-arch" -ldflag="arm64"
if [ $? -ne 0 ]; then echo "hbmk2 build failed"; exit 1; fi

# Create App Bundle Structure
echo "== Creating App Bundle =="
rm -rf "$APP_NAME.app"
mkdir -p "$APP_NAME.app/Contents/MacOS"
mkdir -p "$APP_NAME.app/Contents/Resources"
mkdir -p "$APP_NAME.app/Contents/Frameworks"

# Move the generated binary
mv "$APP_NAME" "$APP_NAME.app/Contents/MacOS/"

# Generate Info.plist
cat > "$APP_NAME.app/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>$APP_NAME</string>
    <key>CFBundleIdentifier</key><string>com.fivetech.$APP_NAME</string>
    <key>CFBundleName</key><string>$APP_NAME</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleIconFile</key><string>fivetech.icns</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSPrincipalClass</key><string>NSApplication</string>
</dict>
</plist>
EOF

# Copy Core Resources
cp snippets.json "$APP_NAME.app/Contents/Resources/" 2>/dev/null
cp hbdocs.json "$APP_NAME.app/Contents/Resources/" 2>/dev/null
cp hbdocs.missing "$APP_NAME.app/Contents/Resources/" 2>/dev/null
cp ../../Resources/icons/fivetech.icns "$APP_NAME.app/Contents/Resources/" 2>/dev/null
if [ -d "img" ]; then cp -r img/* "$APP_NAME.app/Contents/Resources/"; fi

# Copy Scintilla Framework from the correct location
if [ -d "$FIVEMAC_BASE/Resources/frameworks/Scintilla.framework" ]; then
    cp -a "$FIVEMAC_BASE/Resources/frameworks/Scintilla.framework" "$APP_NAME.app/Contents/Frameworks/"
fi

# Sign the App
echo "== Signing App Bundle =="
codesign --force --deep --sign - "$APP_NAME.app"

echo "DONE! Launching..."
open "$APP_NAME.app"
