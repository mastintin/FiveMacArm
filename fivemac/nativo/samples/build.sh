# ./build.sh - (c) FiveTech Software 2007-2018

clear

if [ $# = 0 ]; then
   echo syntax: ./build.sh file [options...]
   exit
fi

if [ "$1" = "clean" ]; then
   echo cleaning...
   rm -rf obj
   rm -rf *.app
   exit
fi

echo compiling...

APPName=$1
mkdir -p obj
OBJS=""
PRG_FILES=""

# Populate PRG_FILES for auto-detection
for FILE in "$@"; do
    if [ -f "$FILE.prg" ]; then
        PRG_FILES="$PRG_FILES $FILE.prg"
    fi
done

USE_SCINTILLA=0
USE_MYSQL=0
for arg in "$@"; do
    if [ "$arg" == "-scintilla" ]; then
        USE_SCINTILLA=1
    fi
    if [ "$arg" == "-mysql" ]; then
        USE_MYSQL=1
    fi
done

if [ $USE_SCINTILLA -eq 1 ]; then
    echo "  Scintilla enabled via flag"
    SCINTILLA_FRAMEWORK="-framework Scintilla"
else
    SCINTILLA_FRAMEWORK=""
fi

if [ $USE_MYSQL -eq 1 ]; then
    echo "  MySQL enabled via flag"
    MYSQL_INC="-I/opt/homebrew/Cellar/mariadb/12.1.2/include/mysql"
    MYSQL_LIBS="-lhbmysql -lmariadb -lssl -lcrypto"
else
    MYSQL_INC=""
    MYSQL_LIBS=""
fi

# Loop through all arguments (files)
HB_DIR=../../../harbour
for FILE in "$@"; do
    if [[ "$FILE" == -* ]]; then
        continue
    fi
    echo "Compiling $FILE.prg..."
    $HB_DIR/bin/harbour "$FILE" -n -w -oobj/ -I./../include -I$HB_DIR/include 
    if [ $? -ne 0 ]; then
       echo "Error compiling $FILE.prg"
       exit 1
    fi   

    echo "Compiling C module obj/$FILE.c..."
    #  add -arch ppc -arch i386 for universal binaries
    SDKPATH=$(xcrun --show-sdk-path)
    clang -ObjC "obj/$FILE.c" -c -target arm64-apple-macosx26.0 -I./../include -I$HB_DIR/include $MYSQL_INC -o "obj/$FILE.o"
    if [ $? -ne 0 ]; then
       echo "Error compiling $FILE.c"
       exit 1
    fi
    
    OBJS="$OBJS obj/$FILE.o"
    PRG_FILES="$PRG_FILES $FILE.prg"
done

# Force compilation of modified TWebview components
echo "Compiling modified WebView components (classes and winapi)..."

# Compile webview.prg
$HB_DIR/bin/harbour "../source/classes/webview.prg" -n -w -q -oobj/ -I./../include -I$HB_DIR/include
clang -ObjC "obj/webview.c" -c -target arm64-apple-macosx26.0 -I./../include -I$HB_DIR/include -o "obj/webview_mod.o"
OBJS="$OBJS obj/webview_mod.o"

# Compile webviews.m
clang -ObjC "../source/winapi/webviews.m" -c -target arm64-apple-macosx26.0 -I./../include -I$HB_DIR/include -o "obj/webviews_mod.o"
OBJS="$OBJS obj/webviews_mod.o"

# Compile get.prg (TGet with WHEN clause)
echo "Compiling modified TGet..."
$HB_DIR/bin/harbour "../source/classes/get.prg" -n -w -q -oobj/ -I./../include -I$HB_DIR/include
clang -ObjC "obj/get.c" -c -target arm64-apple-macosx26.0 -I./../include -I$HB_DIR/include -o "obj/get_mod.o"
OBJS="$OBJS obj/get_mod.o"

# Compile sqlite.prg (enhanced TSQLite)
echo "Compiling modified TSQLite..."
$HB_DIR/bin/harbour "../source/classes/sqlite.prg" -n -w -q -oobj/ -I./../include -I$HB_DIR/include
clang -c "obj/sqlite.c" -target arm64-apple-macosx26.0 -I./../include -I$HB_DIR/include -o "obj/sqlite_mod.o"
OBJS="$OBJS obj/sqlite_mod.o"

# Compile sqlite.c (native part)
clang -c "../source/winapi/sqlite.c" -target arm64-apple-macosx26.0 -I./../include -I$HB_DIR/include -o "obj/sqlite_c_mod.o"
OBJS="$OBJS obj/sqlite_c_mod.o"

# Compile mysql.prg (enhanced TMySQL)
# Moved back to libfive.a

# Scintilla components are now linked from lib/libscintilla.a
if [ $USE_SCINTILLA -eq 1 ]; then
    SCINTILLA_LIB="-lscintilla"
else
    SCINTILLA_LIB=""
fi
echo "Compiling modified musics.m..."
clang -ObjC "../source/winapi/musics.m" -c -target arm64-apple-macosx26.0 -I./../include -I$HB_DIR/include -o "obj/musics_mod.o"
OBJS="$OBJS obj/musics_mod.o"

# Compile cifilters.m (New Filter Logic)
echo "Compiling cifilters.m..."
clang -ObjC "../source/winapi/cifilters.m" -c -target arm64-apple-macosx26.0 -I./../include -I$HB_DIR/include -o "obj/cifilters_mod.o"
OBJS="$OBJS obj/cifilters_mod.o"

if [ ! -d $APPName.app ]; then
   mkdir $APPName.app
fi   
if [ ! -d $APPName.app/Contents ]; then
   mkdir $APPName.app/Contents
fi

if [ ! -d $APPName.app/Contents ]; then
   mkdir $APPName.app/Contents
fi

if [ ! -f $APPName.app/Contents/Info.plist ]; then
   echo '<?xml version="1.0" encoding="UTF-8"?>' > $APPName.app/Contents/Info.plist
   echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $APPName.app/Contents/Info.plist
   echo '<plist version="1.0">' >> $APPName.app/Contents/Info.plist
   echo '<dict>' >> $APPName.app/Contents/Info.plist
   echo '   <key>CFBundleExecutable</key>' >> $APPName.app/Contents/Info.plist
   echo '   <string>'$APPName'</string>' >> $APPName.app/Contents/Info.plist
   echo '   <key>CFBundleName</key>' >> $APPName.app/Contents/Info.plist
   echo '   <string>'$APPName'</string>' >> $APPName.app/Contents/Info.plist
   echo '   <key>CFBundleIdentifier</key>' >> $APPName.app/Contents/Info.plist
   echo '   <string>com.fivetech.'$APPName'</string>' >> $APPName.app/Contents/Info.plist
   echo '   <key>CFBundlePackageType</key>' >> $APPName.app/Contents/Info.plist
   echo '   <string>APPL</string>' >> $APPName.app/Contents/Info.plist
   echo '   <key>CFBundleInfoDictionaryVersion</key>' >> $APPName.app/Contents/Info.plist
   echo '   <string>6.0</string>' >> $APPName.app/Contents/Info.plist
   echo '   <key>CFBundleIconFile</key>' >> $APPName.app/Contents/Info.plist
   echo '   <string>fivetech.icns</string>' >> $APPName.app/Contents/Info.plist
   echo '   <key>NSHighResolutionCapable</key>' >> $APPName.app/Contents/Info.plist
   echo '<true/>' >> $APPName.app/Contents/Info.plist
   echo '   <key>NSPrincipalClass</key>' >> $APPName.app/Contents/Info.plist
   echo '   <string>NSApplication</string>' >> $APPName.app/Contents/Info.plist
   echo '   <key>NSAppTransportSecurity</key>' >> $APPName.app/Contents/Info.plist
   echo '   <dict>' >> $APPName.app/Contents/Info.plist
   echo '      <key>NSAllowsArbitraryLoads</key>' >> $APPName.app/Contents/Info.plist
   echo '      <true/>' >> $APPName.app/Contents/Info.plist
   echo '   </dict>' >> $APPName.app/Contents/Info.plist
   echo '   <key>NSAppleEventsUsageDescription</key>' >> $APPName.app/Contents/Info.plist
   echo '   <string>This app needs to control the Music app to play songs.</string>' >> $APPName.app/Contents/Info.plist
   echo '</dict>' >> $APPName.app/Contents/Info.plist
   echo '</plist>' >> $APPName.app/Contents/Info.plist

   echo 'APPL????' > $APPName.app/Contents/PkgInfo
fi
if [ ! -d $APPName.app/Contents/MacOS ]; then
   mkdir $APPName.app/Contents/MacOS
fi  
if [ ! -d $APPName.app/Contents/Resources ]; then
   mkdir $APPName.app/Contents/Resources
   cp ./../../Resources/icons/fivetech.icns $APPName.app/Contents/Resources/
fi 

# Smart Copy: Only copy images referenced in the source code
# First, clean existing bitmaps to ensure we don't keep unused ones from previous builds
if [ -d "$APPName.app/Contents/Resources/bitmaps" ]; then
   rm -rf "$APPName.app/Contents/Resources/bitmaps"
fi
mkdir -p "$APPName.app/Contents/Resources/bitmaps"

# Smart Copy: Only copy images referenced in the source code
# First, clean existing bitmaps to ensure we don't keep unused ones from previous builds
if [ -d "$APPName.app/Contents/Resources/bitmaps" ]; then
   rm -rf "$APPName.app/Contents/Resources/bitmaps"
fi
mkdir -p "$APPName.app/Contents/Resources/bitmaps"

echo "Smart bundling images..."
# Find all quoted strings ending in common image extensions across ALL Prg files
IMAGES=$(grep -E -o "\"[^\"]+\.(png|jpg|tif|tiff|gif|bmp|icns)\"" $PRG_FILES | tr -d '"' | sort | uniq)

if [ -z "$IMAGES" ]; then
    echo "  No explicit image references found in source files"
else
    count=0
    for img in $IMAGES; do
        # Extract filename only in case grep returns File:match format (though -o usually avoids this, with multiple files grep adds filename:)
        # Actually with multiple files grep -o outputs "filename:match". We need to handle that.
        # simpler: cat all files and grep.
        if [ -f "./../bitmaps/$img" ]; then
            cp "./../bitmaps/$img" "$APPName.app/Contents/Resources/bitmaps/"
            ((count++))
        fi
    done
    
    # Retry with cat if count is 0, to handle grep output format difference
    if [ $count -eq 0 ]; then
       IMAGES=$(cat $PRG_FILES | grep -E -o "\"[^\"]+\.(png|jpg|tif|tiff|gif|bmp|icns)\"" | tr -d '"' | sort | uniq)
       for img in $IMAGES; do
          if [ -f "./../bitmaps/$img" ]; then
             cp "./../bitmaps/$img" "$APPName.app/Contents/Resources/bitmaps/"
             ((count++))
          fi
       done
    fi

    echo "  Bundled $count images."
fi

# Fallback/Legacy: If you want to copy ALL bitmaps, uncomment the line below:
# cp -R ./../bitmaps $APPName.app/Contents/Resources/

# Fallback/Legacy: If you want to copy ALL bitmaps, uncomment the line below:
# cp -R ./../bitmaps $APPName.app/Contents/Resources/

if [ ! -d $APPName.app/Contents/frameworks ]; then
   mkdir $APPName.app/Contents/frameworks
   cp -r ./../../Resources/frameworks/* $APPName.app/Contents/frameworks/
fi 

# If Scintilla not in frameworks but detected, copy it specifically if needed
# (Currently we copy ALL frameworks from ../../Resources/frameworks above, so it should be fine)

echo linking...
CRTLIB=$SDKPATH/usr/lib
HRBLIBS="-lhbdebug -lhbvm -lhbrtl -lhblang -lhbrdd -lgttrm -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbcpage -lhbhsx -lrddnsx $MYSQL_LIBS"
FRAMEWORKS='-framework Cocoa -framework WebKit -framework QuickLookUI -framework QuartzCore -framework CoreImage -framework PDFKit -framework UserNotifications -framework ScreenCaptureKit -framework ScriptingBridge -framework AVKit -framework AVFoundation -framework CoreMedia -framework iokit -framework UniformTypeIdentifiers'

SWIFTPATH=$(xcrun --show-sdk-path)/usr/lib/swift
if [ ! -d "$SWIFTPATH" ]; then
    # Fallback for Command Line Tools
    SWIFTPATH=/usr/lib/swift
fi

WINNH3DLIB="-L$SWIFTPATH -rpath $SWIFTPATH -rpath @executable_path/../Frameworks"

# Link ALL OBJS
# Add target and min-version to link step too
clang $OBJS -o ./$APPName.app/Contents/MacOS/$APPName -target arm64-apple-macosx26.0 -L$CRTLIB -L./../lib -lfive -lfivec $SCINTILLA_LIB -L$HB_DIR/lib $HRBLIBS $FRAMEWORKS  -F./../../Resources/frameworks $SCINTILLA_FRAMEWORK -lsqlite3 $WINNH3DLIB $CRTLIB/libz.tbd $CRTLIB/libpcre.tbd


#rm $1.c
#rm $1.o
# Clean up all Objects and C files
# rm $OBJS
# for file in "$@"; do rm "$file.c"; done


echo done!
#./$APPName.app/Contents/MacOS/$APPName
/usr/bin/open -W ./$APPName.app

