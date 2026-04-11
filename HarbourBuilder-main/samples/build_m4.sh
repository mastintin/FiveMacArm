#!/bin/bash
# build_m4.sh - Build HarbourBuilder for Apple Silicon (M4) using Framework
#
# Usage: ./build_m4.sh

set -e

# 1. Paths (Direct to your M4 installations)
HBDIR="/Users/manuel/Fivemac/harbour"
PROJDIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC="hbbuilder_macos"
PROG="HbBuilder"

# POINT TO THE FRAMEWORKS DIRECTORY (TO USE <Scintilla/ScintillaView.h>)
FRAMEWORKS_DIR="/Users/manuel/Fivemac/fivemac/Resources/frameworks"

cd "$(dirname "$0")"

# Detect Harbour bin
HBBIN="$HBDIR/bin"
HBLIB="$HBDIR/lib"
HBINC="$HBDIR/include"

echo "== Building HarbourBuilder for M4 (ARM64) =="

# [1/4] Harbour → C
echo "[1/4] Compiling ${SRC}.prg..."
"$HBBIN/harbour" ${SRC}.prg -n -w -q \
   -I"$HBINC" \
   -I"$PROJDIR/include" \
   -I"$PROJDIR/harbour" \
   -o${SRC}.c

# [2/4] C → Object (Native ARM64)
echo "[2/4] Compiling ${SRC}.c..."
clang -c -O2 -arch arm64 -Wno-unused-value \
   -I"$HBINC" \
   ${SRC}.c -o ${SRC}.o

# [3/4] Cocoa sources (Native ARM64)
echo "[3/4] Compiling Cocoa backends..."
clang -c -O2 -arch arm64 -fobjc-arc -I"$HBINC" \
   "$PROJDIR/backends/cocoa/cocoa_core.m" -o cocoa_core.o

clang -c -O2 -arch arm64 -fobjc-arc -I"$HBINC" \
   "$PROJDIR/backends/cocoa/cocoa_inspector.m" -o cocoa_inspector.o

# [3b/4] Scintilla editor (Using FRAMEWORK-style includes)
echo "[3b/4] Compiling cocoa_editor.mm..."
clang++ -c -O2 -arch arm64 -fobjc-arc -std=c++17 \
   -I"$HBINC" \
   -I"$FRAMEWORKS_DIR/Scintilla.framework/Headers" \
   -I"$PROJDIR/resources/scintilla_src/lexilla/include" \
   "$PROJDIR/backends/cocoa/cocoa_editor.mm" -o cocoa_editor.o

# [4/4] Linking (DYNAMIC Framework linking)
echo "[4/4] Linking ${PROG} for ARM64..."
clang++ -o ${PROG} -arch arm64 \
   ${SRC}.o cocoa_core.o cocoa_inspector.o cocoa_editor.o \
   -L"$HBLIB" \
   -lhbvm -lhbrtl -lhbcommon -lhbcpage -lhblang \
   -lhbmacro -lhbpp -lhbrdd -lhbcplr -lhbdebug \
   -lhbct -lhbextern -lhbsqlit3 \
   -lrddntx -lrddnsx -lrddcdx -lrddfpt \
   -lhbhsx -lhbsix -lhbusrrdd \
   -lgtcgi -lgttrm -lgtstd \
   -F"$FRAMEWORKS_DIR" \
   -framework Scintilla \
   -framework Cocoa \
   -framework QuartzCore \
   -framework UniformTypeIdentifiers \
   -Wl,-rpath,@executable_path/../Frameworks \
   -Wl,-rpath,"$FRAMEWORKS_DIR" \
   -lm -lpthread -lc++ -lsqlite3

# Create App bundle
APP="$PROJDIR/bin/HbBuilder_M4.app"
echo "== Creating HbBuilder_M4.app bundle =="
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"
mkdir -p "$APP/Contents/Frameworks"

# Copy binary
cp "${PROG}" "$APP/Contents/MacOS/HbBuilder"

# Copy framework into bundle for standalone use
cp -R "$FRAMEWORKS_DIR/Scintilla.framework" "$APP/Contents/Frameworks/"

# Copy Info.plist and resources from the original Intel app
cp "$PROJDIR/bin/HbBuilder.app/Contents/Info.plist" "$APP/Contents/"
cp -R "$PROJDIR/bin/HbBuilder.app/Contents/Resources/"* "$APP/Contents/Resources/"

echo "DONE! Your M4 HarbourBuilder is ready."
open "$APP"
