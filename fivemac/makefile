# FiveMac makefile (c) FiveTech Software 2008-2015
# Don't use spaces before the rules. Use TABs

# General paths
SDKPATH=$(shell xcrun --show-sdk-path)
HEADERS=$(SDKPATH)/usr/include
FRAMEPATH=$(SDKPATH)/System/Library/Frameworks

# Flags
# Using 10.13 as a reasonable minimum for modern builds, or stick to what works for the user. 
# The previous valid one was 10.12.
MIN_VER=-mmacosx-version-min=10.12
CFLAGS=$(MIN_VER)
CVFLAGS=$(MIN_VER)
CC=clang
SWIFTFLAGS = -I../include -sdk $(SDKPATH)

# Harbour paths
HB_DIR=../harbour
HB_BIN=$(HB_DIR)/bin/harbour
HB_INC=$(HB_DIR)/include


all : ./lib/libfive.a ./lib/libfivec.a create

PRG_OBJS = \
  	./obj/applicat.o \
	./obj/browse.o	\
	./obj/button.o	\
	./obj/btnbmp.o	\
	./obj/brush.o	\
	./obj/brImage.o	\
	./obj/capture.o	\
	./obj/checkbox.o \
        ./obj/clipboard.o \
   	./obj/code.o \
	./obj/colors.o \
	./obj/colorwell.o \
	./obj/combobox.o \
	./obj/control.o	\
	./obj/coverflow.o \
	./obj/database.o \
	./obj/datepicker.o \
  	./obj/dbtools.o \
	./obj/dialog.o	\
	./obj/errsysm.o \
	./obj/filename.o \
    ./obj/fmget.o \
	./obj/folder.o	\
	./obj/folditem.o \
	./obj/font.o \
  	./obj/form.o \
  	./obj/get.o \
	./obj/group.o \
	./obj/harbour.o \
    ./obj/hbdocs.o \
	./obj/image.o \
	./obj/inspect.o \
  	./obj/itunes.o \
   	./obj/locale.o \
  	./obj/mail.o \
  	./obj/memoedit.o \
	./obj/menu.o \
	./obj/menuitem.o \
	./obj/mget.o \
	./obj/movie.o \
  	./obj/multiview.o \
	./obj/nodo.o \
        ./obj/notification.o \
  	./obj/nsobject.o \
  	./obj/picture.o \
  	./obj/printer.o \
	./obj/pdfview.o	\
	./obj/pdmenu.o	\
  	./obj/plist.o	\
	./obj/progres.o \
	./obj/radio.o	\
	./obj/radmenu.o	\
	./obj/outline.o	\
	./obj/say.o	\
	./obj/scintilla.o	\
	./obj/snippets.o	\
	./obj/simage.o	\
	./obj/segment.o \
	./obj/settings.o \
	./obj/slider.o \
	./obj/sqlite.o \
	./obj/splash.o \
	./obj/split.o \
	./obj/splitItem.o \
  	./obj/strings.o	\
	./obj/sheet.o \
	./obj/Tsound.o \
	./obj/tabview.o \
	./obj/tabItem.o \
        ./obj/tclipget.o \
        ./obj/textbox.o \
	./obj/Ttimer.o	\
	./obj/toolbar.o	\
	./obj/toolbtn.o	\
	./obj/TRect.o	\
   	./obj/valblank.o \
  	./obj/View.o	\
  	./obj/window.o	\
	./obj/webview.o

C_OBJS = ./objc/browses.o	\
	./objc/Areas.o \
	./objc/aesthetics.o \
	./objc/brushes.o	\
	./objc/buttons.o	\
   ./objc/checkboxes.o \
   ./objc/choosecolor.o \
   ./objc/choosefont.o \
    ./objc/colors.o \
  	./objc/colorton.o	\
	./objc/comboboxes.o \
	./objc/constants.o \
    ./objc/coverflows.o \
	./objc/cursors.o \
	./objc/datepickers.o \
	./objc/dialogs.o	\
	./objc/encript.o \
	./objc/fonts.o	\
  	./objc/formatters.o	\
    ./objc/fmget.o \
  	./objc/funcs.o \
	./objc/gets.o \
	./objc/groups.o \
    ./objc/IKImabr.o \
	./objc/images.o	\
	./objc/ImageAndTextCell.o	\
  	./objc/ituness.o	\
    ./objc/mailer.o \
	./objc/menus.o	\
	./objc/mgets.o	\
	./objc/movies.o	\
	./objc/msgs.o	\
	./objc/nibs.o \
    ./objc/notifications.o \
	./objc/objc.o \
	./objc/or.o	\
	./objc/outlines.o	\
  	./objc/pdfviews.o \
  	./objc/popover.o \
	./objc/preferences.o	\
	./objc/printers.o \
	./objc/progress.o \
	./objc/says.o	\
	./objc/scintillas.o	\
	./objc/simages.o	\
  	./objc/searchgets.o	\
  	./objc/segments.o	\
  	./objc/sgets.o \
  	./objc/sheets.o	\
  	./objc/sliders.o	\
  	./objc/sounds.o \
  	./objc/splits.o	\
	./objc/strtoken.o	\
  	./objc/system.o \
   	./objc/sqlite.o \
	./objc/timers.o	\
  	./objc/tarrays.o	\
	./objc/transparent.o \
	./objc/toolbars.o	\
	./objc/valtochr.o	\
  	./objc/RoundedView.o	\
  	./objc/urls.o	\
  	./objc/tabviews.o	\
  	./objc/views.o \
	./objc/webviews.o \
    ./objc/windows.o

