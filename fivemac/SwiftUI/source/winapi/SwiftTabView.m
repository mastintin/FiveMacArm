#import "SwiftCommon.h"

HB_FUNC(SWIFTTABCLEAR) { [SwiftTabViewLoader clearTabs]; }

HB_FUNC(SWIFTTABADD) {
  NSInteger nIndex = (NSInteger)hb_parnll(1);
  NSString *title = hb_NSSTRING_par(2);
  NSString *icon = hb_NSSTRING_par(3);

  [SwiftTabViewLoader addTabWithIndex:nIndex title:title icon:icon];
}

HB_FUNC(SWIFTTABVIEWCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSWindow *window = (NSWindow *)hb_parnll(5);

  NSView *view = [SwiftTabViewLoader makeTabView];
  if (view) {
    setupSwiftView(view, window, nTop, nLeft, nWidth, nHeight);
    hb_retnll((HB_LONGLONG)view);
  } else {
    hb_retnll(0);
  }
}

HB_FUNC(SWIFTREGISTERVIEW) { // ( hWnd, nIndex )
  NSView *view = (NSView *)hb_parnll(1);
  NSInteger nIndex = (NSInteger)hb_parnll(2);

  [ViewRegistry registerNSView:view forIndex:nIndex];
}
