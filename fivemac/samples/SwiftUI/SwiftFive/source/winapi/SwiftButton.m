#import "SwiftCommon.h"

HB_FUNC(SWIFTBTNCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSString *cPrompt = hb_NSSTRING_par(5);
  NSWindow *window = (NSWindow *)hb_parnl(6);
  NSInteger nIndex =
      (NSInteger)hb_parni(7); // Receive the Index in aSwiftButtons

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
        hb_vmPushInteger((int)nIndex);
        hb_vmDo(1);
      }
    });
  };

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
      // setupSwiftView(btnView, window, nTop, nLeft, nWidth, nHeight);
      [btnView setFrame:NSMakeRect(nLeft, nTop, nWidth, nHeight)];

      id parent = (id)hb_parnl(6);
      if ([parent isKindOfClass:[NSWindow class]]) {
        [[(NSWindow *)parent contentView] addSubview:btnView];
      } else if ([parent isKindOfClass:[NSView class]]) {
        [(NSView *)parent addSubview:btnView];
      }
      hb_retnll((HB_LONGLONG)btnView);
    }
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
  NSInteger nIndex = (NSInteger)hb_parni(2);
  NSString *hexColor = HexColorFromHarbour(nColor);

  NSString *className = @"SwiftFive.SwiftButtonLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setButtonBackgroundColor:index:");
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

HB_FUNC(SWIFTBTNSETFGCOLOR) {
  long nColor = hb_parnl(1);
  NSInteger nIndex = (NSInteger)hb_parni(2);
  NSString *hexColor = HexColorFromHarbour(nColor);

  NSString *className = @"SwiftFive.SwiftButtonLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setButtonForegroundColor:index:");
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

HB_FUNC(SWIFTBTNSETRADIUS) {
  double nRadius = hb_parnd(1);
  NSInteger nIndex = (NSInteger)hb_parni(2);

  NSString *className = @"SwiftFive.SwiftButtonLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setButtonCornerRadius:index:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      NSNumber *numRad = [NSNumber numberWithDouble:nRadius];
      [invocation setArgument:&numRad atIndex:2];
      [invocation setArgument:&nIndex atIndex:3];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTBTNSETPADDING) {
  double nPadding = hb_parnd(1);
  NSInteger nIndex = (NSInteger)hb_parni(2);

  NSString *className = @"SwiftFive.SwiftButtonLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setButtonPadding:index:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      NSNumber *numPad = [NSNumber numberWithDouble:nPadding];
      [invocation setArgument:&numPad atIndex:2];
      [invocation setArgument:&nIndex atIndex:3];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTBTNSETGLASS) {
  BOOL isGlass = hb_parl(1);
  NSInteger nIndex = (NSInteger)hb_parni(2);

  NSString *className = @"SwiftFive.SwiftButtonLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setButtonGlass:index:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&nIndex atIndex:3];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTBTNSETIMAGE) {
  const char *cImage = hb_parc(1);
  NSInteger nIndex = (NSInteger)hb_parni(2);

  if (!cImage)
    return;
  NSString *imageName = [NSString stringWithUTF8String:cImage];

  NSString *className = @"SwiftFive.SwiftButtonLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setButtonImage:index:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&imageName atIndex:2];
      [invocation setArgument:&nIndex atIndex:3];

      [invocation invoke];
    }
  }
}
