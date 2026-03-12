#import "SwiftCommon.h"

/*
HB_FUNC(SWIFTSLIDERCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  double nValue = hb_parnd(5);
  id parent = (id)hb_parnll(6);
  NSInteger nIndex = (NSInteger)hb_parnll(7);
  NSString *cId = hb_NSSTRING_par(8);
  BOOL bShowValue = hb_parl(9);
  BOOL bGlass = hb_parl(10);

  // Callback
  void (^callbackBlock)(NSNumber *) = ^(NSNumber *val) {
    dispatch_async(dispatch_get_main_queue(), ^{
      PHB_DYNS pDynSym = hb_dynsymFindName("SWIFTSLIDERONCHANGE");
      if (pDynSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
        hb_vmPushNil();
        hb_vmPushNLL(nIndex);
        hb_vmPushDouble([val doubleValue], 0);
        hb_vmDo(2);
      }
    });
  };

  // Direct call to Swift Factory
  NSView *sliderView = [SwiftSliderLoader makeSliderWithValue:@(nValue)
                                                           id:cId
                                                    showValue:bShowValue
                                                      isGlass:bGlass
                                                        index:nIndex
                                                     callback:callbackBlock];

  if (sliderView) {
    setupSwiftView(sliderView, parent, nTop, nLeft, nWidth, nHeight);
    hb_retnll((HB_LONGLONG)sliderView);
  }
}

HB_FUNC(SLD_SET_VALUE) {
  NSString *cId = GetRootIdFromParam(1);
  NSString *valStr = hb_NSSTRING_par(2);
  SW_SLD_SET_VALUE((const int8_t *)[cId UTF8String],
                   (const int8_t *)[valStr UTF8String]);
}

HB_FUNC(SLD_GET_VALUE) {
  NSString *cId = GetRootIdFromParam(1);
  const char *res =
      (const char *)SW_SLD_GET_VALUE((const int8_t *)[cId UTF8String]);
  hb_retc(res ? res : "0");
}

HB_FUNC(SLD_SET_ACCENT_COLOR) {
  NSString *cId = GetRootIdFromParam(1);
  NSString *hex = hb_NSSTRING_par(2);
  SW_SLD_SET_ACCENT_COLOR((const int8_t *)[cId UTF8String],
                          (const int8_t *)[hex UTF8String]);
}

HB_FUNC(SLD_SET_COLORS) {
  NSString *cId = GetRootIdFromParam(1);
  NSString *fg = hb_NSSTRING_par(2);
  NSString *bg = hb_NSSTRING_par(3);
  SW_SLD_SET_COLORS((const int8_t *)[cId UTF8String],
                    (const int8_t *)[fg UTF8String],
                    (const int8_t *)[bg UTF8String]);
}
*/
