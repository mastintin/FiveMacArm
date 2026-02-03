#import "SwiftCommon.h"

HB_FUNC(SWIFTCHARTCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSWindow *window = (NSWindow *)hb_parnl(5);
  NSInteger nIndex = (NSInteger)hb_parnl(6);
  NSString *cId = hb_NSSTRING_par(7);
  NSString *cData = hb_NSSTRING_par(8);
  NSString *cType = hb_NSSTRING_par(9);

  NSString *className = @"SwiftFive.SwiftChartLoader";
  Class swiftClass = NSClassFromString(className);

  if (!swiftClass) {
    NSLog(@"Error: Could not find class %@", className);
    return;
  }

  SEL selector = NSSelectorFromString(@"makeChart:data:type:index:");

  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];

    [invocation setArgument:&cId atIndex:2];
    [invocation setArgument:&cData atIndex:3];
    [invocation setArgument:&cType atIndex:4];
    [invocation setArgument:&nIndex atIndex:5];

    [invocation invoke];

    NSView *chartView;
    [invocation getReturnValue:&chartView];

    if (chartView) {
      setupSwiftView(chartView, window, nTop, nLeft, nWidth, nHeight);
      hb_retnl((HB_LONG)chartView);
    }
  } else {
    NSLog(@"ERROR: Selector %@ not found in class %@",
          NSStringFromSelector(selector), className);
  }
}

HB_FUNC(SWIFTCHARTSETDATA) {
  NSString *cData = hb_NSSTRING_par(1);
  NSString *cId = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftChartLoader";
  Class swiftClass = NSClassFromString(className);
  if (!swiftClass)
    return;

  SEL selector = NSSelectorFromString(@"setData:id:");
  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    [invocation setArgument:&cData atIndex:2];
    [invocation setArgument:&cId atIndex:3];
    [invocation invoke];
  }
}

HB_FUNC(SWIFTCHARTSETTYPE) {
  NSString *cType = hb_NSSTRING_par(1);
  NSString *cId = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftChartLoader";
  Class swiftClass = NSClassFromString(className);
  if (!swiftClass)
    return;

  SEL selector = NSSelectorFromString(@"setType:id:");
  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    [invocation setArgument:&cType atIndex:2];
    [invocation setArgument:&cId atIndex:3];
    [invocation invoke];
  }
}
HB_FUNC(SWIFTCHARTMAKESNAPSHOT) {
  NSString *cId = hb_NSSTRING_par(1);
  NSString *cPath = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftChartLoader";
  Class swiftClass = NSClassFromString(className);
  if (!swiftClass)
    return;

  SEL selector = NSSelectorFromString(@"makeSnapshot:path:");
  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    [invocation setArgument:&cId atIndex:2];
    [invocation setArgument:&cPath atIndex:3];
    [invocation invoke];
  }
}
