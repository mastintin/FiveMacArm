#include <fivemac.h>

HB_FUNC(SWIFTVSTACKCREATE) {
  NSWindow *window = (NSWindow *)hb_parnl(1);
  int nIndex = hb_parni(2);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    // Define a block for the callback
    void (^callbackBlock)(int) = ^(int itemIndex) {
      // Call Harbour function when item is clicked
      hb_vmPushSymbol(hb_dynsymSymbol(hb_dynsymFindName("SWIFTVSTACKONCLICK")));
      hb_vmPushNil();
      hb_vmPushLong(nIndex);    // Control Index
      hb_vmPushLong(itemIndex); // Item Index (1-based from Swift)
      hb_vmDo(2);
    };

    NSMethodSignature *signature = [swiftClass
        methodSignatureForSelector:@selector(makeVStackWithIndex:callback:)];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];

    [invocation setSelector:@selector(makeVStackWithIndex:callback:)];
    [invocation setTarget:swiftClass];
    [invocation setArgument:&nIndex atIndex:2];
    [invocation setArgument:&callbackBlock atIndex:3];

    [invocation invoke];

    NSView *view;
    [invocation getReturnValue:&view];

    if (view) {
      [view setFrame:NSMakeRect(hb_parnl(4), hb_parnl(3), hb_parnl(5),
                                hb_parnl(6))];
      [[window contentView] addSubview:view];
      hb_retnl((HB_LONG)view);
    } else {
      hb_retnl(0);
    }
  } else {
    hb_retnl(0);
  }
}

HB_FUNC(SWIFTVSTACKADDITEM) {
  NSString *text = hb_NSSTRING_par(1);
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    [swiftClass performSelector:@selector(addItem:) withObject:text];
  }
}

HB_FUNC(SWIFTVSTACKADDSYSTEMIMAGE) {
  NSString *name = hb_NSSTRING_par(1);
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    [swiftClass performSelector:@selector(addSystemImage:) withObject:name];
  }
}

HB_FUNC(SWIFTVSTACKADDHSTACK) {
  NSString *text = hb_NSSTRING_par(2);
  NSString *imgName = hb_NSSTRING_par(1);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addHStackItem:systemName:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];

    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&text atIndex:2];
      [invocation setArgument:&imgName atIndex:3];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETSCROLL) {
  BOOL bScroll = hb_parl(1);
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setScrollable:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];

    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&bScroll atIndex:2];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETBGCOLOR) {
  double red = hb_parnd(1);
  double green = hb_parnd(2);
  double blue = hb_parnd(3);
  double alpha = hb_parnd(4);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    // Selector with multiple arguments
    SEL selector = @selector(setBackgroundColorRed:green:blue:alpha:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];

    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&red atIndex:2];
      [invocation setArgument:&green atIndex:3];
      [invocation setArgument:&blue atIndex:4];
      [invocation setArgument:&alpha atIndex:5];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETINVERTEDCOLOR) {
  BOOL bInvert = hb_parl(1);
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setInvertedColor:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];

    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETFGCOLOR) {
  double red = hb_parnd(1);
  double green = hb_parnd(2);
  double blue = hb_parnd(3);
  double alpha = hb_parnd(4);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setForegroundColorRed:green:blue:alpha:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];

    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&red atIndex:2];
      [invocation setArgument:&green atIndex:3];
      [invocation setArgument:&blue atIndex:4];
      [invocation setArgument:&alpha atIndex:5];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETSPACING) {
  double nSpacing = hb_parnd(1);
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setSpacing:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&nSpacing atIndex:2];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETALIGNMENT) {
  NSInteger nAlign = hb_parni(1);
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setAlignment:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&nAlign atIndex:2];
      [invocation invoke];
    }
  }
}
