#import "SwiftCommon.h"

HB_FUNC(VSTK_CREATE) {
  id parent = (id)hb_parnll(1);
  NSString *cId = GetRootIdFromParam(2);
  NSInteger nIndex = HB_ISNUM(2) ? hb_parni(2) : [cId intValue];

  // Direct call to Swift Factory (This one stays direct as it's the
  // constructor)
  NSView *view = [SwiftVStackLoader makeVStackWithIndex:cId];

  if (view) {
    // Setup Action Callback
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

    [SwiftVStackLoader setActionCallbackWithRootId:cId
                                          callback:actionCallbackBlock];

    setupSwiftView(view, parent, hb_parnl(3), hb_parnl(4), hb_parnl(5),
                   hb_parnl(6));
    hb_retnll((HB_LONGLONG)view);
  } else {
    hb_retnll(0);
  }
}

HB_FUNC(VSTK_ADD_ITEM) {
  hb_retc((const char *)SW_VSTK_ADD_ITEM(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String]));
}

HB_FUNC(VSTK_ADD_TEXT_TO) {
  hb_retc((const char *)SW_VSTK_ADD_TEXT_TO(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
      hb_parvc(3) ? (const int8_t *)[hb_NSSTRING_par(3) UTF8String] : nil));
}

HB_FUNC(VSTK_ADD_SPACER_TO) {
  hb_retc((const char *)SW_VSTK_ADD_SPACER_TO(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      hb_parvc(2) ? (const int8_t *)[hb_NSSTRING_par(2) UTF8String] : nil));
}

HB_FUNC(VSTK_ADD_SYSTEM_IMAGE_TO) {
  hb_retc((const char *)SW_VSTK_ADD_SYSTEM_IMAGE_TO(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
      hb_parvc(3) ? (const int8_t *)[hb_NSSTRING_par(3) UTF8String] : nil));
}

HB_FUNC(VSTK_ADD_HSTACK) {
  hb_retc((const char *)SW_VSTK_ADD_HSTACK(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      hb_parvc(2) ? (const int8_t *)[hb_NSSTRING_par(2) UTF8String] : nil));
}

HB_FUNC(VSTK_ADD_VSTACK) {
  hb_retc((const char *)SW_VSTK_ADD_VSTACK(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      hb_parvc(2) ? (const int8_t *)[hb_NSSTRING_par(2) UTF8String] : nil));
}

HB_FUNC(VSTK_ADD_BUTTON_ITEM) {
  hb_retc((const char *)SW_VSTK_ADD_BUTTON_ITEM(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
      hb_parvc(3) ? (const int8_t *)[hb_NSSTRING_par(3) UTF8String] : nil));
}

HB_FUNC(VSTK_ADD_BATCH) {
  hb_retc((const char *)SW_VSTK_ADD_BATCH(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
      hb_parvc(3) ? (const int8_t *)[hb_NSSTRING_par(3) UTF8String] : nil));
}

HB_FUNC(VSTK_ADD_LIST) {
  hb_retc((const char *)SW_VSTK_ADD_LIST(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      hb_parvc(2) ? (const int8_t *)[hb_NSSTRING_par(2) UTF8String] : nil));
}

HB_FUNC(VSTK_ADD_LAZYVGRID) {
  hb_retc((const char *)SW_VSTK_ADD_LAZYVGRID(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      hb_parvc(2) ? (const int8_t *)[hb_NSSTRING_par(2) UTF8String] : nil,
      (const int8_t *)[hb_NSSTRING_par(3) UTF8String]));
}

HB_FUNC(VSTK_ADD_DIVIDER_TO) {
  hb_retc((const char *)SW_VSTK_ADD_DIVIDER_TO(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      hb_parvc(2) ? (const int8_t *)[hb_NSSTRING_par(2) UTF8String] : nil));
}

HB_FUNC(VSTK_REMOVE_ALL_ITEMS) {
  SW_VSTK_REMOVE_ALL((const int8_t *)[GetRootIdFromParam(1) UTF8String]);
}

HB_FUNC(VSTK_SET_SCROLL) {
  SW_VSTK_SET_SCROLL((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                     sw_parl(2) ? (const int8_t *)"1" : (const int8_t *)"0");
}

HB_FUNC(VSTK_SET_BGCOLOR_HEX) {
  SW_VSTK_SET_BGCOLOR_HEX((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                          sw_parc(2));
}

HB_FUNC(VSTK_SET_FGCOLOR_HEX) {
  SW_VSTK_SET_FGCOLOR_HEX((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                          sw_parc(2));
}

HB_FUNC(VSTK_SET_INVERTED_COLOR) {
  SW_VSTK_SET_INVERTED_COLOR((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                             sw_parl(2) ? (const int8_t *)"1"
                                        : (const int8_t *)"0");
}

HB_FUNC(VSTK_SET_SPACING) {
  SW_VSTK_SET_SPACING((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                      sw_parc(2));
}

HB_FUNC(VSTK_SET_ALIGNMENT) {
  SW_VSTK_SET_ALIGNMENT((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                        sw_parc(2));
}

HB_FUNC(VSTK_SET_ITEM_TEXT) {
  SW_VSTK_SET_ITEM_TEXT((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                        (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
                        sw_parc(3));
}

HB_FUNC(VSTK_SET_ITEM_COLOR_HEX) {
  SW_VSTK_SET_ITEM_COLOR_HEX((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                             (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
                             sw_parc(3));
}

HB_FUNC(VSTK_SET_ITEM_BGCOLOR_HEX) {
  SW_VSTK_SET_ITEM_BGCOLOR_HEX(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String],
      (const int8_t *)[hb_NSSTRING_par(2) UTF8String], sw_parc(3));
}

HB_FUNC(VSTK_SET_ITEM_LAYOUT) {
  SW_VSTK_SET_ITEM_LAYOUT((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                          (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
                          sw_parc(3), sw_parc(4), sw_parc(5));
}

HB_FUNC(VSTK_SET_ITEM_FONT) {
  SW_VSTK_SET_ITEM_FONT((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                        (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
                        sw_parc(3), sw_parc(4));
}

HB_FUNC(VSTK_SET_ITEM_RADIUS) {
  SW_VSTK_SET_ITEM_RADIUS((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                          (const int8_t *)[hb_NSSTRING_par(2) UTF8String],
                          sw_parc(3));
}

HB_FUNC(VSTK_GET_LAST_ITEM_ID) {
  const char *res = (const char *)SW_VSTK_GET_LAST_ITEM_ID(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String]);
  hb_retc(res ? res : "");
}
