#include <fivemac.h>

HB_FUNC(SWIFTLISTCREATE) {
  NSWindow *window = (NSWindow *)hb_parnl(1);
  int nIndex = hb_parni(2);

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
    [invocation setArgument:&nIndex atIndex:2];

    // Callback block for clicks (Legacy index-based)
    void (^callback)(int) = ^(int index) {
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

      SEL actionSelector = @selector(setActionCallback:);
      if ([vstackClass respondsToSelector:actionSelector]) {
        NSMethodSignature *actionSig =
            [vstackClass methodSignatureForSelector:actionSelector];
        NSInvocation *actionInv =
            [NSInvocation invocationWithMethodSignature:actionSig];
        [actionInv setSelector:actionSelector];
        [actionInv setTarget:vstackClass];
        [actionInv setArgument:&actionCallbackBlock atIndex:2];
        [actionInv invoke];
      }
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
