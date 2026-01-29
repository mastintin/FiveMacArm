# ./build.sh
# Syntax: ./build.sh <prg_file_without_extension>

if [ -z "$1" ]; then
  echo "Syntax: ./build.sh <file>"
  exit 1
fi

export HB_USER_INC=../nativo/include
export HB_USER_LIB=../nativo/lib

echo "compiling..."
../../../../harbour/bin/harbour $1 -n -I../nativo/include -I../../../../harbour/include

echo "compiling C module..."
clang -c $1.c -I../nativo/include -I../../../../harbour/include

echo "linking..."
HRBLIBS='-lhbdebug -lhbvm -lhbrtl -lhblang -lhbrdd -lgttrm -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbcpage -lhbhsx -lrddnsx'
FRAMEWORKS='-framework Cocoa -framework WebKit -framework Quartz -framework UserNotifications -framework ScreenCaptureKit -framework ScriptingBridge -framework AVKit -framework AVFoundation -framework CoreMedia -framework iokit -framework UniformTypeIdentifiers'
CRTLIB=$(xcrun --show-sdk-path)/usr/lib
# Add rpath so it finds Scintilla in ../nativo/frameworks (wait, frameworks moved too?)
clang $1.o -o $1 -L. -lnice -L../nativo/lib -lfive -lfivec -L../../../../harbour/lib $HRBLIBS $FRAMEWORKS -F../nativo/frameworks -framework Scintilla -lsqlite3 $CRTLIB/libz.tbd $CRTLIB/libpcre.tbd -rpath @executable_path/../../frameworks


echo "done!"
./$1
