#import "SwiftFive-Swift.h"
#import <Cocoa/Cocoa.h>
#include <fivemac.h>
#include <hbapi.h>
#include <hbapiitm.h>

HB_FUNC(SWIFTOBSERVATIONCREATE) {
  id parent = (id)hb_parnll(1);
  NSInteger nIndex = (NSInteger)hb_parnll(2);
  int nTop = hb_parni(3);
  int nLeft = hb_parni(4);
  int nWidth = hb_parni(5);
  int nHeight = hb_parni(6);

  NSView *view = [SwiftObservationLoader makeObservationTest:nIndex];

  if (view) {
    if ([parent isKindOfClass:[NSWindow class]]) {
      [[(NSWindow *)parent contentView] addSubview:view];
    } else if ([parent isKindOfClass:[NSView class]]) {
      [(NSView *)parent addSubview:view];
    }
    [view setFrame:NSMakeRect(nLeft, nTop, nWidth, nHeight)];

    // Setup Callback
    void (^actionCallbackBlock)(NSString *) = ^(NSString *itemId) {
      if (!itemId)
        return;
      PHB_DYNS pSym = hb_dynsymFindName("SWIFTONACTION");
      if (pSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pSym));
        hb_vmPushNil();
        hb_vmPushNLL(nIndex);
        hb_vmPushString([itemId UTF8String], (HB_SIZE)[itemId length]);
        hb_vmDo(2);
      }
    };

    [SwiftObservationLoader setActionCallback:actionCallbackBlock];

    hb_retnll((HB_LONGLONG)view);
  } else {
    hb_retnll(0);
  }
}

HB_FUNC(SW_OBS_GETLEVEL) { hb_retnd(sw_obs_get_level()); }

HB_FUNC(SW_OBS_GETENABLED) { hb_retl(sw_obs_get_enabled()); }
