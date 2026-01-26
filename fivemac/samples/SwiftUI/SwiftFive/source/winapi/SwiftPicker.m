#import "SwiftCommon.h"

HB_FUNC(SWIFTPICKERCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);

  // Items array handling
  NSArray *itemsArray = nil;
  if (HB_ISARRAY(5)) {
    NSMutableArray *tempArray = [NSMutableArray array];
    PHB_ITEM pArray = hb_param(5, HB_IT_ARRAY);

    if (pArray) {
      HB_SIZE nLen = hb_arrayLen(pArray);
      for (HB_SIZE i = 1; i <= nLen; i++) {
        const char *cItem = hb_arrayGetCPtr(pArray, i);
        if (cItem)
          [tempArray addObject:[NSString stringWithUTF8String:cItem]];
      }
    }
    itemsArray = [NSArray arrayWithArray:tempArray];
  }

  NSWindow *window = (NSWindow *)hb_parnl(6);
  NSInteger nIndex = (NSInteger)hb_parni(7); // Index in control array
  NSString *cTitle = hb_NSSTRING_par(8);     // Optional title

  NSString *className = @"SwiftFive.SwiftPickerLoader";
  Class swiftClass = NSClassFromString(className);

  if (!swiftClass) {
    NSLog(@"Error: Could not find class %@", className);
    return;
  }

  // Callback
  void (^callbackBlock)(NSString *) = ^(NSString *msg) {
    dispatch_async(dispatch_get_main_queue(), ^{
      PHB_DYNS pDynSym = hb_dynsymFindName("SWIFTPICKERONCHANGE");
      if (pDynSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
        hb_vmPushNil();
        hb_vmPushInteger((int)nIndex);
        hb_vmPushString([msg UTF8String], [msg length]);
        hb_vmDo(2);
      }
    });
  };

  // Signature: makePicker(title:items:index:callback:)
  SEL selector =
      NSSelectorFromString(@"makePickerWithTitle:items:index:callback:");

  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];

    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];

    [invocation setArgument:&cTitle atIndex:2];
    [invocation setArgument:&itemsArray atIndex:3];
    [invocation setArgument:&nIndex atIndex:4];
    [invocation setArgument:&callbackBlock atIndex:5];

    [invocation invoke];

    NSView *pickerView;
    [invocation getReturnValue:&pickerView];

    if (pickerView) {
      [pickerView setFrame:NSMakeRect(nLeft, nTop, nWidth, nHeight)];

      id parent = (id)hb_parnl(6);
      if ([parent isKindOfClass:[NSWindow class]]) {
        [[(NSWindow *)parent contentView] addSubview:pickerView];
      } else if ([parent isKindOfClass:[NSView class]]) {
        [(NSView *)parent addSubview:pickerView];
      }
      hb_retnll((HB_LONGLONG)pickerView);
    }
  }
}

HB_FUNC(SWIFTPICKERSETITEMS) {
  NSArray *itemsArray = nil;
  if (HB_ISARRAY(1)) {
    NSMutableArray *tempArray = [NSMutableArray array];
    PHB_ITEM pArray = hb_param(1, HB_IT_ARRAY);

    if (pArray) {
      HB_SIZE nLen = hb_arrayLen(pArray);
      for (HB_SIZE i = 1; i <= nLen; i++) {
        const char *cItem = hb_arrayGetCPtr(pArray, i);
        if (cItem)
          [tempArray addObject:[NSString stringWithUTF8String:cItem]];
      }
    }
    itemsArray = [NSArray arrayWithArray:tempArray];
  }

  NSInteger nIndex = (NSInteger)hb_parni(2);

  NSString *className = @"SwiftFive.SwiftPickerLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setPickerItems:index:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];

      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&itemsArray atIndex:2];
      [invocation setArgument:&nIndex atIndex:3];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTPICKERSETSELECTION) {
  NSString *cValue = hb_NSSTRING_par(1);
  NSInteger nIndex = (NSInteger)hb_parni(2);

  NSString *className = @"SwiftFive.SwiftPickerLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setPickerSelection:index:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];

      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&cValue atIndex:2];
      [invocation setArgument:&nIndex atIndex:3];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTPICKERSETGLASS) {
  BOOL isGlass = hb_parl(1);
  NSInteger nIndex = (NSInteger)hb_parni(2);

  NSString *className = @"SwiftFive.SwiftPickerLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setPickerGlass:index:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];

      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&isGlass atIndex:2];
      [invocation setArgument:&nIndex atIndex:3];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTPICKERSETSHOWLABEL) {
  BOOL showLabel = hb_parl(1);
  NSInteger nIndex = (NSInteger)hb_parni(2);

  NSString *className = @"SwiftFive.SwiftPickerLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setPickerShowLabel:index:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];

      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&showLabel atIndex:2];
      [invocation setArgument:&nIndex atIndex:3];

      [invocation invoke];
    }
  }
}

HB_FUNC(SWIFTPICKERSETTITLE) {
  NSString *cTitle = hb_NSSTRING_par(1);
  NSInteger nIndex = (NSInteger)hb_parni(2);

  NSString *className = @"SwiftFive.SwiftPickerLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setPickerTitle:index:");
    if ([swiftClass respondsToSelector:selector]) {
      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];

      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];

      [invocation setArgument:&cTitle atIndex:2];
      [invocation setArgument:&nIndex atIndex:3];

      [invocation invoke];
    }
  }
}
