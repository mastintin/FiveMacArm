#include <fivemac.h>

HB_FUNC(SWIFTVSTACKCREATE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
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
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:@selector(makeVStackWithIndex:)];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];

    [invocation setSelector:@selector(makeVStackWithIndex:)];
    [invocation setTarget:swiftClass];
    [invocation setArgument:&cId atIndex:2];

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
    SEL selector = @selector(addItem:content:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&text atIndex:3];
      [invocation invoke];

      NSString *itemId;
      [invocation getReturnValue:&itemId];
      if (itemId) {
        hb_retc([itemId UTF8String]);
      }
    }
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

      NSString *itemId;
      [invocation getReturnValue:&itemId];
      if (itemId) {
        hb_retc([itemId UTF8String]);
      }
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

      NSString *itemId;
      [invocation getReturnValue:&itemId];
      if (itemId) {
        hb_retc([itemId UTF8String]);
      }
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

      NSString *itemId;
      [invocation getReturnValue:&itemId];
      if (itemId) {
        hb_retc([itemId UTF8String]);
      }
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
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&name atIndex:3];
      [invocation invoke];

      NSString *itemId;
      [invocation getReturnValue:&itemId];
      if (itemId) {
        hb_retc([itemId UTF8String]);
      }
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

      NSString *itemId;
      [invocation getReturnValue:&itemId];
      if (itemId) {
        hb_retc([itemId UTF8String]);
      }
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

HB_FUNC(SWIFTVSTACKADDBUTTONITEM) { // (rootId, text, parentId)
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

      NSString *itemId;
      [invocation getReturnValue:&itemId];
      if (itemId) {
        hb_retc([itemId UTF8String]);
      }
    }
  }
}

HB_FUNC(SWIFTVSTACKSETITEMTEXT) { // (rootId, itemId, text)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *itemId = hb_NSSTRING_par(2);
  NSString *text = hb_NSSTRING_par(3);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setItemTextWithRootId:id:text:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&itemId atIndex:3];
      [invocation setArgument:&text atIndex:4];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETITEMCOLOR) { // (rootId, itemId, r, g, b, a)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *itemId = hb_NSSTRING_par(2);
  CGFloat r = (CGFloat)hb_parnd(3);
  CGFloat g = (CGFloat)hb_parnd(4);
  CGFloat b = (CGFloat)hb_parnd(5);
  CGFloat a = (CGFloat)hb_parnd(6);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setItemColorWithRootId:id:r:g:b:a:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&itemId atIndex:3];
      [invocation setArgument:&r atIndex:4];
      [invocation setArgument:&g atIndex:5];
      [invocation setArgument:&b atIndex:6];
      [invocation setArgument:&a atIndex:7];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETITEMLAYOUT) { // (rootId, itemId, width, height, spacing)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *itemId = hb_NSSTRING_par(2);
  double width = hb_parnd(3);
  double height = hb_parnd(4);
  double spacing = hb_parnd(5);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setItemLayout:id:w:h:s:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&itemId atIndex:3];
      [invocation setArgument:&width atIndex:4];
      [invocation setArgument:&height atIndex:5];
      [invocation setArgument:&spacing atIndex:6];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKSETITEMFONT) {
  NSString *rootId = GetRootIdFromParam(1);
  NSString *itemId = hb_NSSTRING_par(2);
  CGFloat size = (CGFloat)hb_parnd(3);
  BOOL isBold = hb_parl(4);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector =
        NSSelectorFromString(@"setItemFontWithRootId:id:size:isBold:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&itemId atIndex:3];
      [invocation setArgument:&size atIndex:4];
      [invocation setArgument:&isBold atIndex:5];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTVSTACKGETLASTITEMID) {
  NSString *rootId = GetRootIdFromParam(1);
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(getLastItemId:);
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
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

HB_FUNC(SWIFTVSTACKADDDIVIDERTO) { // (rootId, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *parentId = hb_parvc(2) ? hb_NSSTRING_par(2) : nil;

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addDivider:dummy:parentId:);
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

      NSString *itemId;
      [invocation getReturnValue:&itemId];
      if (itemId) {
        hb_retc([itemId UTF8String]);
      }
    }
  }
}

HB_FUNC(SWIFTVSTACKSETITEMRADIUS) {
  NSString *rootId = GetRootIdFromParam(1);
  NSString *itemId = hb_NSSTRING_par(2);
  CGFloat radius = (CGFloat)hb_parnd(3);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setItemRadiusWithRootId:id:radius:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&itemId atIndex:3];
      [invocation setArgument:&radius atIndex:4];
      [invocation invoke];
    }
  }
}
HB_FUNC(SWIFTVSTACKADDLAZYVGRID) { // (rootId, parentId, columnsJson)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *parentId = hb_parvc(2) ? hb_NSSTRING_par(2) : nil;
  NSString *columnsJson = hb_NSSTRING_par(3);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"addLazyVGrid:parentId:columnsJson:");

    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&parentId atIndex:3];
      [invocation setArgument:&columnsJson atIndex:4];

      [invocation invoke];

      __unsafe_unretained NSString *retId;
      [invocation getReturnValue:&retId];
      hb_retc([retId UTF8String]);
      return;
    }
  }
  hb_retc("");
}

HB_FUNC(SWIFTVSTACKADDVSTACKITEM) { // (rootId, dummy, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *parentId = hb_parvc(3) ? hb_NSSTRING_par(3) : nil;

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addVStackItem:dummy:parentId:);
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

      NSString *resId;
      [invocation getReturnValue:&resId];
      hb_retc([resId UTF8String]);
      return;
    }
  }
  hb_retc("");
}

HB_FUNC(SWIFTVSTACKADDTEXT) { // Alias for SWIFTVSTACKADDITEM or similar
  HB_FUNC_EXEC(SWIFTVSTACKADDITEM);
}
