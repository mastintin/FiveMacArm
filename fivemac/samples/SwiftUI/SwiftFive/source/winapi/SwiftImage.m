#import "SwiftCommon.h"

// Helper to get hex color string (Reuse from SwiftButton.m if possible, but
// safe to define here too statically)
static NSString *HexColorForImage(long nColor) {
  int r = nColor & 0xFF;
  int g = (nColor >> 8) & 0xFF;
  int b = (nColor >> 16) & 0xFF;
  return [NSString stringWithFormat:@"%02X%02X%02X", r, g, b];
}

HB_FUNC(SWIFTIMAGECREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSString *systemName = hb_NSSTRING_par(5);
  NSWindow *window = (NSWindow *)hb_parnl(6);
  int nIndex = hb_parni(7);

  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);

  if (!swiftClass) {
    NSLog(@"Error: Could not find class %@", className);
    return;
  }

  void (^callbackBlock)(NSString *) = ^(NSString *msg) {
    dispatch_async(dispatch_get_main_queue(), ^{
      PHB_DYNS pDynSym = hb_dynsymFindName("SWIFTIMAGEONCLICK");
      if (pDynSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
        hb_vmPushNil();
        hb_vmPushInteger(nIndex);
        hb_vmDo(1);
      }
    });
  };

  SEL selector =
      NSSelectorFromString(@"makeImageWithSystemName:index:callback:");

  if ([swiftClass respondsToSelector:selector]) {
    NSMethodSignature *signature =
        [swiftClass methodSignatureForSelector:selector];
    NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:swiftClass];

    [invocation setArgument:&systemName atIndex:2];
    [invocation setArgument:&nIndex atIndex:3];
    [invocation setArgument:&callbackBlock atIndex:4];

    [invocation invoke];

    NSView *imgView;
    [invocation getReturnValue:&imgView];

    if (imgView) {
      NSLog(@"SWIFTIMAGECREATE: View Created successfully (ptr=%p). Calling "
            @"setupSwiftView...",
            imgView);
      setupSwiftView(imgView, window, nTop, nLeft, nWidth, nHeight);
      hb_retnl((HB_LONG)imgView);
    } else {
      NSLog(@"SWIFTIMAGECREATE: View Creation Failed (imgView is nil)");
    }
  } else {
    NSLog(@"Error: Class %@ does not respond to selector "
          @"makeImageWithSystemName:index:callback:",
          className);
  }
}

HB_FUNC(SWIFTIMAGESETSYSTEMNAME) {
  NSString *name = hb_NSSTRING_par(1);
  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass &&
      [swiftClass respondsToSelector:@selector(setImageSystemName:)]) {
    [swiftClass performSelector:@selector(setImageSystemName:) withObject:name];
  }
}

HB_FUNC(SWIFTIMAGESETNAME) {
  NSString *name = hb_NSSTRING_par(1);
  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass && [swiftClass respondsToSelector:@selector(setImageName:)]) {
    [swiftClass performSelector:@selector(setImageName:) withObject:name];
  }
}

HB_FUNC(SWIFTIMAGESETCOLOR) {
  long nColor = hb_parnl(1);
  NSString *hexColor = HexColorForImage(nColor);

  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass && [swiftClass respondsToSelector:@selector(setImageColor:)]) {
    [swiftClass performSelector:@selector(setImageColor:) withObject:hexColor];
  }
}

HB_FUNC(SWIFTIMAGESETRESIZABLE) {
  BOOL bResizable = hb_parl(1);
  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass &&
      [swiftClass respondsToSelector:@selector(setImageResizable:)]) {
    [swiftClass performSelector:@selector(setImageResizable:)
                     withObject:[NSNumber numberWithBool:bResizable]];
  }
}

HB_FUNC(SWIFTIMAGESETFILE) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass && [swiftClass respondsToSelector:@selector(setImageFile:)]) {
    [swiftClass performSelector:@selector(setImageFile:) withObject:file];
  }
}

HB_FUNC(SWIFTIMAGESETASPECTRATIO) {
  long nMode = hb_parnl(1);
  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass &&
      [swiftClass respondsToSelector:@selector(setImageAspectRatio:)]) {
    [swiftClass performSelector:@selector(setImageAspectRatio:)
                     withObject:[NSNumber numberWithInt:(int)nMode]];
  }
}

HB_FUNC(SWIFTIMAGESETNSIMAGE) {
  NSImage *image = (NSImage *)hb_parnl(1);
  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass && [swiftClass respondsToSelector:@selector(setImageObj:)]) {
    [swiftClass performSelector:@selector(setImageObj:) withObject:image];
  }
}
