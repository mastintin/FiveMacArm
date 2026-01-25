#import "SwiftCommon.h"

HB_FUNC(SWIFTSLIDERCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  double nValue = hb_parnd(5);
  NSWindow *window = (NSWindow *)hb_parnl(6);
  NSInteger nIndex =
      (NSInteger)hb_parnl(7);         // Control Index (64-bit for NSInvocation)
  NSString *cId = hb_NSSTRING_par(8); // UUID
  BOOL bShowValue = hb_parl(9);       // Show Value
  BOOL bGlass = hb_parl(10);          // Is Glass

  NSLog(@"DEBUG: SWIFTSLIDERCREATE. Index: %ld, ID: %@, ShowVal: %d, Glass: %d",
        (long)nIndex, cId, bShowValue, bGlass);

  NSString *className = @"SwiftFive.SwiftSliderLoader";
  Class swiftClass = NSClassFromString(className);

  if (!swiftClass) {
    NSLog(@"Error: Could not find class %@", className);
    return;
  }

  // Callback: Receives NSNumber from Swift, passes Double to Harbour
  void (^callbackBlock)(NSNumber *) = ^(NSNumber *val) {
    dispatch_async(dispatch_get_main_queue(), ^{
      PHB_DYNS pDynSym = hb_dynsymFindName("SWIFTSLIDERONCHANGE");
      if (pDynSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
        hb_vmPushNil();
        hb_vmPushInteger((int)nIndex);
        hb_vmPushDouble([val doubleValue], 0);
        hb_vmDo(2);
      }
    });
  };

  SEL selector = NSSelectorFromString(
      @"makeSliderWithValue:id:showValue:isGlass:index:callback:");

  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];

    NSNumber *numVal = @(nValue);
    [invocation setArgument:&numVal atIndex:2];
    [invocation setArgument:&cId atIndex:3];
    [invocation setArgument:&bShowValue atIndex:4];
    [invocation setArgument:&bGlass atIndex:5];
    [invocation setArgument:&nIndex atIndex:6];
    [invocation setArgument:&callbackBlock atIndex:7];

    [invocation invoke];

    NSView *sliderView;
    [invocation getReturnValue:&sliderView];

    if (sliderView) {
      setupSwiftView(sliderView, window, nTop, nLeft, nWidth, nHeight);
      hb_retnl((HB_LONG)sliderView);
    }
  } else {
    NSLog(@"ERROR: Selector %@ not found in class %@",
          NSStringFromSelector(selector), className);
  }
}

HB_FUNC(SWIFTSLIDERSETVALUE) {
  double nValue = hb_parnd(1);
  NSString *cId = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftSliderLoader";
  Class swiftClass = NSClassFromString(className);
  if (!swiftClass)
    return;

  SEL selector = NSSelectorFromString(@"setSliderValue:id:");
  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    [invocation setArgument:&nValue atIndex:2];
    [invocation setArgument:&cId atIndex:3];
    [invocation invoke];
  } else {
    NSLog(@"ERROR: Selector setSliderValue:id: NOT found.");
  }
}
