# ./build.sh - (c) FiveTech Software 2007-2018

clear

if [ $# = 0 ]; then
   echo syntax: ./build.sh file [options...]
   exit
fi

echo compiling...
./../../harbour/bin/harbour $1 -n -w -I./../include:./../../harbour/include $2
if [ $? = 1 ]; then
   exit
fi   

echo compiling C module...
#  add -arch ppc -arch i386 for universal binaries
SDKPATH=$(xcrun --show-sdk-path)
   clang -ObjC $1.c -c -I./../include -I./../../harbour/include   

if [ ! -d $1.app ]; then
   mkdir $1.app
fi   
if [ ! -d $1.app/Contents ]; then
   mkdir $1.app/Contents
   echo '<?xml version="1.0" encoding="UTF-8"?>' > $1.app/Contents/Info.plist
   echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> $1.app/Contents/Info.plist
   echo '<plist version="1.0">' >> $1.app/Contents/Info.plist
   echo '<dict>' >> $1.app/Contents/Info.plist
   echo '   <key>CFBundleExecutable</key>' >> $1.app/Contents/Info.plist
   echo '   <string>'$1'</string>' >> $1.app/Contents/Info.plist
   echo '   <key>CFBundleName</key>' >> $1.app/Contents/Info.plist
   echo '   <string>'$1'</string>' >> $1.app/Contents/Info.plist
   echo '   <key>CFBundleIdentifier</key>' >> $1.app/Contents/Info.plist
   echo '   <string>com.fivetech.'$1'</string>' >> $1.app/Contents/Info.plist
   echo '   <key>CFBundlePackageType</key>' >> $1.app/Contents/Info.plist
   echo '   <string>APPL</string>' >> $1.app/Contents/Info.plist
   echo '   <key>CFBundleInfoDictionaryVersion</key>' >> $1.app/Contents/Info.plist
   echo '   <string>6.0</string>' >> $1.app/Contents/Info.plist
   echo '   <key>CFBundleIconFile</key>' >> $1.app/Contents/Info.plist
   echo '   <string>fivetech.icns</string>' >> $1.app/Contents/Info.plist
   echo '   <key>NSHighResolutionCapable</key>' >> $1.app/Contents/Info.plist
   echo '<true/>' >> $1.app/Contents/Info.plist
   echo '	<key>NSPrincipalClass</key>' >> $1.app/Contents/Info.plist
   echo '	<string>NSApplication</string>' >> $1.app/Contents/Info.plist
   echo '	<key>NSAppTransportSecurity</key>' >> $1.app/Contents/Info.plist
   echo '	<dict>' >> $1.app/Contents/Info.plist
   echo '		<key>NSAllowsArbitraryLoads</key>' >> $1.app/Contents/Info.plist
   echo '		<true/>' >> $1.app/Contents/Info.plist
   echo '	</dict>' >> $1.app/Contents/Info.plist
   echo '</dict>' >> $1.app/Contents/Info.plist
   echo '</plist>' >> $1.app/Contents/Info.plist
fi   
if [ ! -d $1.app/Contents/MacOS ]; then
   mkdir $1.app/Contents/MacOS
fi  
if [ ! -d $1.app/Contents/Resources ]; then
   mkdir $1.app/Contents/Resources
   cp ./../icons/fivetech.icns $1.app/Contents/Resources/
fi 

# Always copy bitmaps to ensure they are up to date
if [ -d "$1.app/Contents/Resources/bitmaps" ]; then
   rm -rf "$1.app/Contents/Resources/bitmaps"
fi
cp -R ./../bitmaps $1.app/Contents/Resources/

if [ ! -d $1.app/Contents/frameworks ]; then
   mkdir $1.app/Contents/frameworks
   cp -r ./../frameworks/* $1.app/Contents/frameworks/
fi 

echo linking...
CRTLIB=$SDKPATH/usr/lib
HRBLIBS='-lhbdebug -lhbvm -lhbrtl -lhblang -lhbrdd -lhbrtl -lgttrm -lhbvm -lhbmacro -lhbpp -lrddntx -lrddcdx -lrddfpt -lhbsix -lhbcommon -lhbcplr -lhbcpage -lhbhsx -lhbsix  -lrddnsx'
FRAMEWORKS='-framework Cocoa -framework WebKit -framework Quartz -framework ScreenCaptureKit -framework ScriptingBridge -framework AVKit -framework AVFoundation -framework CoreMedia -framework iokit'

SWIFTPATH=$(xcrun --show-sdk-path)/usr/lib/swift
if [ ! -d "$SWIFTPATH" ]; then
    # Fallback for Command Line Tools
    SWIFTPATH=/usr/lib/swift
fi

WINNH3DLIB="-L$SWIFTPATH -rpath $SWIFTPATH -rpath @executable_path/../Frameworks"

#  add -arch ppc -arch i386 for universal binaries
#  add -arch ppc -arch i386 for universal binaries
clang $1.o -o ./$1.app/Contents/MacOS/$1 -L$CRTLIB -L./../lib -lfive -lfivec -L./../../harbour/lib $HRBLIBS $FRAMEWORKS  -F./../frameworks -framework Scintilla $WINNH3DLIB $CRTLIB/libz.tbd $CRTLIB/libpcre.tbd


#rm $1.c
rm $1.o

echo done!
#./$1.app/Contents/MacOS/$1
/usr/bin/open -W ./$1.app
