#import "SwiftCommon.h"

HB_FUNC(SWIFTTABCLEAR) {
  NSString *className = @"SwiftFive.SwiftTabViewLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass && [swiftClass respondsToSelector:@selector(clearTabs)]) {
    [swiftClass performSelector:@selector(clearTabs)];
  }
}

HB_FUNC(SWIFTTABADD) {
  int nIndex = hb_parni(1);
  NSString *title = hb_NSSTRING_par(2);
  NSString *icon = hb_NSSTRING_par(3);

  NSString *className = @"SwiftFive.SwiftTabViewLoader";
  Class swiftClass = NSClassFromString(className);

  SEL selector = NSSelectorFromString(@"addTabWithIndex:title:icon:");
  if (swiftClass && [swiftClass respondsToSelector:selector]) {
    // Method: addTab(index: Int, title: String, icon: String)
    // Swift name might be addTabWithIndex:title:icon: or
    // addTab(index:title:icon:) mapping In Swift: @objc public static func
    // addTab(index: Int, title: String, icon: String) Default ObjC selector:
    // addTabWithIndex:title:icon:

    // nIndex is int/NSInteger
    // We use NSInvocation
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];

    NSInteger idx = (NSInteger)nIndex;
    [invocation setArgument:&idx atIndex:2];
    [invocation setArgument:&title atIndex:3];
    [invocation setArgument:&icon atIndex:4];

    [invocation invoke];
  }
}

HB_FUNC(SWIFTTABVIEWCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSWindow *window = (NSWindow *)hb_parnl(5);

  NSString *className = @"SwiftFive.SwiftTabViewLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass && [swiftClass respondsToSelector:@selector(makeTabView)]) {
    NSView *view = [swiftClass performSelector:@selector(makeTabView)];
    if (view) {
      setupSwiftView(view, window, nTop, nLeft, nWidth, nHeight);
      hb_retnl((HB_LONG)view);
    } else {
      hb_retnl(0);
    }
  } else {
    hb_retnl(0);
  }
}

HB_FUNC(SWIFTREGISTERVIEW) { // ( hWnd, nIndex )
  NSView *view = (NSView *)hb_parnll(1);
  int nIndex = hb_parni(2);

  NSString *className = @"SwiftFive.ViewRegistry";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"registerNSView:forIndex:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];

      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      NSInteger idx = (NSInteger)nIndex;
      [invocation setArgument:&view atIndex:2];
      [invocation setArgument:&idx atIndex:3];

      [invocation invoke];
    }
  }
}
