#ifndef FIVEMAC_H
#define FIVEMAC_H

#import <Cocoa/Cocoa.h>
#define HB_DONT_DEFINE_BOOL
#include "fmsgs.h"

#include <hbxvm.h>

#include <hbapi.h>
#include <hbapifs.h>
#include <hbapiitm.h>
#include <hbvm.h>

#define RGB(nRed, nGreen, nBlue) (nRed + (nGreen * 256) + (nBlue * 65536))

#define hb_vmPushNLL(n) hb_vmPushNumInt((HB_LONGLONG)n)

// #define hb_vmPushNLL(n) hb_xvmPushLongLong((HB_LONGLONG)n)

void hb_retstr_NS(NSString *string);

NSString *hb_NSSTRING_par(int iParam);
id hb_NSObjPar(int iParam);

NSAttributedString *hb_NSASTRING_par(int iParam);

#if __MAC_OS_X_VERSION_MAX_ALLOWED < 1050
#define NSInteger int
#define NSUInteger int
#define CGFloat float
#endif

NSString *NumToStr(NSInteger myInt);

NSView *GetView(NSWindow *window);

const char *ValToChar(PHB_ITEM item);

NSString *hb_NSSTRING_VAL_par(int iParam);

void ImgResize(NSImage *image, int nWidth, int nHeight);

NSImage *ImgTemplate(NSString *);

#define FIVEMAC_DRAGDROP_METHODS                                               \
  -(NSDragOperation)draggingEntered : (id<NSDraggingInfo>)sender {             \
    return NSDragOperationCopy;                                                \
  }                                                                            \
  -(NSDragOperation)draggingUpdated : (id<NSDraggingInfo>)sender {             \
    return NSDragOperationCopy;                                                \
  }                                                                            \
  -(BOOL)performDragOperation : (id<NSDraggingInfo>)sender {                   \
    NSPasteboard *pboard = [sender draggingPasteboard];                        \
    NSArray *classes = [NSArray arrayWithObject:[NSURL class]];                \
    NSDictionary *options = [NSDictionary dictionary];                         \
    NSArray *fileURLs = [pboard readObjectsForClasses:classes                  \
                                              options:options];                \
    if (fileURLs != nil && [fileURLs count] > 0) {                             \
      PHB_SYMB symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));            \
      if (symFMH) {                                                            \
        hb_vmPushSymbol(symFMH);                                               \
        hb_vmPushNil();                                                        \
        hb_vmPushNumInt((HB_LONGLONG)[self window]);                           \
        hb_vmPushLong(WM_DROPFILES);                                           \
        hb_vmPushNumInt((HB_LONGLONG)self);                                    \
        PHB_ITEM pArray = hb_itemArrayNew([fileURLs count]);                   \
        for (NSUInteger i = 0; i < [fileURLs count]; i++) {                    \
          PHB_ITEM pString = hb_itemPutC(                                      \
              NULL, [[[fileURLs objectAtIndex:i] path] UTF8String]);           \
          hb_itemArrayPut(pArray, i + 1, pString);                             \
          hb_itemRelease(pString);                                             \
        }                                                                      \
        hb_vmPush(pArray);                                                     \
        hb_vmDo(4);                                                            \
        hb_itemRelease(pArray);                                                \
      }                                                                        \
      return YES;                                                              \
    }                                                                          \
    return NO;                                                                 \
  }

#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
@interface View : NSView <NSWindowDelegate>
#else
@interface View : NSView
#endif
{
@public
  BOOL bDesign;
  BOOL bVibrancy;
  NSWindow *originalWindow;
}
- (void)setOriginalWindow:(NSWindow *)window;
- (BOOL)windowShouldClose:(NSNotification *)notification;
- (void)windowWillClose:(NSNotification *)notification;
- (BOOL)acceptsFirstResponder;

- (void)windowDidResignKey:(NSNotification *)notification;
- (void)windowDidBecomeKey:(NSNotification *)notification;

- (void)windowDidUpdate:(NSNotification *)notification;
- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseUp:(NSEvent *)theEvent;
- (void)rightMouseDown:(NSEvent *)theEvent;
- (void)mouseMoved:(NSEvent *)theEvent;
- (void)mouseDragged:(NSEvent *)theEvent;
- (void)keyDown:(NSEvent *)theEvent;
- (void)flagsChanged:(NSEvent *)theEvent;
- (void)windowDidResize:(NSNotification *)notification;
- (void)MenuItem:(id)sender;
- (void)BtnClick:(id)sender;
- (void)CbxChange:(id)sender;
- (void)ChkClick:(id)sender;
- (void)BrwDblClick:(id)sender;
- (void)TbrClick:(id)sender;
- (void)OnTimerEvent:(NSTimer *)timer;
- (void)SliderChanged:(id)sender;
- (IBAction)changeColor:(id)sender;
- (NSView *)hitTest:(NSPoint)aPoint;
- (BOOL)isFlipped;
@end

#endif
