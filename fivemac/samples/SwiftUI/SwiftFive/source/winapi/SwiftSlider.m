#import "SwiftCommon.h"

HB_FUNC(SWIFTSLIDERCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  double nValue = hb_parnd(5);
  NSWindow *window = (NSWindow *)hb_parnl(6);
  int nIndex = hb_parni(7); // Control Index

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
        hb_vmPushInteger(nIndex);
        hb_vmPushDouble([val doubleValue], 0);
        hb_vmDo(2);
      }
    });
  };

  SEL selector = NSSelectorFromString(@"makeSliderWithValue:index:callback:");

  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];

    [invocation setArgument:&nValue
                    atIndex:2]; // Note: makeSlider takes NSNumber, but Swift
                                // side might expect primitive if changed?
    // Wait, Swift `makeSlider(value: NSNumber, ...)`
    // In NSInvocation, if arg is object, we pass pointer to object.
    // `nValue` is double. We should create NSNumber.
    NSNumber *numVal = @(nValue);
    [invocation setArgument:&numVal atIndex:2];

    [invocation setArgument:&nIndex atIndex:3];
    [invocation setArgument:&callbackBlock atIndex:4];

    [invocation invoke];

    NSView *sliderView;
    [invocation getReturnValue:&sliderView];

    if (sliderView) {
      setupSwiftView(sliderView, window, nTop, nLeft, nWidth, nHeight);
      hb_retnl((HB_LONG)sliderView);
    }
  }
}
