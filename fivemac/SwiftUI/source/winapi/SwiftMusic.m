#import "SwiftCommon.h"
#import "fivemac.h"
#import "hbapi.h"
#import <Cocoa/Cocoa.h>

// Helper to call Swift static method
static void CallSwiftMusicMethod(NSString *methodName) {
  NSString *className = @"SwiftFive.SwiftMusicLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(methodName);
    if ([swiftClass respondsToSelector:selector]) {
      [swiftClass performSelector:selector];
    } else {
      NSLog(@"[SwiftMusic] Method %@ not found in class %@", methodName,
            className);
    }
  } else {
    NSLog(@"[SwiftMusic] Class %@ not found", className);
  }
}

HB_FUNC(SWIFTMUSICPLAY) { CallSwiftMusicMethod(@"play"); }

HB_FUNC(SWIFTMUSICPAUSE) { CallSwiftMusicMethod(@"pause"); }

HB_FUNC(SWIFTMUSICNEXT) { CallSwiftMusicMethod(@"next"); }

HB_FUNC(SWIFTMUSICPREV) { CallSwiftMusicMethod(@"previous"); }

HB_FUNC(SWIFTMUSICSTOP) { CallSwiftMusicMethod(@"stop"); }

HB_FUNC(SWIFTMUSICAUTH) { CallSwiftMusicMethod(@"requestAuth"); }

HB_FUNC(SWIFTMUSICSTATE) {
  NSString *className = @"SwiftFive.SwiftMusicLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"getState");
    if ([swiftClass respondsToSelector:selector]) {
      // Return type is Int, so we need invocation or simple cast if strictly
      // compatible But performSelector returns id. For scalar return types like
      // Int, we need NSInvocation or a helper. Simplified approach:
      // performSelector works for objects. For scalars, use NSInvocation.

      NSMethodSignature *signature =
          [swiftClass methodSignatureForSelector:selector];
      NSInvocation *invocation =
          [NSInvocation invocationWithMethodSignature:signature];
      [invocation setSelector:selector];
      [invocation setTarget:swiftClass];
      [invocation invoke];

      NSInteger result;
      [invocation getReturnValue:&result];
      hb_retni((int)result);
      return;
    }
  }
  hb_retni(-1); // Error
}

HB_FUNC(SWIFTMUSICMETADATA) {
  NSString *className = @"SwiftFive.SwiftMusicLoader";
  Class swiftClass = NSClassFromString(className);

  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"getCurrentTrack");
    if ([swiftClass respondsToSelector:selector]) {
      // Expecting String return
      // performSelector returns id, so for NSString it's fine (with bridge
      // cast)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      NSString *result = (NSString *)[swiftClass performSelector:selector];
#pragma clang diagnostic pop

      if (result) {
        hb_retc([result UTF8String]);
        return;
      }
    }
  }
  hb_retc("{}");
}

HB_FUNC(SWIFTMUSICGETARTWORK) {
  NSString *className = @"SwiftFive.SwiftMusicLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *result = (NSString *)[swiftClass
        performSelector:NSSelectorFromString(@"getArtworkPath")];
#pragma clang diagnostic pop
    if (result) {
      hb_retc([result UTF8String]);
      return;
    }
  }
  hb_retc("");
}

HB_FUNC(SWIFTMUSICGETDURATION) {
  // Double return
  // Need invocation for non-object return types
  NSString *className = @"SwiftFive.SwiftMusicLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"getDuration");
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    [invocation invoke];
    double result;
    [invocation getReturnValue:&result];
    hb_retnd(result);
    return;
  }
  hb_retnd(0.0);
}

HB_FUNC(SWIFTMUSICGETPOSITION) {
  NSString *className = @"SwiftFive.SwiftMusicLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"getPosition");
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    [invocation invoke];
    double result;
    [invocation getReturnValue:&result];
    hb_retnd(result);
    return;
  }
  hb_retnd(0.0);
}

HB_FUNC(SWIFTMUSICSETPOSITION) {
  double seconds = hb_parnd(1);
  NSString *className = @"SwiftFive.SwiftMusicLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setPositionWithSeconds:");
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    [invocation setArgument:&seconds atIndex:2];
    [invocation invoke];
  }
}

HB_FUNC(SWIFTMUSICGETVOLUME) {
  NSString *className = @"SwiftFive.SwiftMusicLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"getVolume");
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    [invocation invoke];
    NSInteger result;
    [invocation getReturnValue:&result];
    hb_retni((int)result);
    return;
  }
  hb_retni(0);
}

HB_FUNC(SWIFTMUSICSETVOLUME) {
  NSInteger vol = (NSInteger)hb_parni(1);
  NSString *className = @"SwiftFive.SwiftMusicLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass) {
    SEL selector = NSSelectorFromString(@"setVolumeWithVol:");
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];
    [invocation setArgument:&vol atIndex:2];
    [invocation invoke];
  }
}
