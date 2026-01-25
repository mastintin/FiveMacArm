#import "SwiftCommon.h"

HB_FUNC(SWIFTTOGGLECREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSString *cCaption = hb_NSSTRING_par(5);
  BOOL bIsOn = hb_parl(6);
  NSWindow *window = (NSWindow *)hb_parnl(7);
  NSInteger nIndex = (NSInteger)hb_parnl(8);
  NSString *cId = hb_NSSTRING_par(9);
  BOOL bSwitch = hb_parl(10);

  NSString *className = @"SwiftFive.SwiftToggleLoader";
  Class swiftClass = NSClassFromString(className);

  if (!swiftClass) {
    NSLog(@"Error: Could not find class %@", className);
    return;
  }

  // Callback: Receives Bool from Swift, calls Harbour block
  void (^callbackBlock)(BOOL) = ^(BOOL isOn) {
    dispatch_async(dispatch_get_main_queue(), ^{
      PHB_DYNS pDynSym = hb_dynsymFindName("SWIFTTOGGLEONCHANGE");
      if (pDynSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
        hb_vmPushNil();
        hb_vmPushInteger((int)nIndex);
        hb_vmPushLogical(isOn);
        hb_vmDo(2);
      }
    });
  };

  SEL selector = NSSelectorFromString(
      @"makeToggleWithCaption:isOn:id:isSwitch:index:callback:");

  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];

    [invocation setArgument:&cCaption atIndex:2];
    [invocation setArgument:&bIsOn atIndex:3];
    [invocation setArgument:&cId atIndex:4];
    [invocation setArgument:&bSwitch atIndex:5];
    [invocation setArgument:&nIndex atIndex:6];
    [invocation setArgument:&callbackBlock atIndex:7];

    [invocation invoke];

    NSView *toggleView;
    [invocation getReturnValue:&toggleView];

    if (toggleView) {
      setupSwiftView(toggleView, window, nTop, nLeft, nWidth, nHeight);
      hb_retnl((HB_LONG)toggleView);
    }
  } else {
    NSLog(@"ERROR: Selector %@ not found in class %@",
          NSStringFromSelector(selector), className);
  }
}

HB_FUNC(SWIFTTOGGLESET) {
  BOOL bIsOn = hb_parl(1);
  NSString *cId = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftToggleLoader";
  Class swiftClass = NSClassFromString(className);
  if (!swiftClass)
    return;

  SEL selector = NSSelectorFromString(@"setToggle:id:");
  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    [invocation setArgument:&bIsOn atIndex:2];
    [invocation setArgument:&cId atIndex:3];
    [invocation invoke];
  }
}

HB_FUNC(SWIFTTOGGLEGET) {
  NSInteger nIndex = (NSInteger)hb_parnl(1);
  NSString *className = @"SwiftFive.SwiftToggleLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"getToggleFromIndex:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&nIndex atIndex:2];
      [invocation invoke];

      BOOL bResult;
      [invocation getReturnValue:&bResult];
      hb_retl(bResult);
      return;
    }
  }
  hb_retl(NO);
}
