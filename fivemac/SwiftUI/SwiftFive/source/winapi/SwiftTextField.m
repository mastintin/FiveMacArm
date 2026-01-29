#import "SwiftCommon.h"

HB_FUNC(SWIFTTEXTFIELDCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSString *cText = hb_NSSTRING_par(5);
  NSString *cPlaceholder = hb_NSSTRING_par(6);
  NSWindow *window = (NSWindow *)hb_parnl(7);
  NSInteger nIndex = (NSInteger)hb_parni(8);
  NSString *cId = hb_NSSTRING_par(9);

  NSString *className = @"SwiftTextFieldLoader";
  Class swiftClass = NSClassFromString(className);

  if (!swiftClass) {
    className = @"SwiftFive.SwiftTextFieldLoader";
    swiftClass = NSClassFromString(className);
  }

  if (!swiftClass) {
    NSLog(@"Error: Could not find class SwiftTextFieldLoader");
    return;
  }

  NSLog(@"SWIFTTEXTFIELDCREATE: nIndex=%ld Text=%@ at %f,%f", (long)nIndex,
        cText, nTop, nLeft);

  // Callback for text changes
  void (^callbackBlock)(NSString *) = ^(NSString *newText) {
    dispatch_async(dispatch_get_main_queue(), ^{
      PHB_DYNS pDynSym = hb_dynsymFindName("SWIFTTEXTFIELDONCHANGE");
      if (pDynSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
        hb_vmPushNil();
        hb_vmPushInteger(nIndex);
        const char *utf8Text = [newText UTF8String];
        hb_vmPushString(utf8Text, strlen(utf8Text));
        hb_vmDo(2);
      }
    });
  };

  SEL selector = NSSelectorFromString(
      @"makeTextFieldWithText:placeholder:id:index:callback:");

  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];

    [invocation setArgument:&cText atIndex:2];
    [invocation setArgument:&cPlaceholder atIndex:3];
    [invocation setArgument:&cId atIndex:4];
    [invocation setArgument:&nIndex atIndex:5];
    [invocation setArgument:&callbackBlock atIndex:6];

    [invocation invoke];

    NSView *fieldView;
    [invocation getReturnValue:&fieldView];

    if (fieldView) {
      setupSwiftView(fieldView, window, nTop, nLeft, nWidth, nHeight);
      hb_retnl((HB_LONG)fieldView);
    }
  }
}

HB_FUNC(SWIFTTEXTFIELDSETTEXT) {
  NSInteger nIndex = (NSInteger)hb_parni(1);
  NSString *cText = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftTextFieldLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setText:index:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&cText atIndex:2];
      [invocation setArgument:&nIndex atIndex:3];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTTEXTFIELDGETTEXT) {
  NSInteger nIndex = (NSInteger)hb_parni(1);

  NSString *className = @"SwiftFive.SwiftTextFieldLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"getTextFromIndex:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&nIndex atIndex:2];

      [invocation invoke];

      NSString *result;
      [invocation getReturnValue:&result];

      if (result) {
        hb_retc([result UTF8String]);
        return;
      }
    }
  }
  hb_retc("");
}
