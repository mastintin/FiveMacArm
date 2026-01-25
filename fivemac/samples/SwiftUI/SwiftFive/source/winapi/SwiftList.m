#include <fivemac.h>

HB_FUNC(SWIFTLISTCREATE) {
  NSWindow *window = (NSWindow *)hb_parnl(1);
  // Support for Hybrid ID (Int or String)
  NSString *cId = nil;
  int nIndex = 0;

  if (HB_ISNUM(2)) {
    nIndex = hb_parni(2);
    cId = [NSString stringWithFormat:@"%d", nIndex];
  } else if (HB_ISCHAR(2)) {
    cId = hb_NSSTRING_par(2);
    nIndex = [cId intValue]; // Try validation
  }

  NSString *className = @"SwiftFive.SwiftListLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(makeListWithIndex:callback:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];

    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    // Pass String ID
    [invocation setArgument:&cId atIndex:2];

    // Callback block for clicks (Legacy index-based)
    // IMPORTANT: Swift Int is NSInteger (64-bit), not int (32-bit).
    void (^callback)(NSInteger) = ^(NSInteger index) {
      PHB_DYNS pSym = hb_dynsymFindName("SWIFTLISTONCLICK");
      if (pSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pSym));
        hb_vmPushNil();
        hb_vmPushLong((HB_LONG)nIndex);
        hb_vmPushLong((HB_LONG)index);
        hb_vmDo(2);
      }
    };

    [invocation setArgument:&callback atIndex:3];
    [invocation retainArguments];

    [invocation invoke];

    // Setup Action Callback (Using SwiftVStackLoader as context)
    NSString *vstackClassName = @"SwiftFive.SwiftVStackLoader";
    Class vstackClass = NSClassFromString(vstackClassName);
    if (vstackClass) {
      void (^actionCallbackBlock)(NSString *itemId) = ^(NSString *itemId) {
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

      SEL actionSelector = @selector(setActionCallback:callback:);
      if ([vstackClass respondsToSelector:actionSelector]) {
        NSMethodSignature *actionSig =
            [vstackClass methodSignatureForSelector:actionSelector];
        NSInvocation *actionInv =
            [NSInvocation invocationWithMethodSignature:actionSig];
        [actionInv setSelector:actionSelector];
        [actionInv setTarget:vstackClass];
        // ARG 2: Root ID
        [actionInv setArgument:&cId atIndex:2];
        // ARG 3: Callback
        [actionInv setArgument:&actionCallbackBlock atIndex:3];
        [actionInv invoke];
      }
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

HB_FUNC(SWIFTLISTSELECTINDEX) {
  NSString *id = [NSString stringWithFormat:@"%ld", (long)hb_parnl(1)];
  int index = hb_parni(2);

  Class cls = NSClassFromString(@"SwiftFive.SwiftListLoader");
  if (cls) {
    // signature: selectIndex:index:
    SEL selector = @selector(selectIndex:index:);
    if ([cls respondsToSelector:selector]) {
      NSMethodSignature *signature = [cls methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:cls];
      [invocation setArgument:&id atIndex:2];
      [invocation setArgument:&index atIndex:3];
      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTLISTSETBGCOLOR) { // (rootId, r, g, b, a)
  NSString *rootId = [NSString stringWithFormat:@"%ld", (long)hb_parnl(1)];
  double red = hb_parnd(2);
  double green = hb_parnd(3);
  double blue = hb_parnd(4);
  double alpha = hb_parnd(5);

  NSString *className = @"SwiftFive.SwiftListLoader";
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
