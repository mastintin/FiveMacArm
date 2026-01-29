#include <fivemac.h>

HB_FUNC(SWIFTVSTACKCREATE) {
  NSWindow *window = (NSWindow *)hb_parnl(1);
  // Hybrid ID support
  NSString *cId = nil;
  int nIndex = 0;

  if (HB_ISNUM(2)) {
    nIndex = hb_parni(2);
    cId = [NSString stringWithFormat:@"%d", nIndex];
  } else if (HB_ISCHAR(2)) {
    cId = hb_NSSTRING_par(2);
    nIndex = [cId intValue];
  }

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    // Define a block for the callback
    // IMPORTANT: Swift Int is NSInteger (64-bit)
    void (^callbackBlock)(NSInteger) = ^(NSInteger itemIndex) {
      PHB_DYNS pSym = hb_dynsymFindName("SWIFTVSTACKONCLICK");
      if (pSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pSym));
        hb_vmPushNil();
        hb_vmPushLong(nIndex);    // Control Index
        hb_vmPushLong(itemIndex); // Item Index (1-based from Swift)
        hb_vmDo(2);
      }
    };

    NSMethodSignature *signature = [swiftClass
        methodSignatureForSelector:@selector(makeVStackWithIndex:callback:)];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];

    [invocation setSelector:@selector(makeVStackWithIndex:callback:)];
    [invocation setTarget:swiftClass];
    [invocation setArgument:&cId atIndex:2];
    [invocation setArgument:&callbackBlock atIndex:3];

    [invocation invoke];

    // Setup Action Callback
    void (^actionCallbackBlock)(NSString *) = ^(NSString *itemId) {
      if (!itemId)
        return;

      PHB_DYNS pSym = hb_dynsymFindName("SWIFTONACTION");
      if (pSym) {
        const char *cStr = [itemId UTF8String];
        NSUInteger len =
            [itemId lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

        hb_vmPushSymbol(hb_dynsymSymbol(pSym));
        hb_vmPushNil();
        hb_vmPushLong(nIndex);
        hb_vmPushString(cStr, (HB_SIZE)len);
        hb_vmDo(2);
      }
    };

    SEL actionSelector = @selector(setActionCallback:callback:);
    if ([swiftClass respondsToSelector:actionSelector]) {
      NSMethodSignature *actionSig =
          [swiftClass methodSignatureForSelector:actionSelector];
      NSInvocation *actionInv =
          [NSInvocation invocationWithMethodSignature:actionSig];
      [actionInv setSelector:actionSelector];
      [actionInv setTarget:swiftClass];
      [actionInv setArgument:&cId atIndex:2];
      [actionInv setArgument:&actionCallbackBlock atIndex:3];
      [actionInv invoke];
    }

    NSView *view;
    [invocation getReturnValue:&view];

    if (view) {
      [view setFrame:NSMakeRect(hb_parnl(4), hb_parnl(3), hb_parnl(5),
                                hb_parnl(6))];

      id parent = (id)hb_parnl(1);
      if ([parent isKindOfClass:[NSWindow class]]) {
        [[(NSWindow *)parent contentView] addSubview:view];
      } else if ([parent isKindOfClass:[NSView class]]) {
        [(NSView *)parent addSubview:view];
      }
      hb_retnl((HB_LONG)view);
    } else {
      hb_retnl(0);
    }
  } else {
    hb_retnl(0);
  }
}

// Helper to get String param (handling index shift if needed, but here we
// assume fixed args) All subsequent functions assume Param 1 is RootID (String
// or Int converted to String)

NSString *GetRootIdFromParam(int paramIndex) {
  if (HB_ISNUM(paramIndex)) {
    return [NSString stringWithFormat:@"%d", hb_parni(paramIndex)];
  } else {
    return hb_NSSTRING_par(paramIndex);
  }
}

HB_FUNC(SWIFTVSTACKADDITEM) { // (rootId, text)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *text = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    [swiftClass performSelector:@selector(addItem:content:)
                     withObject:rootId
                     withObject:text];
  }
}

HB_FUNC(SWIFTVSTACKADDTEXTTO) { // (rootId, text, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *text = hb_NSSTRING_par(2);
  NSString *parentId = hb_parvc(3) ? hb_NSSTRING_par(3) : nil;

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addTextItem:content:parentId:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&text atIndex:3];
      [invocation setArgument:&parentId atIndex:4];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKADDSPACERTO) { // (rootId, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *parentId = hb_parvc(2) ? hb_NSSTRING_par(2) : nil;

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addSpacerItem:parentId:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&parentId atIndex:3];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKADDSYSTEMIMAGETO) { // (rootId, name, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *name = hb_NSSTRING_par(2);
  NSString *parentId = hb_parvc(3) ? hb_NSSTRING_par(3) : nil;

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addSystemImageItem:systemName:parentId:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&name atIndex:3];
      [invocation setArgument:&parentId atIndex:4];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKADDSYSTEMIMAGE) { // (rootId, name)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *name = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addSystemImage:systemName:);
    if ([swiftClass respondsToSelector:selector]) {
      [swiftClass performSelector:selector withObject:rootId withObject:name];
    }
  }
}

