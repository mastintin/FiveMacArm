#import "SwiftCommon.h"

HB_FUNC(ZSTK_CREATE) {
  id parent = (id)hb_parnll(1);
  NSString *cId = GetRootIdFromParam(2);
  NSInteger nIndex = HB_ISNUM(2) ? hb_parni(2) : [cId intValue];

  NSView *view = [SwiftZStackLoader makeZStackWithIndex:cId];

  if (view) {
    void (^actionCallbackBlock)(NSString *) = ^(NSString *itemId) {
      if (!itemId)
        return;
      PHB_DYNS pSym = hb_dynsymFindName("SWIFTONACTION");
      if (pSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pSym));
        hb_vmPushNil();
        hb_vmPushNLL(nIndex);
        hb_vmPushString([itemId UTF8String], [itemId length]);
        hb_vmDo(2);
      }
    };

    [SwiftZStackLoader setActionCallbackWithRootId:cId
                                          callback:actionCallbackBlock];

    setupSwiftView(view, parent, hb_parnl(3), hb_parnl(4), hb_parnl(5),
                   hb_parnl(6));
    hb_retnll((HB_LONGLONG)view);
  } else {
    hb_retnll(0);
  }
}

HB_FUNC(ZSTK_ADD_ITEM) {
  hb_retc((const char *)SW_ZSTK_ADD_ITEM(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String]));
}

HB_FUNC(ZSTK_ADD_FILE_IMAGE) {
  hb_retc((const char *)SW_ZSTK_ADD_FILE_IMAGE(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String]));
}

HB_FUNC(ZSTK_ADD_IMAGE) {
  hb_retc((const char *)SW_ZSTK_ADD_FILE_IMAGE(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String]));
}

HB_FUNC(ZSTK_ADD_TEXT_TO) {
  hb_retc((const char *)SW_ZSTK_ADD_TEXT_TO(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
      hb_parvc(3) ? (const int8_t *)[hb_NSSTRING_par(3) UTF8String] : nil));
}

HB_FUNC(ZSTK_ADD_SYSTEM_IMAGE_TO) {
  hb_retc((const char *)SW_ZSTK_ADD_SYSTEM_IMAGE_TO(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
      hb_parvc(3) ? (const int8_t *)[hb_NSSTRING_par(3) UTF8String] : nil));
}

HB_FUNC(ZSTK_ADD_BUTTON_TO) {
  hb_retc((const char *)SW_ZSTK_ADD_BUTTON_TO(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
      hb_parvc(3) ? (const int8_t *)[hb_NSSTRING_par(3) UTF8String] : nil));
}

HB_FUNC(ZSTK_ADD_SPACER) {
  hb_retc((const char *)SW_ZSTK_ADD_SPACER(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      hb_parvc(2) ? (const int8_t *)[hb_NSSTRING_par(2) UTF8String] : nil));
}

HB_FUNC(ZSTK_ADD_DIVIDER) {
  hb_retc((const char *)SW_ZSTK_ADD_DIVIDER(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      hb_parvc(2) ? (const int8_t *)[hb_NSSTRING_par(2) UTF8String] : nil));
}

HB_FUNC(ZSTK_ADD_BATCH) {
  hb_retc((const char *)SW_ZSTK_ADD_BATCH(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
      hb_parvc(3) ? (const int8_t *)[hb_NSSTRING_par(3) UTF8String] : nil));
}

HB_FUNC(ZSTK_ADD_LIST) {
  hb_retc((const char *)SW_ZSTK_ADD_LIST(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      hb_parvc(2) ? (const int8_t *)[hb_NSSTRING_par(2) UTF8String] : nil));
}

HB_FUNC(ZSTK_ADD_LAZYVGRID) {
  hb_retc((const char *)SW_ZSTK_ADD_LAZYVGRID(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      hb_parvc(2) ? (const int8_t *)[hb_NSSTRING_par(2) UTF8String] : nil,
      (const int8_t *)[hb_NSSTRING_par(3) UTF8String]));
}

HB_FUNC(ZSTK_ADD_VSTACK) {
  hb_retc((const char *)SW_VSTK_ADD_VSTACK(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      hb_parvc(2) ? (const int8_t *)[hb_NSSTRING_par(2) UTF8String] : nil));
}

HB_FUNC(ZSTK_ADD_HSTACK) {
  hb_retc((const char *)SW_VSTK_ADD_HSTACK(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      hb_parvc(2) ? (const int8_t *)[hb_NSSTRING_par(2) UTF8String] : nil));
}

HB_FUNC(ZSTK_REMOVE_ALL_ITEMS) {
  SW_ZSTK_REMOVE_ALL((const int8_t *)[GetRootIdFromParam(1) UTF8String]);
}

HB_FUNC(ZSTK_SET_ALIGNMENT) {
  SW_ZSTK_SET_ALIGNMENT((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                        sw_parc(2));
}

HB_FUNC(ZSTK_SET_BGCOLOR_HEX) {
  SW_ZSTK_SET_BGCOLOR_HEX((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                          sw_parc(2));
}

HB_FUNC(ZSTK_SET_FGCOLOR_HEX) {
  SW_ZSTK_SET_FGCOLOR_HEX((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                          sw_parc(2));
}

HB_FUNC(ZSTK_SET_ITEM_COLOR_HEX) {
  SW_ZSTK_SET_ITEM_COLOR_HEX((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                             (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
                             sw_parc(3));
}

HB_FUNC(ZSTK_SET_ITEM_BGCOLOR_HEX) {
  SW_ZSTK_SET_ITEM_BGCOLOR_HEX(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String], sw_parc(3));
}