SWIFT_OBJS =


./lib/libfive.a  : $(PRG_OBJS)
#	ranlib ./lib/libfive.a
	
./lib/libfivec.a : $(C_OBJS)
#	ranlib ./lib/libfivec.a

./lib/libfivec.a : $(SWIFT_OBJS)

./obj/%.c : ./source/classes/%.prg
	if [ ! -d "obj" ]; then mkdir obj; fi
	$(HB_BIN) $< -o./$@ -n -I$(HB_INC) -I./include

./obj/%.c : ./source/function/%.prg
	if [ ! -d "obj" ]; then mkdir obj; fi
	$(HB_BIN) $< -o./$@ -n -I$(HB_INC) -I./include

./objs/%.o : ./source/swift/%.swift
	if [ ! -d "objs" ]; then mkdir objs; fi
	swiftc -frontend -c -color-diagnostics -primary-file -Wno-nullability-completeness $<  \
	-module-name Bridgette \
	$(SWIFTFLAGS) -emit-module -emit-module-path ./source/swift/$*.swiftmodule \
	-emit-objc-header-path ./source/swift/$*-Swift.h \
	-enable-testing -enable-objc-interop -parse-as-library \
	-o $@
	if [ ! -d "lib" ]; then mkdir lib; fi
	ar rc ./lib/libfivec.a $@

# -arch i386 -arch ppc
./obj/%.o : ./obj/%.c
	$(CC) -ObjC -c -o $@ -I$(HB_INC) -I$(HEADERS) -F$(FRAMEPATH) $(CFLAGS) $<
	if [ ! -d "lib" ]; then mkdir lib; fi	
	ar rc ./lib/libfive.a $@ 

# -arch i386 -arch ppc
./objc/%.o : ./source/function/%.c
	if [ ! -d "objc" ]; then mkdir objc; fi
	$(CC) -ObjC -I$(HB_INC) -I./include -I$(HEADERS) -F$(FRAMEPATH) $(CFLAGS) -Wall -c -o $@ $<
	if [ ! -d "lib" ]; then mkdir lib; fi
	ar rc ./lib/libfivec.a $@

# -arch i386 -arch ppc
./objc/%.o : ./source/winapi/%.m
	if [ ! -d "objc" ]; then mkdir objc; fi
	$(CC) -ObjC -I$(HB_INC) -I./include -I$(HEADERS) -F./frameworks -Wall -c -o $@ $<
	if [ ! -d "lib" ]; then mkdir lib; fi
	if [ ! -d "lib" ]; then mkdir lib; fi
	ar rc ./lib/libfivec.a $@

# -arch i386 -arch ppc
./objc/%.o : ./source/winapi/%.c
	if [ ! -d "objc" ]; then mkdir objc; fi
	$(CC) -ObjC -I$(HB_INC) -I./include -I$(HEADERS) -Wall -c -o $@ $<
	if [ ! -d "lib" ]; then mkdir lib; fi
	ar rc ./lib/libfivec.a $@

# -arch i386 -arch ppc
./objc/%.o : ./source/internal/%.c
	if [ ! -d "objc" ]; then mkdir objc; fi
	$(CC) -ObjC -I$(HB_INC) -I./include -I$(HEADERS) -F$(FRAMEPATH) $(CFLAGS) -Wall -c -o $@ $<
	if [ ! -d "lib" ]; then mkdir lib; fi
	ar rc ./lib/libfivec.a $@

# -arch i386 -arch ppc
./objc/%.o : ./source/internal/%.m 
	if [ ! -d "objc" ]; then mkdir objc; fi
	$(CC) -ObjC -I$(HB_INC) -I./include -I$(HEADERS) -F$(FRAMEPATH) $(CFLAGS) -Wall -c -o $@ $<
	if [ ! -d "lib" ]; then mkdir lib; fi
	ar rc ./lib/libfivec.a $@

clean:
	rm -f ./obj/*
	rm -f ./objc/*
	rm -f ./lib/*

create:
	echo '<?xml version="1.0" encoding="UTF-8"?>' > Info.plist
	echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> Info.plist
	echo '<plist version="1.0">' >> Info.plist
	echo '<dict>' >> Info.plist
	echo '   <key>CFBundleExecutable</key>' >> Info.plist
	echo '   <string>Plantenkennis</string>' >> Info.plist
	echo '   <key>CFBundleName</key>' >> Info.plist
	echo '   <string>Plantenkennis</string>' >> Info.plist
	echo '   <key>CFBundleIdentifier</key>' >> Info.plist
	echo '   <string>com.fivetech.Plantenkennis</string>' >> Info.plist
	echo '   <key>CFBundlePackageType</key>' >> Info.plist
	echo '   <string>APPL</string>' >> Info.plist
	echo '   <key>CFBundleInfoDictionaryVersion</key>' >> Info.plist
	echo '   <string>6.0</string>' >> Info.plist
	echo '   <key>CFBundleIconFile</key>' >> Info.plist
	echo '   <string>fivetech.icns</string>' >> Info.plist
	echo '   <key>NSPrincipalClass</key>' >> Info.plist
	echo '   <string>NSApplication</string>' >> Info.plist
	echo '   <key>NSHighResolutionCapable</key>' >> Info.plist
	echo '<true/>' >> Info.plist
	echo '</dict>' >> Info.plist
	echo '</plist>' >> Info.plist
	
	cp Info.plist ./plist/





