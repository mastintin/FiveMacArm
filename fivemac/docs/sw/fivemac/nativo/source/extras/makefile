# Makefile for FiveMac Extras (Expat, XlsxIO, XlsxWriter)
# (c) FiveTech Software 2025

SDKPATH=$(shell xcrun --show-sdk-path)
HEADERS=$(SDKPATH)/usr/include
FRAMEPATH=$(SDKPATH)/System/Library/Frameworks

# Flags
MIN_VER=-mmacosx-version-min=26.0
CFLAGS=$(MIN_VER)
CC=clang

# Harbour paths
HB_DIR=../../../../harbour
HB_BIN=$(HB_DIR)/bin/harbour
HB_INC=$(HB_DIR)/include

# Output paths (relative to nativo directory)
LIB_DIR=../../lib
OBJ_DIR=../../obj
OBJC_DIR=../../objc

EXTRAS_PRG_OBJS = $(OBJ_DIR)/xlsxreader.o \
	$(OBJ_DIR)/hb_others.o \
	$(OBJ_DIR)/expat.o

EXTRAS_C_OBJS = \
	$(OBJC_DIR)/Expat.o $(OBJC_DIR)/ExpatWrappers.o \
	$(OBJC_DIR)/XlsxioRead.o $(OBJC_DIR)/XlsxioWrappers.o \
	$(OBJC_DIR)/app.o $(OBJC_DIR)/chart.o $(OBJC_DIR)/chartsheet.o $(OBJC_DIR)/comment.o $(OBJC_DIR)/content_types.o \
	$(OBJC_DIR)/core.o $(OBJC_DIR)/custom.o $(OBJC_DIR)/drawing.o $(OBJC_DIR)/format.o $(OBJC_DIR)/hash_table.o \
	$(OBJC_DIR)/hb_app.o $(OBJC_DIR)/hb_chart.o $(OBJC_DIR)/hb_chartsheet.o $(OBJC_DIR)/hb_content_types.o \
	$(OBJC_DIR)/hb_core.o $(OBJC_DIR)/hb_custom.o $(OBJC_DIR)/hb_drawing.o $(OBJC_DIR)/hb_format.o \
	$(OBJC_DIR)/hb_misc.o $(OBJC_DIR)/hb_relationships.o $(OBJC_DIR)/hb_shared_strings.o \
	$(OBJC_DIR)/hb_styles.o $(OBJC_DIR)/hb_theme.o $(OBJC_DIR)/hb_utility.o $(OBJC_DIR)/hb_workbook.o \
	$(OBJC_DIR)/hb_worksheet.o $(OBJC_DIR)/metadata.o $(OBJC_DIR)/packager.o $(OBJC_DIR)/relationships.o \
	$(OBJC_DIR)/rich_value.o $(OBJC_DIR)/rich_value_rel.o $(OBJC_DIR)/rich_value_structure.o \
	$(OBJC_DIR)/rich_value_types.o $(OBJC_DIR)/shared_strings.o $(OBJC_DIR)/styles.o $(OBJC_DIR)/table.o \
	$(OBJC_DIR)/theme.o $(OBJC_DIR)/utility.o $(OBJC_DIR)/vml.o $(OBJC_DIR)/workbook.o $(OBJC_DIR)/worksheet.o \
	$(OBJC_DIR)/xmlwriter.o $(OBJC_DIR)/tmpfileplus.o $(OBJC_DIR)/emyg_dtoa.o

all: $(LIB_DIR)/libfiveextras.a

$(LIB_DIR)/libfiveextras.a : $(EXTRAS_PRG_OBJS) $(EXTRAS_C_OBJS)
	if [ ! -d "$(LIB_DIR)" ]; then mkdir -p $(LIB_DIR); fi
	ar rc $(LIB_DIR)/libfiveextras.a $(EXTRAS_PRG_OBJS) $(EXTRAS_C_OBJS)
	ranlib $(LIB_DIR)/libfiveextras.a

# Rules for building from extras/prg
$(OBJ_DIR)/%.o : ./prg/%.prg
	if [ ! -d "$(OBJ_DIR)" ]; then mkdir -p $(OBJ_DIR); fi
	$(HB_BIN) $< -o$(OBJ_DIR)/$*.c -n -I$(HB_INC) -I../../include
	$(CC) -ObjC -c -o $@ -I$(HB_INC) -I$(HEADERS) -I../../include -F$(FRAMEPATH) $(CFLAGS) $(OBJ_DIR)/$*.c

# Rules for building from extras/expat
$(OBJC_DIR)/%.o : ./expat/%.m
	if [ ! -d "$(OBJC_DIR)" ]; then mkdir -p $(OBJC_DIR); fi
	$(CC) -ObjC -I$(HB_INC) -I../../include -I$(HEADERS) -Wall -c -o $@ $<

# Rules for building from extras/xlsxio
$(OBJC_DIR)/%.o : ./xlsxio/%.m
	if [ ! -d "$(OBJC_DIR)" ]; then mkdir -p $(OBJC_DIR); fi
	$(CC) -ObjC -I$(HB_INC) -I../../include -I../../include/xlsxwriter -I$(HEADERS) -Wall -c -o $@ $<

# Rules for building from extras/xlsxwriter
$(OBJC_DIR)/%.o : ./xlsxwriter/%.c
	if [ ! -d "$(OBJC_DIR)" ]; then mkdir -p $(OBJC_DIR); fi
	$(CC) -ObjC $(CFLAGS) -I$(HB_INC) -I$(HEADERS) -I../../include -I../../include/xlsxwriter -Wall -DUSE_SYSTEM_MINIZIP -c -o $@ $<
