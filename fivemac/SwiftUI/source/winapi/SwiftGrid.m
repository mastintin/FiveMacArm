#import "SwiftCommon.h"

HB_FUNC(SWIFTGRIDCREATE) {
  id parent = (id)hb_parnll(1);
  NSString *cId = HB_ISNUM(2) ? [NSString stringWithFormat:@"%d", hb_parni(2)]
                              : hb_NSSTRING_par(2);
  NSInteger nIndex = [cId intValue];
  NSString *columnsJson = hb_NSSTRING_par(7);

  NSView *view = [SwiftGridLoader makeGridWithIndex:cId
                                        columnsJson:columnsJson];

  if (view) {
    // Setup Action Callback (modern string-based)
    void (^actionCallback)(NSString *) = ^(NSString *idStr) {
      if (!idStr)
        return;
      PHB_DYNS pSym = hb_dynsymFindName("SWIFTGRIDONACTION");
      if (pSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pSym));
        hb_vmPushNil();
        hb_vmPushNLL(nIndex);
        hb_vmPushString([idStr UTF8String], [idStr length]);
        hb_vmDo(2);
      }
    };

    [SwiftGridLoader setActionCallbackWithRootId:cId callback:actionCallback];

    setupSwiftView(view, parent, hb_parnl(3), hb_parnl(4), hb_parnl(5),
                   hb_parnl(6));
    hb_retnll((HB_LONGLONG)view);
  } else {
    hb_retnll(0);
  }
}
