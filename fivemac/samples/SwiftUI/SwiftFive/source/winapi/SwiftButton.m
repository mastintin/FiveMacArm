#import "SwiftCommon.h"

HB_FUNC(SWIFTBTNCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSString *cPrompt = hb_NSSTRING_par(5);
  NSWindow *window = (NSWindow *)hb_parnl(6);
  int nIndex = hb_parni(7); // Receive the Index in aSwiftButtons

  // Class name hardcoded or passed? We use specific loader.
  NSString *className = @"SwiftFive.SwiftButtonLoader";
  Class swiftClass = NSClassFromString(className);

  if (!swiftClass) {
    NSLog(@"Error: Could not find class %@", className);
    return;
  }

  // Callback
  void (^callbackBlock)(NSString *) = ^(NSString *msg) {
    dispatch_async(dispatch_get_main_queue(), ^{
      PHB_DYNS pDynSym = hb_dynsymFindName("SWIFTBTNONCLICK");
      if (pDynSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
        hb_vmPushNil();
        hb_vmPushInteger(nIndex);
        hb_vmDo(1);
      }
    });
  };

  NSLog(@"SWIFTBTNCREATE: Top=%f Left=%f Width=%f Height=%f", nTop, nLeft,
        nWidth, nHeight);

  // Call Swift Factory
  // Signature: makeButton(title:index:callback:)
  SEL selector = NSSelectorFromString(@"makeButtonWithTitle:index:callback:");

  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];

    [invocation setArgument:&cPrompt atIndex:2];
    [invocation setArgument:&nIndex atIndex:3];
    [invocation setArgument:&callbackBlock atIndex:4];

    [invocation invoke];

    NSView *btnView;
    [invocation getReturnValue:&btnView];

    if (btnView) {
      NSLog(@"SWIFTBTNCREATE: View created: %@", btnView);
      setupSwiftView(btnView, window, nTop, nLeft, nWidth, nHeight);
      hb_retnl((HB_LONG)btnView);
    } else {
      NSLog(@"SWIFTBTNCREATE: View Creation Failed");
    }
  } else {
    NSLog(@"SWIFTBTNCREATE: Selector not found on class %@", className);
  }
}

// Helper to get hex color string from Harbour numeric color (duplicated from
// SwiftLabel.m refactor candidate)
NSString *HexColorFromHarbour(long nColor) {
  int r = nColor & 0xFF;
  int g = (nColor >> 8) & 0xFF;
  int b = (nColor >> 16) & 0xFF;
  return [NSString stringWithFormat:@"%02X%02X%02X", r, g, b];
}

HB_FUNC(SWIFTBTNSETBGCOLOR) {
  long nColor = hb_parnl(1);
  NSString *hexColor = HexColorFromHarbour(nColor);

  NSString *className = @"SwiftFive.SwiftButtonLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass &&
      [swiftClass respondsToSelector:@selector(setButtonBackgroundColor:)]) {
    [swiftClass performSelector:@selector(setButtonBackgroundColor:)
                     withObject:hexColor];
  }
}

HB_FUNC(SWIFTBTNSETFGCOLOR) {
  long nColor = hb_parnl(1);
  NSString *hexColor = HexColorFromHarbour(nColor);

  NSString *className = @"SwiftFive.SwiftButtonLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass &&
      [swiftClass respondsToSelector:@selector(setButtonForegroundColor:)]) {
    [swiftClass performSelector:@selector(setButtonForegroundColor:)
                     withObject:hexColor];
  }
}

HB_FUNC(SWIFTBTNSETRADIUS) {
  double nRadius = hb_parnd(1);

  NSString *className = @"SwiftFive.SwiftButtonLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass &&
      [swiftClass respondsToSelector:@selector(setButtonCornerRadius:)]) {
    [swiftClass performSelector:@selector(setButtonCornerRadius:)
                     withObject:[NSNumber numberWithDouble:nRadius]];
  }
}

HB_FUNC(SWIFTBTNSETPADDING) {
  double nPadding = hb_parnd(1);

  NSString *className = @"SwiftFive.SwiftButtonLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass &&
      [swiftClass respondsToSelector:@selector(setButtonPadding:)]) {
    [swiftClass performSelector:@selector(setButtonPadding:)
                     withObject:[NSNumber numberWithDouble:nPadding]];
  }
}
