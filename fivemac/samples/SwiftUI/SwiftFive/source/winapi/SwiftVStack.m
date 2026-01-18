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

    // Setup Action Callback
    void (^actionCallbackBlock)(NSString *) = ^(NSString *itemId) {
      // NSLog(@"DEBUG: [ObjC] Callback Block Entered. itemID: '%@'", itemId);

      if (!itemId) {
        // NSLog(@"DEBUG: [ObjC] itemID is nil! Aborting callback.");
        return;
      }

      const char *cStr = [itemId UTF8String];
      NSUInteger len = [itemId lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
      // NSLog(@"DEBUG: [ObjC] UTF8String: %p, Length: %lu", cStr, (unsigned
      // long)len);

      PHB_DYNS pSym = hb_dynsymFindName("SWIFTONACTION");
      if (pSym) {
        // NSLog(@"DEBUG: [ObjC] Symbol Found. Pushing params...");
        hb_vmPushSymbol(hb_dynsymSymbol(pSym));
        hb_vmPushNil();
        hb_vmPushLong(nIndex);
        // Use explicit length to be safe
        hb_vmPushString(cStr, (HB_SIZE)len);
        // NSLog(@"DEBUG: [ObjC] Params pushed. Calling vmDo...");
        hb_vmDo(2);
        // NSLog(@"DEBUG: [ObjC] vmDo returned.");
      } else {
        NSLog(@"CRITICAL ERROR: SWIFTONACTION symbol not found in Harbour!");
      }
    };

    SEL actionSelector = @selector(setActionCallback:);
    if ([swiftClass respondsToSelector:actionSelector]) {
      NSMethodSignature *actionSig =
          [swiftClass methodSignatureForSelector:actionSelector];
      NSInvocation *actionInv =
          [NSInvocation invocationWithMethodSignature:actionSig];
      [actionInv setSelector:actionSelector];
      [actionInv setTarget:swiftClass];
      [actionInv setArgument:&actionCallbackBlock atIndex:2];
      [actionInv invoke];
    }

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

HB_FUNC(SWIFTVSTACKADDBUTTON) {
  NSString *text = hb_NSSTRING_par(1);
  NSString *parentId = nil; // Root

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addButtonItem:parentId:);

    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&text atIndex:2];
      [invocation setArgument:&parentId atIndex:3];

      [invocation invoke];

      // Capture the return value (NSString item ID)
      __unsafe_unretained NSString *retVal = nil;
      [invocation getReturnValue:&retVal];

      if (retVal) {
        // NSLog(@"DEBUG: [ObjC] addButtonItem returned ID: %@", retVal);
        hb_retc([retVal UTF8String]);
      } else {
        // NSLog(@"DEBUG: [ObjC] addButtonItem returned nil!");
        hb_retc("");
      }
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

HB_FUNC(SWIFTSETID) {
  const char *cId = hb_parc(1);
  if (cId) {
    NSString *idStr = [NSString stringWithUTF8String:cId];
    NSString *className = @"SwiftFive.SwiftVStackLoader";
    Class swiftClass = NSClassFromString(className);
    if (swiftClass) {
      SEL selector = @selector(setLastItemId:);
      if ([swiftClass respondsToSelector:selector]) {
        NSMethodSignature *signature =
            [swiftClass methodSignatureForSelector:selector];
        NSInvocation *invocation =
            [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setTarget:swiftClass];
        [invocation setArgument:&idStr atIndex:2];
        [invocation invoke];
      }
    }
  }
}

HB_FUNC(SWIFTVSTACKADDHSTACKCONTAINER) {
  NSString *parentId = hb_NSSTRING_par(1);
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addHStackContainer:parentId:);
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      NSString *dummy = @"";
      [invocation setArgument:&dummy atIndex:2];
      [invocation setArgument:&parentId atIndex:3];

      [invocation invoke];

      // Return the ID
      __unsafe_unretained NSString *retVal = nil;
      [invocation getReturnValue:&retVal];
      hb_retc([retVal UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

HB_FUNC(SWIFTVSTACKADDLIST) {
  NSString *parentId = hb_NSSTRING_par(1);
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addList:parentId:);
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      NSString *dummy = @"";
      [invocation setArgument:&dummy atIndex:2];
      [invocation setArgument:&parentId atIndex:3];

      [invocation invoke];

      __unsafe_unretained NSString *retId;
      [invocation getReturnValue:&retId];
      if (retId) {
        hb_retc([retId UTF8String]);
      } else {
        hb_retc("");
      }
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

HB_FUNC(SWIFTVSTACKADDBATCH) {
  NSString *json = [NSString stringWithUTF8String:hb_parc(1)];
  NSString *parentId =
      hb_parvc(2) ? [NSString stringWithUTF8String:hb_parvc(2)] : nil;

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addBatchToParent:json:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&parentId atIndex:2];
      [invocation setArgument:&json atIndex:3];
      [invocation invoke];

      __unsafe_unretained NSString *retId;
      [invocation getReturnValue:&retId];
      if (retId) {
        hb_retc([retId UTF8String]);
      } else {
        hb_retc("[]");
      }
    } else {
      hb_retc("[]");
    }
  } else {
    hb_retc("[]");
  }
}
