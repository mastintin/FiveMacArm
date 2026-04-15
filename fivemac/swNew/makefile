# SwiftUI Library Makefile (sw branch - TOTAL INDEPENDENCE)
# (c) FiveTech Software 2026

# General paths
SDKPATH=$(shell xcrun --show-sdk-path)
HARBOUR_PATH=../../harbour
FIVEMAC_PATH=..
CORE_SWIFTUI_PATH=../SwiftUI

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

# Macro paths (Local to Isla SW)
MACRO_BIN=source/HarbourMacro/bin/HarbourMacroPlugin
MACRO_INC=source/HarbourMacro/bin

# Flags
CFLAGS=$(TARGET_FLAG) -c -Iinclude -Isource/swift -I$(FIVEMAC_PATH)/nativo/include -I$(HARBOUR_PATH)/include -fmodules
HBFLAGS=-n -w -Iinclude -I$(FIVEMAC_PATH)/nativo/include -I$(HARBOUR_PATH)/include
SWIFTFLAGS=-emit-object -whole-module-optimization -parse-as-library -module-name SwiftFive $(TARGET_FLAG) -emit-objc-header-path include/SwiftFive-Swift.h -I $(MACRO_INC) -load-plugin-executable $(MACRO_BIN)\#HarbourMacroImpl

# Sources (LOCAL ONLY for TOTAL INDEPENDENCE)
SWIFT_SOURCES=$(wildcard source/swift/*.swift)
PRG_SOURCES=$(wildcard source/classes/*.prg)

SWIFT_OBJ=obj/SwiftFive.o
PRG_OBJS=$(patsubst source/classes/%.prg,obj/Hrb_%.o,$(PRG_SOURCES))

LIB_NAME=lib/libSwiftFive.a

# Rules
all: $(LIB_NAME)

$(LIB_NAME): $(SWIFT_OBJ) $(PRG_OBJS)
	@mkdir -p lib
	@echo "Archiving $@..."
	ar rc $@ $(SWIFT_OBJ) obj/Hrb_*.o
	ranlib $@

$(SWIFT_OBJ): $(SWIFT_SOURCES)
	@mkdir -p obj
	@mkdir -p include
	@echo "Compiling Swift (Isolated)..."
	swiftc $(SWIFT_SOURCES) $(SWIFTFLAGS) -o $@

# Local PRG rule
obj/Hrb_%.o: source/classes/%.prg
	@mkdir -p obj
	@echo "Compiling Harbour: $<..."
	$(HB_BIN) $< $(HBFLAGS) -o$*.c
	$(CC) $(CFLAGS) $*.c -o $@
	@rm $*.c

clean:
	rm -rf obj lib/$(notdir $(LIB_NAME))
