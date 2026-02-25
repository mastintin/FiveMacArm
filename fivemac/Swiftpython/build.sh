# build.sh para el entorno experimental Swiftpython
clear

export HARB_DIR="/Users/manuel/Fivemac/harbour"
export FIVEMAC_DIR="/Users/manuel/Fivemac/fivemac"

rm -f *.o

echo "Compilando testpython.prg..."
$HARB_DIR/bin/harbour testpython.prg -n -w -I$FIVEMAC_DIR/nativo/include -I$FIVEMAC_DIR/nativo/include/api -I$HARB_DIR/include

echo "Compilando SwiftPython.swift y PythonKit..."
# Compilamos PythonKit y nuestro puente Swift en un módulo de librería u objeto
SDKPATH=$(xcrun --show-sdk-path)
swiftc -c SwiftPython.swift \
       PythonKit/PythonKit/NumpyConversion.swift \
       PythonKit/PythonKit/Python.swift \
       PythonKit/PythonKit/PythonLibrary+Symbols.swift \
       PythonKit/PythonKit/PythonLibrary.swift \
       -emit-objc-header-path SwiftPython-Swift.h \
       -module-name SwiftPython \
       -sdk "$SDKPATH" -target arm64-apple-macos11.0

echo "Compilando puente C (testpython.c)..."
clang -ObjC testpython.c -c -I$FIVEMAC_DIR/nativo/include -I$FIVEMAC_DIR/nativo/include/api -I$HARB_DIR/include

echo "Compilando inicializador de Python (set_python_home.m)..."
clang -ObjC set_python_home.m -c -I$FIVEMAC_DIR/nativo/include -I$FIVEMAC_DIR/nativo/include/api -I$HARB_DIR/include

echo "Enlazando binario final..."
CRTLIB=$(xcrun --show-sdk-path)/usr/lib
HRBLIBS='-lhbdebug -lhbvm -lhbrtl -lhblang -lhbrdd -lgttrm -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbcpage -lhbhsx -lrddnsx'
FRAMEWORKS='-framework Cocoa -framework WebKit -framework QuartzCore -framework AVFoundation -framework CoreMedia -framework UniformTypeIdentifiers -framework UserNotifications -framework ScreenCaptureKit -framework IOKit -framework ScriptingBridge -framework AVKit -framework Foundation'

SWIFTPATH=$(xcrun --show-sdk-path)/usr/lib/swift
if [ ! -d "$SWIFTPATH" ]; then
    SWIFTPATH=/usr/lib/swift
fi

swiftc *.o -o testpython \
      -L$CRTLIB -L$FIVEMAC_DIR/nativo/lib -lfive -lfivec -L$HARB_DIR/lib $HRBLIBS \
      -F$FIVEMAC_DIR/nativo/frameworks -F./Python.xcframework/macos-arm64_x86_64/ \
      -framework Cocoa -framework WebKit -framework QuartzCore -framework AVFoundation \
      -framework CoreMedia -framework UniformTypeIdentifiers -framework UserNotifications \
      -framework ScreenCaptureKit -framework IOKit -framework ScriptingBridge -framework AVKit -framework Foundation \
      -framework Python -Xlinker -rpath -Xlinker @executable_path/Python.xcframework/macos-arm64_x86_64/ \
      $CRTLIB/libz.tbd $CRTLIB/libpcre.tbd

rm -f testpython.c *.o
echo "Terminado!"
