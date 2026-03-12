#import "SwiftCommon.h"
/*
HB_FUNC(SWIFTTOGGLECREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSString *cCaption = hb_NSSTRING_par(5);
  BOOL bIsOn = sw_parl(6);
  id parent = (id)hb_parnll(7);
  NSInteger nIndex = (NSInteger)hb_parnll(8);
  NSString *cId = hb_NSSTRING_par(9);
  BOOL bSwitch = sw_parl(10);

  // Callback: Receives Bool from Swift, calls Harbour block
  void (^callbackBlock)(BOOL) = ^(BOOL isOn) {
    dispatch_async(dispatch_get_main_queue(), ^{
      PHB_DYNS pDynSym = hb_dynsymFindName("SWIFTTOGGLEONCHANGE");
      if (pDynSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
        hb_vmPushNil();
        hb_vmPushNLL(nIndex);
        hb_vmPushLogical(isOn);
        hb_vmDo(2);
      }
    });
  };

  // Call Swift Factory directly
  NSView *toggleView = [SwiftToggleLoader makeToggleWithCaption:cCaption
                                                           isOn:bIsOn
                                                             id:cId
                                                       isSwitch:bSwitch
                                                          index:nIndex
                                                       callback:callbackBlock];

  if (toggleView) {
    setupSwiftView(toggleView, parent, nTop, nLeft, nWidth, nHeight);
    hb_retnll((HB_LONGLONG)toggleView);
  }
}
*/

/*
HB_FUNC(TGL_SET_CAPTION) {
  SW_TGL_SET_CAPTION((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                     sw_parc(2));
}

HB_FUNC(TGL_SET_COLORS) {
  SW_TGL_SET_COLORS((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                    sw_parc(2), sw_parc(3));
}

HB_FUNC(TGL_GET_VALUE) {

  hb_retc((const char *)SW_TGL_GET_VALUE(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String]));
}
*/
