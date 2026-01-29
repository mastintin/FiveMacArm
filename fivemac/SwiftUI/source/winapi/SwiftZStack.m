
#include <fivemac.h>

HB_FUNC(SWIFTZSTACKCREATE) {
  NSWindow *window = (NSWindow *)hb_parnl(1);
  int nIndex = hb_parni(2);

  NSString *className = @"SwiftFive.SwiftZStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(makeZStackWithIndex:actionCallback:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];

    // Callback block for actions
    void (^actionCallback)(NSString *) = ^(NSString *itemId) {
      // NSLog(@"DEBUG: [ObjC-ZStack] Callback Block Entered. itemID: '%@'",
      // itemId);

      if (!itemId) {
        // NSLog(@"DEBUG: [ObjC-ZStack] itemID is nil! Aborting callback.");
        return;
      }

      const char *cStr = [itemId UTF8String];
      NSUInteger len = [itemId lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

      PHB_DYNS pSym = hb_dynsymFindName("SWIFTONACTION");
      if (pSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pSym));
        hb_vmPushNil();
        hb_vmPushLong((HB_LONG)nIndex);
        hb_vmPushString(cStr, (HB_SIZE)len);
        hb_vmDo(2);
      } else {
        NSLog(@"CRITICAL ERROR: SWIFTONACTION symbol not found in Harbour!");
      }
    };

    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    [invocation setArgument:&nIndex atIndex:2];
    [invocation setArgument:&actionCallback atIndex:3];
    [invocation retainArguments];

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

HB_FUNC(SWIFTZSTACKADDITEM) {
  NSString *text = hb_NSSTRING_par(1);
  NSString *className = @"SwiftFive.SwiftZStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    [swiftClass performSelector:@selector(addItem:) withObject:text];
  }
}

HB_FUNC(SWIFTZSTACKADDIMAGE) {
  NSString *name = hb_NSSTRING_par(1);
  NSString *className = @"SwiftFive.SwiftZStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    [swiftClass performSelector:@selector(addSystemImage:) withObject:name];
  }
}

HB_FUNC(SWIFTZSTACKADDFILEIMAGE) {
  NSString *path = hb_NSSTRING_par(1);
  NSString *className = @"SwiftFive.SwiftZStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    [swiftClass performSelector:@selector(addFileImage:) withObject:path];
  }
}

// Nesting Bridges needing return ID
HB_FUNC(SWIFTZSTACKADDVSTACKCONTAINER) {
  NSString *parentId = hb_NSSTRING_par(1); // Optional parent ID
  NSString *className =
      @"SwiftFive.SwiftVStackLoader"; // Function logic in VStackLoader
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    // Selector addVStackItem:parentId:
    SEL selector = @selector(addVStackItem:parentId:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      NSString *dummy = @"";
      [invocation setArgument:&dummy atIndex:2];
      [invocation setArgument:&parentId atIndex:3];

      [invocation invoke];

      NSString *resId;
      [invocation getReturnValue:&resId];

      hb_retc([resId UTF8String]);
      return;
    }
  }
  hb_retc("");
}

HB_FUNC(SWIFTZSTACKADDHSTACKCONTAINER) {
  NSString *parentId = hb_NSSTRING_par(1);
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addHStackContainer:parentId:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      NSString *dummy = @"";
      [invocation setArgument:&dummy atIndex:2];
      [invocation setArgument:&parentId atIndex:3];

      [invocation invoke];

      NSString *resId;
      [invocation getReturnValue:&resId];

      hb_retc([resId UTF8String]);
      return;
    }
  }
  hb_retc("");
}

HB_FUNC(SWIFTZSTACKADDTEXTTO) {
  NSString *text = hb_NSSTRING_par(1);
  NSString *parentId = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addTextItem:parentId:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&text atIndex:2];
      [invocation setArgument:&parentId atIndex:3];

      [invocation invoke];

      NSString *retId;
      [invocation getReturnValue:&retId];
      if (retId) {
        // NSLog(@"DEBUG: [ObjC] AddButtonTo returned ID: '%@'", retId);
        hb_retc([retId UTF8String]);
      } else {
        // NSLog(@"DEBUG: [ObjC] AddButtonTo returned NIL!");
        hb_retc("");
      }
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

