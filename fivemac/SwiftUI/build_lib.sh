#!/bin/bash

# Configuration
LIB_NAME="libSwiftFive.a"
HARBOUR_PATH="../../harbour"
FIVEMAC_PATH=".."
SWIFT_MODULE_NAME="SwiftFive"

# Clean
rm -rf obj
mkdir -p obj
mkdir -p include
mkdir -p lib

echo "Building Library $LIB_NAME..."

# Detect Architecture
ARCH=$(uname -m)
if [ "$ARCH" == "arm64" ]; then
    TARGET_FLAG="-target arm64-apple-macosx11.0"
else
    TARGET_FLAG="-target x86_64-apple-macosx10.15"
fi

# 1. Compile Swift (All files in source/swift)
echo "Compiling Swift..."
swiftc source/swift/*.swift \
    -emit-objc-header-path "include/$SWIFT_MODULE_NAME-Swift.h" \
    -emit-object \
    -whole-module-optimization \
    -parse-as-library \
    -module-name "$SWIFT_MODULE_NAME" \
    $TARGET_FLAG \
    -o obj/SwiftFive.o

if [ $? -ne 0 ]; then echo "Error compiling Swift"; exit 1; fi

# 2. Compile ObjC Glue (All files in source/winapi)
for f in source/winapi/*.m; do
    filename=$(basename -- "$f")
    name="${filename%.*}"
    
    echo "  $f..."
    clang -c "$f" \
        -Iinclude \
        -Isource/winapi \
        -I"$FIVEMAC_PATH/nativo/include" \
        -I"$HARBOUR_PATH/include" \
        -fmodules \
        -o "obj/ObjC_${name}.o"
        
    if [ $? -ne 0 ]; then echo "Error compiling ObjC: $f"; exit 1; fi
done

# 3. Compile Harbour Classes
echo "Compiling Harbour Classes..."
for f in source/classes/*.prg; do
    filename=$(basename -- "$f")
    name="${filename%.*}"
    
    echo "  $f..."
    "$HARBOUR_PATH/bin/harbour" "$f" -n -w -Iinclude -I"$FIVEMAC_PATH/nativo/include" -I"$HARBOUR_PATH/include" -o"obj/${name}.c"
    
    clang -c "obj/${name}.c" \
        -I"$FIVEMAC_PATH/nativo/include" \
        -I"$HARBOUR_PATH/include" \
        -o "obj/Hrb_${name}.o"
done

# 4. Create Static Library
echo "Archiving to lib/$LIB_NAME..."
# Archive Swift object, ObjC objects, and Harbour objects
ar rc lib/$LIB_NAME obj/*.o
ranlib lib/$LIB_NAME

echo "Library built: lib/$LIB_NAME"
