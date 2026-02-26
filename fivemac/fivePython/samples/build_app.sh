#!/bin/bash

# build_app.sh - Empaquetador profesional para aplicaciones FiveMac + Python
# Uso: ./build_app.sh <nombre_prg_sin_extension>

if [ -z "$1" ]; then
  echo "Uso: ./build_app.sh excel_nice_browse"
  exit 1
fi

APP_NAME=$1
PRG_MAIN=$1.prg
BUNDLE_DIR="$APP_NAME.app"
CONTENTS="$BUNDLE_DIR/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"
FRAMEWORKS="$CONTENTS/Frameworks"

export HARB_DIR="/Users/manuel/Fivemac/harbour"
export FIVEMAC_DIR="/Users/manuel/Fivemac/fivemac"
export OBJ_DIR="./obj"

echo "--- Iniciando Clean Build ---"
rm -rf "$BUNDLE_DIR"
mkdir -p "$OBJ_DIR"
rm -f "$OBJ_DIR"/*.o "$OBJ_DIR"/*.c

echo "--- Compilando Harbour -> C ---"
# 1. Main
$HARB_DIR/bin/harbour "$PRG_MAIN" -n -w -I$FIVEMAC_DIR/nativo/include -I$FIVEMAC_DIR/nativo/include/api -I$HARB_DIR/include -I$FIVEMAC_DIR/NiceGui/include -o$OBJ_DIR/main.c
# 2. TPython Wrapper
$HARB_DIR/bin/harbour ../source/tpython.prg -n -w -I$FIVEMAC_DIR/nativo/include -I$FIVEMAC_DIR/nativo/include/api -I$HARB_DIR/include -o$OBJ_DIR/tpython.c
# 3. NiceGUI Framework
$HARB_DIR/bin/harbour $FIVEMAC_DIR/NiceGui/source/Nice.prg -n -w -I$FIVEMAC_DIR/nativo/include -I$FIVEMAC_DIR/nativo/include/api -I$HARB_DIR/include -I$FIVEMAC_DIR/NiceGui/include -o$OBJ_DIR/Nice.c

echo "--- Compilando C -> O ---"
# Puente C-Python
clang ../source/c_python_bridge.c -c -o $OBJ_DIR/c_python_bridge.o -I$FIVEMAC_DIR/nativo/include -I$FIVEMAC_DIR/nativo/include/api -I$HARB_DIR/include \
      -F../frameworks/Python.xcframework/macos-arm64_x86_64/

# Resto de fuentes Harbour generados
for f in $OBJ_DIR/*.c; do
    name=$(basename "$f" .c)
    clang -ObjC "$f" -c -o $OBJ_DIR/$name.o -I$FIVEMAC_DIR/nativo/include -I$FIVEMAC_DIR/nativo/include/api -I$HARB_DIR/include -I$FIVEMAC_DIR/NiceGui/include
done

echo "--- Creando Estructura del Bundle ---"
mkdir -p "$MACOS"
mkdir -p "$RESOURCES/python-stdl"
mkdir -p "$RESOURCES/nicegui_dist"
mkdir -p "$FRAMEWORKS"

echo "--- Copiando Assets y Scripts ---"
# Copiar el framework de Python al bundle (desde la versión macos del xcframework)
cp -r ../frameworks/Python.xcframework/macos-arm64_x86_64/Python.framework "$FRAMEWORKS/"

# Copiar scripts desde el directorio source/pyCode
cp ../source/pyCode/*.py "$RESOURCES/"
cp -r ../python-stdl "$RESOURCES/"

# Copiar NiceGUI dist (desde el directorio central de NiceGUI)
cp -r $FIVEMAC_DIR/NiceGui/nicegui_dist "$RESOURCES/"

echo "--- Generando Info.plist ---"
PLIST="$CONTENTS/Info.plist"
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>'$APP_NAME'</string>
    <key>CFBundleIdentifier</key>
    <string>com.fivemac.python.'$APP_NAME'</string>
    <key>CFBundleName</key>
    <string>'$APP_NAME'</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>' > "$PLIST"

echo "--- Enlazando Binario Final ---"
CRTLIB=$(xcrun --show-sdk-path)/usr/lib
HRBLIBS='-lhbdebug -lhbvm -lhbrtl -lhblang -lhbrdd -lgttrm -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbcpage -lhbhsx -lrddnsx'
FRAMEWORKS_FLAGS='-framework Cocoa -framework WebKit -framework QuartzCore -framework AVFoundation -framework CoreMedia -framework UniformTypeIdentifiers -framework UserNotifications -framework ScreenCaptureKit -framework IOKit -framework ScriptingBridge -framework AVKit'

clang $OBJ_DIR/*.o -o "$MACOS/$APP_NAME" \
      -L$CRTLIB -L$FIVEMAC_DIR/nativo/lib -lfive -lfivec -L$HARB_DIR/lib $HRBLIBS \
      $FRAMEWORKS_FLAGS -F"$FRAMEWORKS" -framework Python \
      -Xlinker -rpath -Xlinker @executable_path/../Frameworks/

echo "--- ¡Hecho! ---"
echo "App generada en: $BUNDLE_DIR"
