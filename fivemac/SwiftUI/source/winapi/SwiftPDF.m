#import "SwiftCommon.h"

HB_FUNC(SWIFTPDFSAVE) {
  NSString *path = hb_NSSTRING_par(2);

  Class swiftClass = NSClassFromString(@"SwiftFive.SwiftPDF");
  if (!swiftClass)
    return;

  SEL selector = NSSelectorFromString(@"saveView:to:");
  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];

    NSInteger id = (NSInteger)hb_parni(1);
    [invocation setArgument:&id atIndex:2];
    [invocation setArgument:&path atIndex:3];

    [invocation invoke];
  }
}
