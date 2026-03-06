# SwiftUI Library Makefile
# (c) FiveTech Software 2026

# General paths
SDKPATH=$(shell xcrun --show-sdk-path)
HARBOUR_PATH=../../harbour
FIVEMAC_PATH=..

# Tools
CC=clang
HB_BIN=$(HARBOUR_PATH)/bin/harbour

# Architecture detection
ARCH=$(shell uname -m)
ifeq ($(ARCH),arm64)
    TARGET_FLAG=-target arm64-apple-macosx26.0
else
    TARGET_FLAG=-target x86_64-apple-macosx10.15
endif

# Macro paths
MACRO_BIN=source/HarbourMacro/bin/HarbourMacroPlugin
MACRO_INC=source/HarbourMacro/bin

# Flags
CFLAGS=$(TARGET_FLAG) -c -Iinclude -I$(FIVEMAC_PATH)/nativo/include -I$(HARBOUR_PATH)/include -fmodules
HBFLAGS=-n -w -Iinclude -I$(FIVEMAC_PATH)/nativo/include -I$(HARBOUR_PATH)/include
SWIFTFLAGS=-emit-object -whole-module-optimization -parse-as-library -module-name SwiftFive $(TARGET_FLAG) -emit-objc-header-path include/SwiftFive-Swift.h -I $(MACRO_INC) -load-plugin-executable $(MACRO_BIN)\#HarbourMacroImpl

# Files
SWIFT_SOURCES=$(wildcard source/swift/*.swift)
OBJC_SOURCES=$(wildcard source/winapi/*.m)
PRG_SOURCES=$(wildcard source/classes/*.prg)

SWIFT_OBJ=obj/SwiftFive.o
OBJC_OBJS=$(patsubst source/winapi/%.m,obj/ObjC_%.o,$(OBJC_SOURCES))
PRG_OBJS=$(patsubst source/classes/%.prg,obj/Hrb_%.o,$(PRG_SOURCES))

LIB_NAME=lib/libSwiftFive.a

# Rules
all: $(LIB_NAME)

$(LIB_NAME): $(SWIFT_OBJ) $(OBJC_OBJS) $(PRG_OBJS)
	@mkdir -p lib
	@echo "Archiving $@..."
	ar rc $@ obj/*.o
	ranlib $@

# Compile Swift
$(SWIFT_OBJ): $(SWIFT_SOURCES)
	@mkdir -p obj
	@mkdir -p include
	@echo "Compiling Swift..."
	swiftc $(SWIFT_SOURCES) $(SWIFTFLAGS) -o $@

# Compile ObjC
obj/ObjC_%.o: source/winapi/%.m
	@mkdir -p obj
	@echo "Compiling ObjC: $<..."
	$(CC) $(CFLAGS) $< -o $@

# Compile Harbour to C then to O
obj/Hrb_%.o: source/classes/%.prg
	@mkdir -p obj
	@echo "Compiling Harbour: $<..."
	$(HB_BIN) $< $(HBFLAGS) -oobj/$*.c
	$(CC) $(CFLAGS) obj/$*.c -o $@
	@rm obj/$*.c

clean:
	rm -rf obj lib/$(notdir $(LIB_NAME))
