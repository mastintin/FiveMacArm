# ./build.sh
# Syntax: ./build.sh <prg_file_without_extension>

if [ -z "$1" ]; then
  echo "Syntax: ./build.sh <file>"
  exit 1
fi

export HB_USER_INC=../../nativo/include
export HB_USER_LIB=../../nativo/lib

mkdir -p obj
NAME=$(basename "$1")

echo "compiling..."
../../../harbour/bin/harbour $1 -n -oobj/$NAME.c -I../include -I../../nativo/include -I../../../harbour/include

echo "compiling C module..."
clang -c obj/$NAME.c -oobj/$NAME.o -I../include -I../../nativo/include -I../../../harbour/include

echo "linking..."
HRBLIBS='-lhbdebug -lhbvm -lhbrtl -lhblang -lhbrdd -lgttrm -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbcpage -lhbhsx -lrddnsx'
FRAMEWORKS='-framework Cocoa -framework WebKit -framework Quartz -framework UserNotifications -framework ScreenCaptureKit -framework ScriptingBridge -framework AVKit -framework AVFoundation -framework CoreMedia -framework iokit -framework UniformTypeIdentifiers'
CRTLIB=$(xcrun --show-sdk-path)/usr/lib
# Add rpath so it finds Scintilla in ../Resources/frameworks
clang obj/$NAME.o -o $NAME -L../lib -lnice -L../../nativo/lib -lfive -lfivec -L../../../harbour/lib $HRBLIBS $FRAMEWORKS -F../../Resources/frameworks -framework Scintilla -lsqlite3 $CRTLIB/libz.tbd $CRTLIB/libpcre.tbd -rpath @executable_path/../../Resources/frameworks


echo "done!"
./$NAME
