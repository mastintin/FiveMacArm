#import "SwiftCommon.h"
/*
// Helper to get hex color string
static NSString *HexColorForImage(long nColor) {
  int r = nColor & 0xFF;
  int g = (nColor >> 8) & 0xFF;
  int b = (nColor >> 16) & 0xFF;
  return [NSString stringWithFormat:@"%02X%02X%02X", r, g, b];
}

HB_FUNC(SWIFTIMAGECREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSString *systemName = hb_NSSTRING_par(5);
  id parent = (id)hb_parnll(6);

  // SUPPORT FOR HYBRID ID (Int or String)
  NSString *cId = nil;
  NSInteger nIndex = 0;

  if (HB_ISNUM(7)) {
    nIndex = (NSInteger)hb_parnll(7);
    cId = [NSString stringWithFormat:@"%ld", (long)nIndex];
  } else if (HB_ISCHAR(7)) {
    cId = hb_NSSTRING_par(7);
    nIndex = [cId intValue]; // Try validation
  }

  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);

  if (!swiftClass) {
    NSLog(@"Error: Could not find class %@", className);
    return;
  }

  void (^callbackBlock)(NSString *) = ^(NSString *msg) {
    dispatch_async(dispatch_get_main_queue(), ^{
      PHB_DYNS pDynSym = hb_dynsymFindName("SWIFTIMAGEONCLICK");
      if (pDynSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
        hb_vmPushNil();
        hb_vmPushNLL(nIndex);
        // Legacy support
        hb_vmDo(1);
      }
    });
  };

  // Direct call to Swift Factory instead of NSInvocation
  NSView *imgView = [SwiftImageLoader makeImageWithSystemName:systemName
                                                        index:cId
                                                     callback:callbackBlock];

  if (imgView) {
    setupSwiftView(imgView, parent, nTop, nLeft, nWidth, nHeight);
    hb_retnll((HB_LONGLONG)imgView);
  }
}

HB_FUNC(IMG_SET_SYSTEM_NAME) {
  NSString *cId = GetRootIdFromParam(1);
  NSString *name = hb_NSSTRING_par(2);
  SW_IMG_SET_SYSTEM_NAME((const int8_t *)[cId UTF8String],
                         (const int8_t *)[name UTF8String]);
}

HB_FUNC(IMG_SET_NAME) {
  NSString *cId = GetRootIdFromParam(1);
  NSString *name = hb_NSSTRING_par(2);
  SW_IMG_SET_NAME((const int8_t *)[cId UTF8String],
                  (const int8_t *)[name UTF8String]);
}

HB_FUNC(IMG_SET_FILE) {
  NSString *cId = GetRootIdFromParam(1);
  NSString *path = hb_NSSTRING_par(2);
  SW_IMG_SET_FILE((const int8_t *)[cId UTF8String],
                  (const int8_t *)[path UTF8String]);
}

HB_FUNC(IMG_SET_COLOR) {
  NSString *cId = GetRootIdFromParam(1);
  NSString *hex = hb_NSSTRING_par(2);
  SW_IMG_SET_COLOR((const int8_t *)[cId UTF8String],
                   (const int8_t *)[hex UTF8String]);
}

HB_FUNC(IMG_SET_RESIZABLE) {
  NSString *cId = GetRootIdFromParam(1);
  NSString *val = hb_parl(2) ? @"1" : @"0";
  SW_IMG_SET_RESIZABLE((const int8_t *)[cId UTF8String],
                       (const int8_t *)[val UTF8String]);
}

HB_FUNC(IMG_SET_ASPECT_RATIO) {
  NSString *cId = GetRootIdFromParam(1);
  NSString *mode = [NSString stringWithFormat:@"%d", hb_parni(2)];
  SW_IMG_SET_ASPECT_RATIO((const int8_t *)[cId UTF8String],
                          (const int8_t *)[mode UTF8String]);
}
*/