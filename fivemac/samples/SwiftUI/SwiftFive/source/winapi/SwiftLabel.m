#import "SwiftCommon.h"

HB_FUNC(SWIFTUPDATELABEL) {
  NSString *className = hb_NSSTRING_par(1);
  NSString *text = hb_NSSTRING_par(2);
  NSInteger nIndex = (NSInteger)hb_parni(3);

  NSLog(@"SWIFTUPDATELABEL: Class=%@ Text=%@ Index=%ld", className, text,
        (long)nIndex);

  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"updateLabel:index:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&text atIndex:2];
      [invocation setArgument:&nIndex atIndex:3];

      [invocation invoke];
    } else {
      NSLog(
          @"SWIFTUPDATELABEL: Class %@ does NOT respond to updateLabel:index:",
          className);
    }
  } else {
    NSLog(@"SWIFTUPDATELABEL: Class %@ NOT found", className);
  }
}

HB_FUNC(SWIFTLABELCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSString *cText = hb_NSSTRING_par(5);
  NSWindow *window = (NSWindow *)hb_parnl(6);

  NSString *className = @"SwiftFive.SwiftLabelLoader";
  Class swiftClass = NSClassFromString(className);

  if (!swiftClass) {
    NSLog(@"Error: Could not find class %@", className);
    return;
  }

  NSLog(@"Debug: Found class %@. Checking for makeLabelWithText:", className);

  SEL selector = NSSelectorFromString(@"makeLabelWithText:index:");

  if ([swiftClass respondsToSelector:selector]) { // Check specific selector
    NSLog(@"Debug: Class responds to selector. Calling it...");

    // NSInvocation needed for int arg
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];

    NSInteger nIndex =
        (NSInteger)hb_parni(7); // Get index for Label (Added in PRG)

    NSLog(@"SWIFTLABELCREATE: Calling makeLabelWithText: Text=%@ Index=%ld",
          cText, (long)nIndex);

    [invocation setArgument:&cText atIndex:2];
    [invocation setArgument:&nIndex atIndex:3];

    [invocation invoke];

    NSView *labelView;
    [invocation getReturnValue:&labelView];

    if (labelView) {
      NSLog(@"Debug: makeLabelWithText returned a valid view: %@", labelView);
      setupSwiftView(labelView, window, nTop, nLeft, nWidth, nHeight);
      hb_retnl((HB_LONG)labelView);
    }
  }
}

HB_FUNC(SWIFTLABELSETFONT) {
  double nSize = hb_parnd(1);
  NSInteger nIndex = (NSInteger)hb_parni(2);

  NSString *className = @"SwiftFive.SwiftLabelLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setLabelFontSize:index:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      NSNumber *numSize = [NSNumber numberWithDouble:nSize];
      [invocation setArgument:&numSize atIndex:2];
      [invocation setArgument:&nIndex atIndex:3];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTLABELSETCOLOR) {
  long nColor = hb_parnl(1);
  NSInteger nIndex = (NSInteger)hb_parni(2);

  // Harbour Color is R + (G * 256) + (B * 65536)
  int r = nColor & 0xFF;
  int g = (nColor >> 8) & 0xFF;
  int b = (nColor >> 16) & 0xFF;

  NSString *hexColor = [NSString stringWithFormat:@"%02X%02X%02X", r, g, b];

  NSString *className = @"SwiftFive.SwiftLabelLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setLabelTextColor:index:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&hexColor atIndex:2];
      [invocation setArgument:&nIndex atIndex:3];

      [invocation invoke];
    }
  }
}
