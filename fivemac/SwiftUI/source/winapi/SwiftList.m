#import "SwiftCommon.h"

HB_FUNC(SWIFTLISTCREATE) {
  id parent = (id)hb_parnll(1);
  NSString *cId = GetRootIdFromParam(2);
  NSInteger nIndex = HB_ISNUM(2) ? hb_parni(2) : [cId intValue];

  NSView *view = [SwiftListLoader makeListWithIndex:cId];

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

    [SwiftListLoader setActionCallbackWithRootId:cId
                                        callback:actionCallbackBlock];

    setupSwiftView(view, parent, hb_parnl(3), hb_parnl(4), hb_parnl(5),
                   hb_parnl(6));
    hb_retnll((HB_LONGLONG)view);
  } else {
    hb_retnll(0);
  }
}

HB_FUNC(SWIFTLISTSELECTINDEX) {
  NSString *rootId = GetRootIdFromParam(1);
  NSString *index = [NSString stringWithFormat:@"%ld", (long)hb_parnl(2)];
  SW_LST_SET_SELECTION((const int8_t *)[rootId UTF8String],
                       (const int8_t *)[index UTF8String]);
}

HB_FUNC(SWIFTLISTSETBGCOLOR) {
  NSString *rootId = GetRootIdFromParam(1);
  NSString *r = [NSString stringWithFormat:@"%f", hb_parnd(2)];
  NSString *g = [NSString stringWithFormat:@"%f", hb_parnd(3)];
  NSString *b = [NSString stringWithFormat:@"%f", hb_parnd(4)];
  NSString *a = [NSString stringWithFormat:@"%f", hb_parnd(5)];
  SW_LST_SET_BGCOLOR(
      (const int8_t *)[rootId UTF8String], (const int8_t *)[r UTF8String],
      (const int8_t *)[g UTF8String], (const int8_t *)[b UTF8String],
      (const int8_t *)[a UTF8String]);
}
