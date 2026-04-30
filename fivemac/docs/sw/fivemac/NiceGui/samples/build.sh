# ./build.sh
# Syntax: ./build.sh <prg_file_without_extension>

if [ -z "$1" ]; then
  echo "Syntax: ./build.sh <file>"
  exit 1
fi

export HB_USER_INC=../../nativo/include
export HB_USER_LIB=../../nativo/lib

mkdir -p obj
NAME=$(basename "$1" .prg)

echo "compiling modified components..."
# 1. Native WebView (C) 
clang -ObjC "../../nativo/source/winapi/webviews.m" -c -o obj/webviews_mod.o -I../../nativo/include -I../../../harbour/include -target arm64-apple-macosx11.0 
# 2. WebView Class (Harbour)
../../../harbour/bin/harbour ../../nativo/source/classes/webview.prg -n -oobj/webview_mod.c -I../../nativo/include -I../../../harbour/include
clang -c obj/webview_mod.c -o obj/webview_mod.o -I../../nativo/include -I../../../harbour/include
# 3. NiceCore Class (Harbour) - The one with CDNs
../../../harbour/bin/harbour ../source/NiceCore.prg -n -oobj/NiceCore_mod.c -I../include -I../../nativo/include -I../../../harbour/include
clang -c obj/NiceCore_mod.c -o obj/NiceCore_mod.o -I../include -I../../nativo/include -I../../../harbour/include
# 4. NiceChart Class
../../../harbour/bin/harbour ../source/NiceChart.prg -n -oobj/NiceChart_mod.c -I../include -I../../nativo/include -I../../../harbour/include
clang -c obj/NiceChart_mod.c -o obj/NiceChart_mod.o -I../include -I../../nativo/include -I../../../harbour/include
# 5. NiceControls Class
../../../harbour/bin/harbour ../source/NiceControls.prg -n -oobj/NiceControls_mod.c -I../include -I../../nativo/include -I../../../harbour/include
clang -c obj/NiceControls_mod.c -o obj/NiceControls_mod.o -I../include -I../../nativo/include -I../../../harbour/include
# 6. NiceLayout Class
../../../harbour/bin/harbour ../source/NiceLayout.prg -n -oobj/NiceLayout_mod.c -I../include -I../../nativo/include -I../../../harbour/include
clang -c obj/NiceLayout_mod.c -o obj/NiceLayout_mod.o -I../include -I../../nativo/include -I../../../harbour/include
# 7. NicePrinter Class
../../../harbour/bin/harbour ../source/NicePrinter.prg -n -oobj/NicePrinter_mod.c -I../include -I../../nativo/include -I../../../harbour/include
clang -c obj/NicePrinter_mod.c -o obj/NicePrinter_mod.o -I../include -I../../nativo/include -I../../../harbour/include
clang -c obj/NicePrinter_mod.c -o obj/NicePrinter_mod.o -I../include -I../../nativo/include -I../../../harbour/include
# 8. NiceTable Class
../../../harbour/bin/harbour ../source/NiceTable.prg -n -oobj/NiceTable_mod.c -I../include -I../../nativo/include -I../../../harbour/include
clang -c obj/NiceTable_mod.c -o obj/NiceTable_mod.o -I../include -I../../nativo/include -I../../../harbour/include

# 9. TSQLite Class (Harbour)
../../../harbour/bin/harbour ../../nativo/source/classes/sqlite.prg -n -oobj/sqlite_mod.c -I../../nativo/include -I../../../harbour/include
clang -c obj/sqlite_mod.c -o obj/sqlite_mod.o -I../../nativo/include -I../../../harbour/include

# 10. SQLite Native (C)
clang -c "../../nativo/source/winapi/sqlite.c" -o obj/sqlite_c_mod.o -I../../nativo/include -I../../../harbour/include

echo "compiling $1..."
../../../harbour/bin/harbour $1 -n -oobj/$NAME.c -I../include -I../../nativo/include -I../../../harbour/include

echo "compiling C module..."
clang -c obj/$NAME.c -oobj/$NAME.o -I../include -I../../nativo/include -I../../../harbour/include

echo "linking..."
HRBLIBS='-lhbdebug -lhbvm -lhbrtl -lhblang -lhbrdd -lgttrm -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbcpage -lhbhsx -lrddnsx'
FRAMEWORKS='-framework Cocoa -framework WebKit -framework Quartz -framework UserNotifications -framework ScreenCaptureKit -framework ScriptingBridge -framework AVKit -framework AVFoundation -framework CoreMedia -framework iokit -framework UniformTypeIdentifiers'
CRTLIB=$(xcrun --show-sdk-path)/usr/lib
# Add rpath so it finds Scintilla in ../Resources/frameworks
clang obj/$NAME.o obj/NiceCore_mod.o obj/NiceChart_mod.o obj/NiceControls_mod.o obj/NiceLayout_mod.o obj/NicePrinter_mod.o obj/NiceTable_mod.o obj/webview_mod.o obj/webviews_mod.o obj/sqlite_mod.o obj/sqlite_c_mod.o -o $NAME -L../../nativo/lib -lfive -lfivec -L../../../harbour/lib $HRBLIBS $FRAMEWORKS -F../../Resources/frameworks -framework Scintilla -lsqlite3 $CRTLIB/libz.tbd $CRTLIB/libpcre.tbd -rpath @executable_path/../../Resources/frameworks


echo "done!"
./$NAME
