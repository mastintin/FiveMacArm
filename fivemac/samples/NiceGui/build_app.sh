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
rm -f $APPName $APPName.c $APPName.o

echo "Compiling Harbour to C..."
../../../../harbour/bin/harbour $PRG_FILE -n -I../../include -I../../../../harbour/include
if [ $? -ne 0 ]; then echo "Error compiling Harbour"; exit 1; fi

echo "Compiling C to Object..."
clang -c $APPName.c -I../../include -I../../../../harbour/include
if [ $? -ne 0 ]; then echo "Error compiling C"; exit 1; fi

echo "Creating .app bundle structure..."
mkdir -p $APPName.app/Contents/MacOS
mkdir -p $APPName.app/Contents/Resources/nicegui
mkdir -p $APPName.app/Contents/Frameworks

echo "Copying NiceGUI resources to bundle..."
if [ -d "nicegui_dist" ]; then
   cp -r nicegui_dist/* $APPName.app/Contents/Resources/nicegui/
else
   echo "Warning: nicegui_dist folder not found. Local copies only."
fi

echo "Copying Frameworks to bundle..."
if [ -d "../../frameworks" ]; then
   cp -r ../../frameworks/* $APPName.app/Contents/Frameworks/
else
   echo "Warning: frameworks folder not found at ../../frameworks"
fi

echo "Generating Info.plist..."
cat <<EOF > $APPName.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APPName</string>
    <key>CFBundleIdentifier</key>
    <string>com.fivemac.nicegui.$APPName</string>
    <key>CFBundleName</key>
    <string>$APPName</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
</dict>
</plist>
EOF

echo "Linking..."
HRBLIBS='-lhbdebug -lhbvm -lhbrtl -lhblang -lhbrdd -lgttrm -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbcpage -lhbhsx -lrddnsx'
FRAMEWORKS='-framework Cocoa -framework WebKit -framework Quartz -framework UserNotifications -framework ScreenCaptureKit -framework ScriptingBridge -framework AVKit -framework AVFoundation -framework CoreMedia -framework iokit -framework UniformTypeIdentifiers'
CRTLIB=$(xcrun --show-sdk-path)/usr/lib

clang $APPName.o -o $APPName.app/Contents/MacOS/$APPName \
      -L../../lib -lfive -lfivec -L../../../../harbour/lib $HRBLIBS $FRAMEWORKS \
      -F../../frameworks -framework Scintilla -lsqlite3 $CRTLIB/libz.tbd $CRTLIB/libpcre.tbd \
      -rpath @executable_path/../Frameworks

if [ $? -eq 0 ]; then
   echo "Successfully built $APPName.app"
   echo "Opening app..."
   open $APPName.app
else
   echo "Linking error"
fi
