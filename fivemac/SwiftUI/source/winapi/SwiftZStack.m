
#include <fivemac.h>

static NSString *GetRootIdFromParam(int paramIndex) {
  if (HB_ISNUM(paramIndex)) {
    return [NSString stringWithFormat:@"%d", hb_parni(paramIndex)];
  } else {
    return hb_NSSTRING_par(paramIndex);
  }
}

HB_FUNC(SWIFTZSTACKCREATE) {
  NSWindow *window = (NSWindow *)hb_parnl(1);
  NSString *cId = nil;
  int nIndex = 0;

  if (HB_ISNUM(2)) {
    nIndex = hb_parni(2);
    cId = [NSString stringWithFormat:@"%d", nIndex];
  } else if (HB_ISCHAR(2)) {
    cId = hb_NSSTRING_par(2);
    nIndex = [cId intValue];
  }

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
      if (!itemId)
        return;

      PHB_DYNS pSym = hb_dynsymFindName("SWIFTONACTION");
      if (pSym) {
        const char *cStr = [itemId UTF8String];
        NSUInteger len =
            [itemId lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

        hb_vmPushSymbol(hb_dynsymSymbol(pSym));
        hb_vmPushNil();
        hb_vmPushLong((HB_LONG)nIndex);
        hb_vmPushString(cStr, (HB_SIZE)len);
        hb_vmDo(2);
      }
    };

    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    [invocation setArgument:&cId atIndex:2];
    [invocation setArgument:&actionCallback atIndex:3];
    [invocation retainArguments];

    [invocation invoke];

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

HB_FUNC(SWIFTZSTACKADDITEM) { // (rootId, text)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *text = hb_NSSTRING_par(2);
  NSString *className = @"SwiftFive.SwiftZStackLoader";
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
      hb_retc([itemId UTF8String]);
    }
  }
}

HB_FUNC(SWIFTZSTACKADDIMAGE) { // (rootId, name)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *name = hb_NSSTRING_par(2);
  NSString *className = @"SwiftFive.SwiftZStackLoader";
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
      hb_retc([itemId UTF8String]);
    }
  }
}

HB_FUNC(SWIFTZSTACKADDFILEIMAGE) { // (rootId, path)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *path = hb_NSSTRING_par(2);
  NSString *className = @"SwiftFive.SwiftZStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addFileImage:filePath:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    if (signature) {
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&path atIndex:3];
      [invocation invoke];

      NSString *itemId;
      [invocation getReturnValue:&itemId];
      hb_retc([itemId UTF8String]);
    }
  }
}

// Nesting Bridges needing return ID
HB_FUNC(SWIFTZSTACKADDVSTACKCONTAINER) { // (rootId, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *parentId = hb_parvc(2) ? hb_NSSTRING_par(2) : nil;

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

HB_FUNC(SWIFTZSTACKADDHSTACKCONTAINER) { // (rootId, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *parentId = hb_parvc(2) ? hb_NSSTRING_par(2) : nil;
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addHStackContainer:dummy:parentId:);
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

HB_FUNC(SWIFTZSTACKADDTEXTTO) { // (rootId, text, parentId)
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

      NSString *retId;
      [invocation getReturnValue:&retId];
      hb_retc([retId UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

HB_FUNC(SWIFTZSTACKADDSPACER) { // (rootId, parentId)
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

HB_FUNC(SWIFTZSTACKADDDIVIDER) { // (rootId, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *parentId = hb_parvc(2) ? hb_NSSTRING_par(2) : nil;
  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addDivider:dummy:parentId:);
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
    }
  }
}

HB_FUNC(SWIFTZSTACKSETALIGNMENT) { // (rootId, nAlign)
  NSString *rootId = GetRootIdFromParam(1);
  NSInteger nAlign = hb_parni(2);
  NSString *className = @"SwiftFive.SwiftZStackLoader";
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

HB_FUNC(SWIFTZSTACKSETBGCOLOR) { // (rootId, r, g, b, a)
  NSString *rootId = GetRootIdFromParam(1);
  double red = hb_parnd(2);
  double green = hb_parnd(3);
  double blue = hb_parnd(4);
  double alpha = hb_parnd(5);

  NSString *className = @"SwiftFive.SwiftZStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setBackgroundColor:red:green:blue:alpha:);
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

HB_FUNC(SWIFTZSTACKSETFGCOLOR) { // (rootId, r, g, b, a)
  NSString *rootId = GetRootIdFromParam(1);
  double red = hb_parnd(2);
  double green = hb_parnd(3);
  double blue = hb_parnd(4);
  double alpha = hb_parnd(5);

  NSString *className = @"SwiftFive.SwiftZStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setForegroundColor:red:green:blue:alpha:);
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

HB_FUNC(SWIFTZSTACKREMOVEALLITEMS) { // (rootId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *className = @"SwiftFive.SwiftZStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(removeAllItems:);
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation setArgument:&rootId atIndex:2];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTZSTACKSETITEMBGCOLOR) { // (rootId, itemId, r, g, b, a)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *itemId = hb_NSSTRING_par(2);
  double red = hb_parnd(3);
  double green = hb_parnd(4);
  double blue = hb_parnd(5);
  double alpha = hb_parnd(6);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(setItem:id:red:green:blue:alpha:);
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&itemId atIndex:3];
      [invocation setArgument:&red atIndex:4];
      [invocation setArgument:&green atIndex:5];
      [invocation setArgument:&blue atIndex:6];
      [invocation setArgument:&alpha atIndex:7];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTZSTACKADDLAZYVGRID) { // (rootId, parentId, columnsJson)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *parentId = hb_parvc(2) ? hb_NSSTRING_par(2) : nil;
  NSString *columnsJson = hb_NSSTRING_par(3);

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addLazyVGrid:parentId:columnsJson:);

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

      NSString *resId;
      [invocation getReturnValue:&resId];
      hb_retc([resId UTF8String]);
      return;
    }
  }
  hb_retc("");
}

HB_FUNC(SWIFTZSTACKADDLIST) { // (rootId, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *parentId = hb_parvc(2) ? hb_NSSTRING_par(2) : nil;
  NSString *dummy = @"";

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

HB_FUNC(SWIFTZSTACKADDSYSTEMIMAGETO) { // (rootId, systemName, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *systemName = hb_NSSTRING_par(2);
  NSString *parentId = hb_parvc(3) ? hb_NSSTRING_par(3) : nil;

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addSystemImageItem:systemName:parentId:);

    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&rootId atIndex:2];
      [invocation setArgument:&systemName atIndex:3];
      [invocation setArgument:&parentId atIndex:4];

      [invocation invoke];

      NSString *resId;
      [invocation getReturnValue:&resId];
      hb_retc([resId UTF8String]);
    }
  }
}

HB_FUNC(SWIFTZSTACKADDBUTTONTO) { // (rootId, text, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *text = hb_NSSTRING_par(2);
  NSString *parentId = hb_parvc(3) ? hb_NSSTRING_par(3) : nil;

  NSString *className = @"SwiftFive.SwiftVStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addButtonItem:text:parentId:);

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

HB_FUNC(SWIFTZSTACKADDBATCH) { // (rootId, json, parentId)
  NSString *rootId = GetRootIdFromParam(1);
  NSString *json = [NSString stringWithUTF8String:hb_parc(2)];
  NSString *parentId =
      hb_parvc(3) ? [NSString stringWithUTF8String:hb_parvc(3)] : nil;

  NSString *className = @"SwiftFive.SwiftZStackLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(addBatch:parentId:json:);
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