HB_FUNC(SWIFTZSTACKADDSPACER) {
  NSString *parentId = hb_NSSTRING_par(1);
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addSpacer:parentId:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      NSString *dummy = @"";
      [invocation setArgument:&dummy atIndex:2];
      [invocation setArgument:&parentId atIndex:3];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTZSTACKADDDIVIDER) {
  NSString *parentId = hb_NSSTRING_par(1);
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addDivider:parentId:);
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
    }
  }
}

HB_FUNC(SWIFTZSTACKSETALIGNMENT) {
  NSInteger nAlign = hb_parni(1);
  NSString *className = @"SwiftFive.SwiftZStackLoader";
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

HB_FUNC(SWIFTZSTACKSETBGCOLOR) {
  double red = hb_parnd(1);
  double green = hb_parnd(2);
  double blue = hb_parnd(3);
  double alpha = hb_parnd(4);

  NSString *className = @"SwiftFive.SwiftZStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
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

HB_FUNC(SWIFTZSTACKSETFGCOLOR) {
  double red = hb_parnd(1);
  double green = hb_parnd(2);
  double blue = hb_parnd(3);
  double alpha = hb_parnd(4);

  NSString *className = @"SwiftFive.SwiftZStackLoader";
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

HB_FUNC(SWIFTZSTACKREMOVEALLITEMS) {
  NSString *className = @"SwiftFive.SwiftZStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"removeAllItems");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTZSTACKSETITEMBGCOLOR) {
  NSString *itemId = hb_NSSTRING_par(1);
  double red = hb_parnd(2);
  double green = hb_parnd(3);
  double blue = hb_parnd(4);
  double alpha = hb_parnd(5);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setItemBackgroundColorWithId:
                                                      red:green:blue:alpha:);
    // Bridging note: Swift method signature handling
    selector = @selector(setItem:backgroundColorRed:green:blue:alpha:);

    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&itemId atIndex:2];
      [invocation setArgument:&red atIndex:3];
      [invocation setArgument:&green atIndex:4];
      [invocation setArgument:&blue atIndex:5];
      [invocation setArgument:&alpha atIndex:6];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTZSTACKADDLAZYVGRID) {
  NSString *parentId = hb_NSSTRING_par(1);
  NSString *columnsJson = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addLazyVGrid:columnsJson:);

    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&parentId atIndex:2];
      [invocation setArgument:&columnsJson atIndex:3];

      [invocation invoke];

      NSString *resId;
      [invocation getReturnValue:&resId];
      hb_retc([resId UTF8String]);
      return;
    }
  }
  hb_retc("");
}

HB_FUNC(SWIFTZSTACKADDLIST) {
  NSString *parentId = hb_NSSTRING_par(1);
  NSString *dummy = @"";

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

      [invocation setArgument:&dummy atIndex:2];
      [invocation setArgument:&parentId atIndex:3];

      [invocation invoke];

      NSString *resId;
      [invocation getReturnValue:&resId];
      hb_retc([resId UTF8String]);
      return;
    }
  }
  hb_retc("");
}

HB_FUNC(SWIFTZSTACKADDSYSTEMIMAGETO) {
  NSString *systemName = hb_NSSTRING_par(1);
  NSString *parentId = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addSystemImageItem:parentId:);

    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&systemName atIndex:2];
      [invocation setArgument:&parentId atIndex:3];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTZSTACKADDBUTTONTO) {
  NSString *text = hb_NSSTRING_par(1);
  NSString *parentId = hb_NSSTRING_par(2);

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

      NSString *retId;
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

HB_FUNC(SWIFTZSTACKADDBATCH) {
  NSString *json = [NSString stringWithUTF8String:hb_parc(1)];
  NSString *parentId =
      hb_parvc(2) ? [NSString stringWithUTF8String:hb_parvc(2)] : nil;

  NSString *className = @"SwiftFive.SwiftZStackLoader";
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
