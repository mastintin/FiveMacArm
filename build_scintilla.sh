#!/bin/bash
set -e

# Scintilla 4.1.2 compilation script for macOS (arm64 + x86_64)
# Adapting for missing Xcode, using command line tools/clang directly.

SRC_DIR="scintilla_build/scintilla/src"
COCOA_DIR="scintilla_build/scintilla/cocoa"
INCLUDE_DIR="scintilla_build/scintilla/include"
LEXLIB_DIR="scintilla_build/scintilla/lexlib"
LEXERS_DIR="scintilla_build/scintilla/lexers"
BUILD_DIR="scintilla_build/build"
FRAMEWORK_DIR="scintilla_build/Scintilla.framework"
FRAMEWORK_NAME="Scintilla"

mkdir -p "$BUILD_DIR"
mkdir -p "$FRAMEWORK_DIR/Versions/A/Headers"
mkdir -p "$FRAMEWORK_DIR/Versions/A/Resources"

# Compiler flags
CFLAGS="-x c++ -arch arm64 -arch x86_64 -std=c++17 -stdlib=libc++ -fPIC -D_MACOSX -DSCI_NAMESPACE -DSCI_LEXER -I$INCLUDE_DIR -I$SRC_DIR -I$COCOA_DIR -I$LEXLIB_DIR"
OBJCFLAGS="-x objective-c++ -arch arm64 -arch x86_64 -std=c++17 -stdlib=libc++ -fPIC -D_MACOSX -DSCI_NAMESPACE -DSCI_LEXER -I$INCLUDE_DIR -I$SRC_DIR -I$COCOA_DIR -I$LEXLIB_DIR -fobjc-arc"

echo "Compiling C++ sources (Base)..."
for file in "$SRC_DIR"/*.cxx; do
    filename=$(basename -- "$file")
    name="${filename%.*}"
    # echo "$filename"
    clang++ $CFLAGS -c "$file" -o "$BUILD_DIR/$name.o"
done

echo "Compiling C++ sources (LexLib)..."
for file in "$LEXLIB_DIR"/*.cxx; do
    filename=$(basename -- "$file")
    name="${filename%.*}"
    # echo "$filename"
    clang++ $CFLAGS -c "$file" -o "$BUILD_DIR/$name.o"
done

echo "Compiling C++ sources (Lexers)..."
# Only compile .cxx files
for file in "$LEXERS_DIR"/*.cxx; do
    filename=$(basename -- "$file")
    name="${filename%.*}"
    # echo "$filename"
    clang++ $CFLAGS -c "$file" -o "$BUILD_DIR/$name.o"
done

echo "Compiling Cocoa sources..."
# We only need the implementation files. ScintillaTest should be excluded if present in root.
# Listing showed ScintillaTest is a subdir, so *.mm in cocoa/ is safe?
# Let's double check listing.
for file in "$COCOA_DIR"/*.mm; do
    filename=$(basename -- "$file")
    name="${filename%.*}"
    echo "$filename"
    clang++ $OBJCFLAGS -framework Cocoa -framework QuartzCore -c "$file" -o "$BUILD_DIR/$name.o"
done

echo "Linking framework..."
clang++ -dynamiclib -arch arm64 -arch x86_64 \
    -install_name "@rpath/$FRAMEWORK_NAME.framework/Versions/A/$FRAMEWORK_NAME" \
    -compatibility_version 1.0.0 -current_version 1.0.0 \
    -framework Cocoa -framework QuartzCore \
    -o "$FRAMEWORK_DIR/Versions/A/$FRAMEWORK_NAME" \
    "$BUILD_DIR"/*.o

echo "Copying Headers..."
cp "$INCLUDE_DIR"/*.h "$FRAMEWORK_DIR/Versions/A/Headers/"
cp "$COCOA_DIR/ScintillaView.h" "$FRAMEWORK_DIR/Versions/A/Headers/"
# ScintillaCocoa.h? Maybe.
if [ -f "$COCOA_DIR/ScintillaCocoa.h" ]; then
    cp "$COCOA_DIR/ScintillaCocoa.h" "$FRAMEWORK_DIR/Versions/A/Headers/"
fi

echo "Creating Info.plist..."
# Minimal Info.plist
cat > "$FRAMEWORK_DIR/Versions/A/Resources/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Scintilla</string>
    <key>CFBundleIdentifier</key>
    <string>org.scintilla.Scintilla</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Scintilla</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>4.1.2</string>
    <key>CFBundleVersion</key>
    <string>4.1.2</string>
</dict>
</plist>
EOF

echo "Creating Symlinks..."
cd "$FRAMEWORK_DIR/Versions"
ln -sf A Current
cd ..
ln -sf Versions/Current/Scintilla Scintilla
ln -sf Versions/Current/Headers Headers
ln -sf Versions/Current/Resources Resources

echo "Build Complete!"
