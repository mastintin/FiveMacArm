# NiceGUI Library Makefile
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
    TARGET_FLAG=-target arm64-apple-macosx11.0
else
    TARGET_FLAG=-target x86_64-apple-macosx10.15
endif

# Flags
CFLAGS=-c -Iinclude -I$(FIVEMAC_PATH)/nativo/include -I$(HARBOUR_PATH)/include -fmodules $(TARGET_FLAG)
HBFLAGS=-n -w -Iinclude -I$(FIVEMAC_PATH)/nativo/include -I$(HARBOUR_PATH)/include

# Files
# We compile all PRGs except the "enlace" Nice.prg
PRG_SOURCES=$(filter-out source/Nice.prg, $(wildcard source/*.prg))
PRG_OBJS=$(patsubst source/%.prg,obj/%.o,$(PRG_SOURCES))

LIB_NAME=lib/libnice.a

# Rules
all: $(LIB_NAME)

$(LIB_NAME): $(PRG_OBJS)
	@mkdir -p lib
	@echo "Archiving $@..."
	ar rc $@ obj/*.o
	ranlib $@

# Compile Harbour to C then to O
obj/%.o: source/%.prg
	@mkdir -p obj
	@echo "Compiling Harbour: $<..."
	$(HB_BIN) $< $(HBFLAGS) -oobj/$*.c
	$(CC) $(CFLAGS) obj/$*.c -o $@
	@rm obj/$*.c

clean:
	rm -rf obj lib/$(notdir $(LIB_NAME))
