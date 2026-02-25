# build_c.sh para el entorno experimental CPython directo (sin Swift)
clear

export HARB_DIR="/Users/manuel/Fivemac/harbour"
export FIVEMAC_DIR="/Users/manuel/Fivemac/fivemac"

rm -f *.o

echo "Compilando test_c_python.prg y tpython.prg..."
$HARB_DIR/bin/harbour test_c_python.prg -n -w -I$FIVEMAC_DIR/nativo/include -I$FIVEMAC_DIR/nativo/include/api -I$HARB_DIR/include
$HARB_DIR/bin/harbour tpython.prg -n -w -I$FIVEMAC_DIR/nativo/include -I$FIVEMAC_DIR/nativo/include/api -I$HARB_DIR/include

echo "Compilando puente CPython API (c_python_bridge.c)..."
clang c_python_bridge.c -c -I$FIVEMAC_DIR/nativo/include -I$FIVEMAC_DIR/nativo/include/api -I$HARB_DIR/include \
      -F./Python.xcframework/macos-arm64_x86_64/ -framework Python

echo "Compilando puente intermedio generado por Harbour (test_c_python.c y tpython.c)..."
clang -ObjC test_c_python.c -c -I$FIVEMAC_DIR/nativo/include -I$FIVEMAC_DIR/nativo/include/api -I$HARB_DIR/include
clang -ObjC tpython.c -c -I$FIVEMAC_DIR/nativo/include -I$FIVEMAC_DIR/nativo/include/api -I$HARB_DIR/include

echo "Enlazando binario final..."
CRTLIB=$(xcrun --show-sdk-path)/usr/lib
HRBLIBS='-lhbdebug -lhbvm -lhbrtl -lhblang -lhbrdd -lgttrm -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbcpage -lhbhsx -lrddnsx'
FRAMEWORKS='-framework Cocoa -framework WebKit -framework QuartzCore -framework AVFoundation -framework CoreMedia -framework UniformTypeIdentifiers -framework UserNotifications -framework ScreenCaptureKit -framework IOKit -framework ScriptingBridge -framework AVKit'

clang test_c_python.o tpython.o c_python_bridge.o -o test_c_python \
      -L$CRTLIB -L$FIVEMAC_DIR/nativo/lib -lfive -lfivec -L$HARB_DIR/lib $HRBLIBS \
      $FRAMEWORKS -F$FIVEMAC_DIR/nativo/frameworks -F./Python.xcframework/macos-arm64_x86_64/ \
      -framework Python -Xlinker -rpath -Xlinker @executable_path/Python.xcframework/macos-arm64_x86_64/ \
      $CRTLIB/libz.tbd $CRTLIB/libpcre.tbd

rm -f test_c_python.c *.o
echo "Terminado!"
