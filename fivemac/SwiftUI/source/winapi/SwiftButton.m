#import "SwiftCommon.h"

HB_FUNC(SWIFTBTNCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSString *cPrompt = hb_NSSTRING_par(5);
  id parent = (id)hb_parnll(6);
  NSInteger nIndex =
      (NSInteger)hb_parnll(7); // Receive the Index in aSwiftButtons

  // Class name hardcoded or passed? We use specific loader.
  NSString *className = @"SwiftFive.SwiftButtonLoader";
  Class swiftClass = NSClassFromString(className);

  if (!swiftClass) {
    NSLog(@"Error: Could not find class %@", className);
    return;
  }

  // Callback
  void (^callbackBlock)(NSString *) = ^(NSString *msg) {
    dispatch_async(dispatch_get_main_queue(), ^{
      PHB_DYNS pDynSym = hb_dynsymFindName("SWIFTBTNONCLICK");
      if (pDynSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
        hb_vmPushNil();
        hb_vmPushNLL(nIndex);
        hb_vmDo(1);
      }
    });
  };

  // Direct call to Swift Factory
  NSView *btnView = [SwiftButtonLoader makeButtonWithTitle:cPrompt
                                                     index:nIndex
                                                  callback:callbackBlock];

  if (btnView) {
    NSLog(@"DEBUG: SWIFTBTNCREATE success for index: %ld", (long)nIndex);
    setupSwiftView(btnView, parent, nTop, nLeft, nWidth, nHeight);
    hb_retnll((HB_LONGLONG)btnView);
  }
}

HB_FUNC(BTN_SET_TEXT) {
  SW_BTN_SET_TEXT((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                  sw_parc(2));
}

HB_FUNC(BTN_SET_BG) {
  SW_BTN_SET_BG((const int8_t *)[GetRootIdFromParam(1) UTF8String], sw_parc(2));
}

HB_FUNC(BTN_SET_FG) {
  SW_BTN_SET_FG((const int8_t *)[GetRootIdFromParam(1) UTF8String], sw_parc(2));
}

HB_FUNC(BTN_SET_RADIUS) {
  SW_BTN_SET_RADIUS((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                    sw_parc(2));
}

HB_FUNC(BTN_SET_PADDING) {
  SW_BTN_SET_PADDING((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                     sw_parc(2));
}

HB_FUNC(BTN_SET_GLASS) {
  SW_BTN_SET_GLASS((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                   sw_parc(2));
}

HB_FUNC(BTN_SET_IMAGE) {
  SW_BTN_SET_IMAGE((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                   sw_parc(2));
}
