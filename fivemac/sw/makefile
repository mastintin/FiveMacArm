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


# Flags
CFLAGS=$(TARGET_FLAG) -c -Iinclude -I$(FIVEMAC_PATH)/nativo/include -I$(FIVEMAC_PATH)/nativo/source/winapi -I$(HARBOUR_PATH)/include -fmodules
HBFLAGS=-n -w -Iinclude -I$(FIVEMAC_PATH)/nativo/include -I$(HARBOUR_PATH)/include
#SWIFT_SOURCES = source/swift/SwAIChat.swift source/swift/SwActionRunner.swift source/swift/SwCommon.swift \
#                source/swift/SwComponentFactory.swift source/swift/SwDispatcher.swift source/swift/SwHarbourApi.swift \
#                source/swift/SwNotificationCenter.swift source/swift/SwProtocols.swift source/swift/SwRecursiveItemView.swift \
#                source/swift/SwRegistry.swift source/swift/SwWindow.swift source/swift/SwWorkflowContext.swift \
#                source/swift/SwApp.swift source/swift/SwBridge.swift source/swift/SwUniversalCommands.swift \
#                source/swift/SwiftButton.swift source/swift/SwiftFiles.swift source/swift/SwiftGet.swift \
#                source/swift/SwiftImage.swift source/swift/SwiftLabel.swift source/swift/SwiftList.swift \
#                source/swift/SwiftNetworks.swift source/swift/SwiftProgress.swift source/swift/SwiftSlider.swift \
#                source/swift/SwSystem.swift source/swift/SwTabView.swift source/swift/SwTimer.swift \
#                source/swift/SwiftToggle.swift \
#                source/swift/SwiftViews.swift source/swift/SwiftWebView.swift
SWIFTFLAGS=-emit-object -whole-module-optimization -parse-as-library -module-name SwiftFive $(TARGET_FLAG) -emit-objc-header-path include/SwiftFive-Swift.h

# Files
SWIFT_SOURCES=$(wildcard source/swift/*.swift)
PRG_SOURCES=$(wildcard source/classes/*.prg)
C_SOURCES=$(wildcard source/sqlite/*.c)
OBJC_SOURCES=$(wildcard source/objc/*.m)

SWIFT_OBJ=obj/SwiftFive.o
PRG_OBJS=$(patsubst source/classes/%.prg,obj/Hrb_%.o,$(PRG_SOURCES))
C_OBJS=$(addprefix obj/,$(notdir $(C_SOURCES:.c=.o)))
OBJC_OBJS=$(addprefix obj/,$(notdir $(OBJC_SOURCES:.m=.o)))

LIB_NAME=lib/libSwiftFive.a

# Rules
all: $(LIB_NAME)

$(LIB_NAME): $(SWIFT_OBJ) $(PRG_OBJS) $(C_OBJS) $(OBJC_OBJS)
	@mkdir -p lib
	@echo "Archiving $@..."
	ar rc $@ $(SWIFT_OBJ) obj/Hrb_*.o $(C_OBJS) $(OBJC_OBJS)
	ranlib $@

# Compile Swift
$(SWIFT_OBJ): $(SWIFT_SOURCES)
	@mkdir -p obj
	@mkdir -p include
	@echo "Compiling Swift..."
	swiftc $(SWIFT_SOURCES) $(SWIFTFLAGS) -o $@

# Compile Native C modules
obj/%.o: source/sqlite/%.c
	@mkdir -p obj
	@echo "Compiling Native C: $<..."
	$(CC) $(CFLAGS) $< -o $@

# Compile Objective-C modules
obj/%.o: source/objc/%.m
	@mkdir -p obj
	@echo "Compiling Objective-C: $<..."
	$(CC) $(CFLAGS) $< -o $@

obj/formatters.o: ../nativo/source/winapi/formatters.m
	@mkdir -p obj
	@echo "Compiling Native Formatter: $<..."
	$(CC) $(CFLAGS) $< -o $@

# Compile Harbour to C then to O
obj/Hrb_%.o: source/classes/%.prg
	@mkdir -p obj
	@echo "Compiling Harbour: $<..."
	$(HB_BIN) $< $(HBFLAGS) -o$*.c
	@mv $*.c obj/
	$(CC) $(CFLAGS) obj/$*.c -o $@
	@rm obj/$*.c

clean:
	rm -rf obj lib/$(notdir $(LIB_NAME))
