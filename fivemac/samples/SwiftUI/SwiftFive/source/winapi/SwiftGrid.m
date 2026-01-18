#include <fivemac.h>

HB_FUNC(SWIFTGRIDCREATE) {
  NSWindow *window = (NSWindow *)hb_parnl(1);
  int nIndex = hb_parni(2);
  NSString *columnsJson = hb_NSSTRING_par(7); // After x,y,w,h

  NSString *className = @"SwiftFive.SwiftGridLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = @selector(makeGridWithIndex:
                                   columnsJson:callback:actionCallback:);
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];

    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    [invocation setArgument:&nIndex atIndex:2];
    [invocation setArgument:&columnsJson atIndex:3];

    // Callback block for clicks
    void (^callback)(NSInteger) = ^(NSInteger index) {
      dispatch_async(dispatch_get_main_queue(), ^{
        PHB_DYNS pSym = hb_dynsymFindName("SWIFTGRIDONCLICK");
        if (pSym) {
          hb_vmPushSymbol(hb_dynsymSymbol(pSym));
          hb_vmPushNil();
          hb_vmPushLong((HB_LONG)nIndex);
          hb_vmPushLong((HB_LONG)index);
          hb_vmDo(2);
        } else {
          NSLog(@"FiveMac Error: Symbol SWIFTGRIDONCLICK not found");
        }
      });
    };

    // Callback block for actions (String IDs)
    void (^actionCallback)(NSString *) = ^(NSString *idStr) {
      const char *cId = [idStr UTF8String];
      // printf("OBJC: Action Callback. ID: %s\n", cId);
      dispatch_async(dispatch_get_main_queue(), ^{
        PHB_DYNS pSym = hb_dynsymFindName("SWIFTGRIDONACTION");
        if (pSym) {
          hb_vmPushSymbol(hb_dynsymSymbol(pSym));
          hb_vmPushNil();
          hb_vmPushLong((HB_LONG)nIndex);
          hb_vmPushString(cId, strlen(cId));
          hb_vmDo(2);
        }
      });
    };

    [invocation setArgument:&callback atIndex:4];
    [invocation setArgument:&actionCallback atIndex:5];
    [invocation retainArguments]; // Important for blocks

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
