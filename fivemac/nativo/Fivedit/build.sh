# ./build.sh - (c) FiveTech Software 2007-2018
# Modified to handle Scintilla 5.x Framework and Resources

clear

if [ $# = 0 ]; then
   echo syntax: ./build.sh file [options...]
   exit
fi

echo compiling...

APPName=$1

# Fivedit requires multiple modules
if [ "$APPName" == "fivedit" ] && [ $# -eq 1 ]; then
   set -- "fivedit" "CreaForm" "CreaBuilder"
fi

OBJS=""
PRG_FILES=""
PATHCONF="./.."
RESOURCES="./../../Resources"
HARBPATH="./../../../harbour"

# Loop through all arguments (files)
for FILE_PATH in "$@"; do
    FILE_NAME=$(basename "$FILE_PATH")
    FILE_DIR=$(dirname "$FILE_PATH")
    
    echo "Compiling $FILE_PATH.prg..."
    $HARBPATH/bin/harbour "$FILE_PATH" -n -w -I$PATHCONF/include -I$HARBPATH/include
    if [ $? -ne 0 ]; then
       echo "Error compiling $FILE_PATH.prg"
       exit 1
    fi   

    C_FILE="./$FILE_NAME.c"
    O_FILE="./$FILE_NAME.o"

    echo "Compiling C module $C_FILE..."
    clang -ObjC "$C_FILE" -c -I./../include -I$HARBPATH/include   
    if [ $? -ne 0 ]; then
       echo "Error compiling $C_FILE"
       exit 1
    fi
    
    OBJS="$OBJS $O_FILE"
    PRG_FILES="$PRG_FILES $FILE_PATH.prg"
done

if [ ! -d $APPName.app ]; then
   mkdir -p $APPName.app/Contents/MacOS
   mkdir -p $APPName.app/Contents/Resources
   mkdir -p $APPName.app/Contents/Frameworks
fi   

# Ensure Scintilla.framework is always present for Scintilla 5.x
SCINTILLA_SRC_FRAMEWORK="../../fivemac/frameworks/Scintilla.framework"
TARGET_FRAMEWORKS_DIR="./$APPName.app/Contents/Frameworks"

if [ -d "$SCINTILLA_SRC_FRAMEWORK" ]; then
    echo "Updating Scintilla.framework in $APPName.app..."
    mkdir -p "$TARGET_FRAMEWORKS_DIR"
    cp -Rf "$SCINTILLA_SRC_FRAMEWORK" "$TARGET_FRAMEWORKS_DIR/"
else
    # Try alternate location in nativo folder structure
    SCINTILLA_SRC_FRAMEWORK="./Resources/frameworks/Scintilla.framework"
    if [ -d "$SCINTILLA_SRC_FRAMEWORK" ]; then
        echo "Updating Scintilla.framework from Resources..."
        mkdir -p "$TARGET_FRAMEWORKS_DIR"
        cp -Rf "$SCINTILLA_SRC_FRAMEWORK" "$TARGET_FRAMEWORKS_DIR/"
    else
        echo "Warning: Scintilla.framework NOT FOUND"
    fi
fi

# Ensure Resources (hbdocs.json, etc.) are always present
echo "Copying resources to $APPName.app/Contents/Resources..."
if [ -d "./Resources" ]; then
   cp -Rf ./Resources/* $APPName.app/Contents/Resources/
fi

# Specfic copy for JSON configurations (Snippets, docs, themes)
[ -f "./hbdocs.json" ] && cp "./hbdocs.json" $APPName.app/Contents/Resources/
[ -f "./snippets.json" ] && cp "./snippets.json" $APPName.app/Contents/Resources/
[ -f "./solarized.json" ] && cp "./solarized.json" $APPName.app/Contents/Resources/

# Link ALL OBJS
echo linking...
SDKPATH=$(xcrun --show-sdk-path)
CRTLIB=$SDKPATH/usr/lib
HRBLIBS='-lhbdebug -lhbvm -lhbrtl -lhblang -lhbrdd -lgttrm -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbcpage -lhbhsx -lrddnsx -lhbmysql -lhbmisc'
MYSQL_LIBS='-lmariadb -lssl -lcrypto'
FRAMEWORKS='-framework Cocoa -framework WebKit -framework Quartz -framework UserNotifications -framework ScreenCaptureKit -framework ScriptingBridge -framework AVKit -framework AVFoundation -framework CoreMedia -framework iokit -framework UniformTypeIdentifiers -framework Network'
SWIFTPATH=$SDKPATH/usr/lib/swift
WINNH3DLIB="-L$SWIFTPATH -rpath $SWIFTPATH -rpath @executable_path/../Frameworks"

clang $OBJS -o ./$APPName.app/Contents/MacOS/$APPName -L$CRTLIB -L$PATHCONF/lib -lfive -lfivec -lscintilla -L$HARBPATH/lib $HRBLIBS $MYSQL_LIBS $FRAMEWORKS  -F$TARGET_FRAMEWORKS_DIR -framework Scintilla -lsqlite3 $WINNH3DLIB $CRTLIB/libz.tbd $CRTLIB/libpcre.tbd

echo done!
/usr/bin/open -W ./$APPName.app
