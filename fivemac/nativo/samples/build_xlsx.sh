#!/bin/bash

clear

if [ $# = 0 ]; then
   echo syntax: ./build_xlsx.sh file
   exit
fi

HB_DIR=../../../harbour
XLS_INC=/Users/manuel/Fivemac/hbxlsxwriter
APPName=$1

echo "Compiling $APPName.prg..."
$HB_DIR/bin/harbour "$APPName" -n -w -oobj/ -I./../include -I$HB_DIR/include -I$XLS_INC
if [ $? -ne 0 ]; then
   exit 1
fi

echo "Compiling C module obj/$APPName.c..."
clang -ObjC "obj/$APPName.c" -c -target arm64-apple-macosx26.0 -I./../include -I$HB_DIR/include -o "obj/$APPName.o"

# Usamos el build.sh existente para el resto de la App (bundle, etc) 
# Pero necesitamos enlazar con las nuevas librerías.
# Así que ejecutamos el link manual imitando a build.sh

echo "Linking..."
CRTLIB=$(xcrun --show-sdk-path)/usr/lib
HRBLIBS="-lhbdebug -lhbvm -lhbrtl -lhblang -lhbrdd -lgttrm -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbcpage -lhbhsx -lrddnsx -lhbziparc -lhbmzip -lhbzlib -lminizip"
FRAMEWORKS='-framework Cocoa -framework WebKit -framework QuickLookUI -framework QuartzCore -framework CoreImage -framework PDFKit -framework UserNotifications -framework ScreenCaptureKit -framework ScriptingBridge -framework AVKit -framework AVFoundation -framework CoreMedia -framework iokit -framework UniformTypeIdentifiers -framework Vision -framework MapKit -framework CoreLocation'

# Creamos el bundle si no existe (usando la lógica de build.sh)
mkdir -p $APPName.app/Contents/MacOS

# Enlazamos incluyendo las librerías de Excel
clang obj/$APPName.o -o ./$APPName.app/Contents/MacOS/$APPName \
  -target arm64-apple-macosx26.0 \
  -L./../lib -lfive -lfivec \
  -L$HB_DIR/lib $HRBLIBS -lhbxlsxwriter -lxlsxwriter \
  $FRAMEWORKS -lz -lpcre

echo "Done! Running $APPName..."
./$APPName.app/Contents/MacOS/$APPName