HB_FUNC(SWIFTVSTACKADDHSTACK) { // (rootId, imgName, text)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *imgName = hb_NSSTRING_par(2);
  NSString *text = hb_NSSTRING_par(3);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addHStackItem:text:systemName:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];

    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&text atIndex:3];
      [invocation setArgument:&imgName atIndex:4];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETSCROLL) { // (rootId, bScroll)
  NSString *rootId = GetRootIdFromParam(1);
  BOOL bScroll = hb_parl(2);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setScrollable:scrollable:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];

    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&bScroll atIndex:3];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETBGCOLOR) { // (rootId, r, g, b, a)
  NSString *rootId = GetRootIdFromParam(1);
  double red = hb_parnd(2);
  double green = hb_parnd(3);
  double blue = hb_parnd(4);
  double alpha = hb_parnd(5);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setBackgroundColorRed:red:green:blue:alpha:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];

    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&red atIndex:3];
      [invocation setArgument:&green atIndex:4];
      [invocation setArgument:&blue atIndex:5];
      [invocation setArgument:&alpha atIndex:6];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETINVERTEDCOLOR) { // (rootId, bInvert)
  NSString *rootId = GetRootIdFromParam(1);
  BOOL bInvert = hb_parl(2);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setInvertedColor:useInverted:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];

    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&bInvert atIndex:3];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETFGCOLOR) { // (rootId, r, g, b, a)
  NSString *rootId = GetRootIdFromParam(1);
  double red = hb_parnd(2);
  double green = hb_parnd(3);
  double blue = hb_parnd(4);
  double alpha = hb_parnd(5);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setForegroundColorRed:red:green:blue:alpha:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];

    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&red atIndex:3];
      [invocation setArgument:&green atIndex:4];
      [invocation setArgument:&blue atIndex:5];
      [invocation setArgument:&alpha atIndex:6];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETSPACING) { // (rootId, nSpacing)
  NSString *rootId = GetRootIdFromParam(1);
  double nSpacing = hb_parnd(2);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setSpacing:spacing:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&nSpacing atIndex:3];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETALIGNMENT) { // (rootId, nAlign)
  NSString *rootId = GetRootIdFromParam(1);
  NSInteger nAlign = hb_parni(2);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setAlignment:alignment:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&nAlign atIndex:3];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKADDBUTTON) { // (rootId, text, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *text = hb_NSSTRING_par(2);
  NSString *parentId =
      hb_parvc(3) ? [NSString stringWithUTF8String:hb_parvc(3)] : nil;

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addButtonItem:text:parentId:); // Updated Selector

    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&text atIndex:3];
      [invocation setArgument:&parentId atIndex:4];

      [invocation invoke];

      __unsafe_unretained NSString *retVal = nil;
      [invocation getReturnValue:&retVal];

      if (retVal) {
        hb_retc([retVal UTF8String]);
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

HB_FUNC(SWIFTSETID) { // (rootId, id)
  NSString *rootId = GetRootIdFromParam(1);
  const char *cId = hb_parc(2);

  if (cId) {
    NSString *idStr = [NSString stringWithUTF8String:cId];
    NSString *className = @"SwiftFive.SwiftVStackLoader";
    Class swiftClass = NSClassFromString(className);
    if (swiftClass) {
      SEL selector = @selector(setLastItemId:id:);
      if ([swiftClass respondsToSelector:selector]) {
        NSMethodSignature *signature =
            [swiftClass methodSignatureForSelector:selector];
        NSInvocation *invocation =
            [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setTarget:swiftClass];
        [invocation setArgument:&rootId atIndex:2];
        [invocation setArgument:&idStr atIndex:3];
        [invocation invoke];
      }
    }
  }
}

HB_FUNC(SWIFTVSTACKADDHSTACKCONTAINER) { // (rootId, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *parentId = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addHStackContainer:dummy:parentId:);
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      NSString *dummy = @"";
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&dummy atIndex:3];
      [invocation setArgument:&parentId atIndex:4];

      [invocation invoke];

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

HB_FUNC(SWIFTVSTACKADDLIST) { // (rootId, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *parentId = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addList:dummy:parentId:);
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      NSString *dummy = @"";
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&dummy atIndex:3];
      [invocation setArgument:&parentId atIndex:4];

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

HB_FUNC(SWIFTVSTACKADDBATCH) { // (rootId, json, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *json = [NSString stringWithUTF8String:hb_parc(2)];
  NSString *parentId =
      hb_parvc(3) ? [NSString stringWithUTF8String:hb_parvc(3)] : nil;

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector
        (addBatchToParent:
                 parentId:json:); // Order in Swift was root, parent, json?
    // Swift: addBatch(_ rootId: String, parentId: String?, json: String)
    // So usage: rootId, parentId, json

    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&parentId atIndex:3];
      [invocation setArgument:&json atIndex:4];
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

HB_FUNC(SWIFTVSTACKADDSPACER) { // (rootId, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *parentId = hb_parvc(2) ? hb_NSSTRING_par(2) : nil;

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addSpacer:dummy:parentId:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      NSString *dummy = @"";
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&dummy atIndex:3];
      [invocation setArgument:&parentId atIndex:4];
      [invocation invoke];
    }
  }
}
