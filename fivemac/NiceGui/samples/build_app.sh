#!/bin/bash

# build_app.sh - Package NiceGUI samples into macOS .app bundles

if [ -z "$1" ]; then
  echo "Syntax: ./build_app.sh <prg_file>"
  exit 1
fi

APPName=$1
PRG_FILE=$1.prg

echo "Cleaning previous build..."
rm -rf $APPName.app
rm -rf obj
mkdir -p obj

echo "Compiling Harbour to C..."
../../../harbour/bin/harbour $PRG_FILE -n -oobj/$APPName.c -I../include -I../../nativo/include -I../../../harbour/include
if [ $? -ne 0 ]; then echo "Error compiling Harbour"; exit 1; fi

echo "Compiling C to Object..."
clang -c obj/$APPName.c -oobj/$APPName.o -I../include -I../../nativo/include -I../../../harbour/include
if [ $? -ne 0 ]; then echo "Error compiling C"; exit 1; fi

echo "Creating .app bundle structure..."
mkdir -p $APPName.app/Contents/MacOS
mkdir -p $APPName.app/Contents/Resources/nicegui
mkdir -p $APPName.app/Contents/Frameworks

echo "Copying NiceGUI resources to bundle..."
if [ -d "../nicegui_dist" ]; then
   cp -r ../nicegui_dist/* $APPName.app/Contents/Resources/nicegui/
else
   echo "Warning: nicegui_dist folder not found. Local copies only."
fi

echo "Copying Frameworks to bundle..."
if [ -d "../../Resources/frameworks" ]; then
   cp -r "../../Resources/frameworks/"* $APPName.app/Contents/Frameworks/
else
   echo "Warning: frameworks folder not found at ../../Resources/frameworks"
fi

echo "Generating Info.plist..."
PLIST="$APPName.app/Contents/Info.plist"
echo '<?xml version="1.0" encoding="UTF-8"?>' > "$PLIST"
echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> "$PLIST"
echo '<plist version="1.0">' >> "$PLIST"
echo '<dict>' >> "$PLIST"
echo '   <key>CFBundleExecutable</key>' >> "$PLIST"
echo '   <string>'$APPName'</string>' >> "$PLIST"
echo '   <key>CFBundleName</key>' >> "$PLIST"
echo '   <string>'$APPName'</string>' >> "$PLIST"
echo '   <key>CFBundleIdentifier</key>' >> "$PLIST"
echo '   <string>com.fivemac.nicegui.'$APPName'</string>' >> "$PLIST"
echo '   <key>CFBundlePackageType</key>' >> "$PLIST"
echo '   <string>APPL</string>' >> "$PLIST"
echo '   <key>CFBundleInfoDictionaryVersion</key>' >> "$PLIST"
echo '   <string>6.0</string>' >> "$PLIST"
echo '   <key>CFBundleIconFile</key>' >> "$PLIST"
echo '   <string>fivetech.icns</string>' >> "$PLIST"
echo '   <key>NSHighResolutionCapable</key>' >> "$PLIST"
echo '   <true/>' >> "$PLIST"
echo '   <key>NSPrincipalClass</key>' >> "$PLIST"
echo '   <string>NSApplication</string>' >> "$PLIST"
echo '   <key>NSAppTransportSecurity</key>' >> "$PLIST"
echo '   <dict>' >> "$PLIST"
echo '      <key>NSAllowsArbitraryLoads</key>' >> "$PLIST"
echo '      <true/>' >> "$PLIST"
echo '   </dict>' >> "$PLIST"
echo '</dict>' >> "$PLIST"
echo '</plist>' >> "$PLIST"

echo 'APPL????' > "$APPName.app/Contents/PkgInfo"

echo "Copying Icon..."
if [ -f "../../Resources/icons/fivetech.icns" ]; then
   cp "../../Resources/icons/fivetech.icns" "$APPName.app/Contents/Resources/"
else
   echo "Warning: fivetech.icns not found at ../../Resources/icons/"
fi

echo "Linking..."
HRBLIBS='-lhbdebug -lhbvm -lhbrtl -lhblang -lhbrdd -lgttrm -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbcpage -lhbhsx -lrddnsx'
FRAMEWORKS='-framework Cocoa -framework WebKit -framework Quartz -framework UserNotifications -framework ScreenCaptureKit -framework ScriptingBridge -framework AVKit -framework AVFoundation -framework CoreMedia -framework iokit -framework UniformTypeIdentifiers'
CRTLIB=$(xcrun --show-sdk-path)/usr/lib

clang obj/$APPName.o -o $APPName.app/Contents/MacOS/$APPName \
      -L../lib -lnice -L../../nativo/lib -lfive -lfivec -L../../../harbour/lib $HRBLIBS $FRAMEWORKS \
      -F../../Resources/frameworks -framework Scintilla -lsqlite3 $CRTLIB/libz.tbd $CRTLIB/libpcre.tbd \
      -rpath @executable_path/../Frameworks

if [ $? -eq 0 ]; then
   echo "Successfully built $APPName.app"
   echo "Opening app..."
   open $APPName.app
else
   echo "Linking error"
fi
