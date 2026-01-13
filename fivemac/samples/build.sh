# ./build.sh - (c) FiveTech Software 2007-2018

clear

if [ $# = 0 ]; then
   echo syntax: ./build.sh file [options...]
   exit
fi

echo compiling...

APPName=$1
OBJS=""
PRG_FILES=""

# Loop through all arguments (files)
for FILE in "$@"; do
    echo "Compiling $FILE.prg..."
    ./../../harbour/bin/harbour "$FILE" -n -w -I./../include:./../../harbour/include
    if [ $? -ne 0 ]; then
       echo "Error compiling $FILE.prg"
       exit 1
    fi   

    echo "Compiling C module $FILE.c..."
    #  add -arch ppc -arch i386 for universal binaries
    SDKPATH=$(xcrun --show-sdk-path)
    clang -ObjC "$FILE.c" -c -I./../include -I./../../harbour/include   
    if [ $? -ne 0 ]; then
       echo "Error compiling $FILE.c"
       exit 1
    fi
    
    OBJS="$OBJS $FILE.o"
    PRG_FILES="$PRG_FILES $FILE.prg"
done

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
   echo '	<key>NSPrincipalClass</key>' >> $APPName.app/Contents/Info.plist
   echo '	<string>NSApplication</string>' >> $APPName.app/Contents/Info.plist
   echo '	<key>NSAppTransportSecurity</key>' >> $APPName.app/Contents/Info.plist
   echo '	<dict>' >> $APPName.app/Contents/Info.plist
   echo '		<key>NSAllowsArbitraryLoads</key>' >> $APPName.app/Contents/Info.plist
   echo '		<true/>' >> $APPName.app/Contents/Info.plist
   echo '	</dict>' >> $APPName.app/Contents/Info.plist
   # para poder enviar mail
   # echo '   <key>NSAppleEventsUsageDescription</key>' >> $APPName.app/Contents/Info.plist
   # echo '   <string>FiveMac needs to control Mail to send emails.</string>' >> $APPName.app/Contents/Info.plist
   echo '</dict>' >> $APPName.app/Contents/Info.plist
   echo '</plist>' >> $APPName.app/Contents/Info.plist

   echo 'APPL????' > $APPName.app/Contents/PkgInfo
fi
if [ ! -d $APPName.app/Contents/MacOS ]; then
   mkdir $APPName.app/Contents/MacOS
fi  
if [ ! -d $APPName.app/Contents/Resources ]; then
   mkdir $APPName.app/Contents/Resources
   cp ./../icons/fivetech.icns $APPName.app/Contents/Resources/
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
   cp -r ./../frameworks/* $APPName.app/Contents/frameworks/
fi 

echo linking...
CRTLIB=$SDKPATH/usr/lib
HRBLIBS='-lhbdebug -lhbvm -lhbrtl -lhblang -lhbrdd -lgttrm -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbcpage -lhbhsx -lrddnsx'
FRAMEWORKS='-framework Cocoa -framework WebKit -framework Quartz -framework UserNotifications -framework ScreenCaptureKit -framework ScriptingBridge -framework AVKit -framework AVFoundation -framework CoreMedia -framework iokit -framework UniformTypeIdentifiers'

SWIFTPATH=$(xcrun --show-sdk-path)/usr/lib/swift
if [ ! -d "$SWIFTPATH" ]; then
    # Fallback for Command Line Tools
    SWIFTPATH=/usr/lib/swift
fi

WINNH3DLIB="-L$SWIFTPATH -rpath $SWIFTPATH -rpath @executable_path/../Frameworks"

#  add -arch ppc -arch i386 for universal binaries
#  add -arch ppc -arch i386 for universal binaries
# Link ALL OBJS
clang $OBJS -o ./$APPName.app/Contents/MacOS/$APPName -L$CRTLIB -L./../lib -lfive -lfivec -L./../../harbour/lib $HRBLIBS $FRAMEWORKS  -F./../frameworks -framework Scintilla -lsqlite3 $WINNH3DLIB $CRTLIB/libz.tbd $CRTLIB/libpcre.tbd


#rm $1.c
#rm $1.o
# Clean up all Objects and C files
# rm $OBJS
# for file in "$@"; do rm "$file.c"; done


echo done!
#./$APPName.app/Contents/MacOS/$APPName
/usr/bin/open -W ./$APPName.app

