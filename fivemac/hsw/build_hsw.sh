#!/bin/bash

# Configuración de Rutas
HARBOUR_PATH="../../harbour"
HSW_PATH="."
OBJ_DIR="obj"
BIN_DIR="bin"
SDK_PATH=$(xcrun --show-sdk-path)

if [ -z "$1" ]; then
  echo "Uso: ./build_hsw.sh <archivo_prg_sin_extension>"
  echo "Ejemplo: ./build_hsw.sh samples/test_hsw"
  # Por defecto usaremos el test si no se especifica
  FILE_TO_BUILD="samples/test_hsw"
else
  FILE_TO_BUILD=$1
fi

APP_NAME=$(basename "$FILE_TO_BUILD")
PRG_FILE="$FILE_TO_BUILD.prg"

echo "== Building HSW App: $APP_NAME =="

# 1. Limpieza
rm -rf "$APP_NAME.app"
mkdir -p $OBJ_DIR

# 2. Compilar Swift (Motor UI en Hilo 0)
echo "Compiling Swift UI Engine..."
swiftc source/swift/HswSystem.swift \
       -emit-object \
       -module-name HswSwift \
       -parse-as-library \
       -target arm64-apple-macosx26.0 \
       -o $OBJ_DIR/HswSwift.o

# 3. Compilar HswMain (Punto de entrada Dual)
echo "Compiling HswMain (C Entry Point)..."
clang -c source/objc/hsw_main.m \
      -I$HARBOUR_PATH/include \
      -target arm64-apple-macosx26.0 \
      -fmodules \
      -o $OBJ_DIR/HswMain.o

# 4. Compilar código Harbour del usuario (Hilo 1)
echo "Compiling Harbour PRG: $PRG_FILE..."
$HARBOUR_PATH/bin/harbour "$PRG_FILE" -n -w -o"$OBJ_DIR/$APP_NAME.c" -I"$HARBOUR_PATH/include"
clang -c "$OBJ_DIR/$APP_NAME.c" -I"$HARBOUR_PATH/include" -target arm64-apple-macosx26.0 -o "$OBJ_DIR/$APP_NAME.o"

# 5. Crear estructura del Bundle .app
echo "Creating .app bundle structure..."
mkdir -p "$APP_NAME.app/Contents/MacOS"
mkdir -p "$APP_NAME.app/Contents/Resources"

# 6. Linkado Final (Usando swiftc como linker)
echo "Linking everything..."
FRAMEWORKS="-framework Cocoa -framework SwiftUI -framework AppKit -framework WebKit"
HARBOUR_LIBS="-L$HARBOUR_PATH/lib -lhbvmmt -lhbrtl -lhblang -lhbrdd -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbdebug -lgttrm -lgtstd"

swiftc -o "$APP_NAME.app/Contents/MacOS/$APP_NAME" \
    $OBJ_DIR/HswSwift.o \
    $OBJ_DIR/HswMain.o \
    $OBJ_DIR/$APP_NAME.o \
    $HARBOUR_LIBS \
    $FRAMEWORKS \
    -Xlinker -rpath -Xlinker /usr/lib/swift

if [ $? -ne 0 ]; then echo "Linking failed"; exit 1; fi

# 7. Generar Info.plist
echo "Generating Info.plist..."
PLIST="$APP_NAME.app/Contents/Info.plist"
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>'$APP_NAME'</string>
    <key>CFBundleIdentifier</key>
    <string>com.fivetech.hsw.'$APP_NAME'</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleName</key>
    <string>'$APP_NAME'</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>' > "$PLIST"

echo "== Build Done! =="
echo "Run with: open $APP_NAME.app"
