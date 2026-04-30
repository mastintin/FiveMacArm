#import <AppKit/NSCursor.h>

#include <fivemac.h>

// deprecated
HB_FUNC(SETCURSORSIZE) { [[NSCursor resizeLeftRightCursor] set]; }

HB_FUNC(SETCURSORARROW) { [[NSCursor arrowCursor] set]; }

HB_FUNC(SETCURSORHAND) { [[NSCursor openHandCursor] set]; }

// deprecated
HB_FUNC(SETCURSORRESIZEDOWN) { [[NSCursor resizeDownCursor] set]; }

HB_FUNC(SETCURSORCLOSEHAND) { [[NSCursor closedHandCursor] set]; }

HB_FUNC(SETCURSORIMAGE) {
  NSString *string = hb_NSSTRING_par(1);
  NSImage *image;

  NSFileManager *filemgr = [NSFileManager defaultManager];

  if ([filemgr fileExistsAtPath:string])
    image = [[NSImage alloc] initWithContentsOfFile:string];
  else
    image = ImgTemplate(string);

  NSCursor *imageCursor = [[NSCursor alloc] initWithImage:image
                                                  hotSpot:NSZeroPoint];
  [image release];
  [imageCursor set];
}

HB_FUNC(SETCURSORSFSYMBOL) {
  NSString *name = hb_NSSTRING_par(1);
  NSString *descrip = hb_NSSTRING_par(2);
  NSImage *img = [NSImage imageWithSystemSymbolName:name
                           accessibilityDescription:descrip];

  NSCursor *imageCursor = [[NSCursor alloc] initWithImage:img
                                                  hotSpot:NSMakePoint(8, 8)];
  [img release];
  [imageCursor set];
}

HB_FUNC(GETCURSORPOSIDIREC) {
  NSCursor *cursor = [NSCursor
      frameResizeCursorFromPosition:NSCursorFrameResizePositionBottomRight
                       inDirections:NSCursorFrameResizeDirectionsAll];
  [cursor set];
}

HB_FUNC(CURSORSET) {
  NSCursor *cursor = (NSCursor *)hb_parnll(1);
  [cursor set];
}
