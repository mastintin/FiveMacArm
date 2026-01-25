#import "SwiftCommon.h"

// Helper to get hex color string
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

  // SUPPORT FOR HYBRID ID (Int or String)
  NSString *cId = nil;
  int nIndex = 0;

  if (HB_ISNUM(7)) {
    nIndex = hb_parni(7);
    cId = [NSString stringWithFormat:@"%d", nIndex];
  } else if (HB_ISCHAR(7)) {
    cId = hb_NSSTRING_par(7);
    nIndex = [cId intValue]; // Try validation
  }

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
        hb_vmPushInteger(nIndex); // Legacy support
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
    [invocation setArgument:&cId atIndex:3];
    [invocation setArgument:&callbackBlock atIndex:4];

    [invocation invoke];

    NSView *imgView;
    [invocation getReturnValue:&imgView];

    if (imgView) {
      setupSwiftView(imgView, window, nTop, nLeft, nWidth, nHeight);
      hb_retnl((HB_LONG)imgView);
    }
  }
}

HB_FUNC(SWIFTIMAGESETSYSTEMNAME) {
  // Param 1: ID
  // Param 2: SystemName

  NSString *cId = nil;
  if (HB_ISNUM(1)) {
    cId = [NSString stringWithFormat:@"%d", hb_parni(1)];
  } else {
    cId = hb_NSSTRING_par(1);
  }

  NSString *name = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass &&
      [swiftClass respondsToSelector:@selector(setImageSystemName:name:)]) {
    [swiftClass performSelector:@selector(setImageSystemName:name:)
                     withObject:cId
                     withObject:name];
  }
}

HB_FUNC(SWIFTIMAGESETNAME) {
  NSString *cId = nil;
  if (HB_ISNUM(1)) {
    cId = [NSString stringWithFormat:@"%d", hb_parni(1)];
  } else {
    cId = hb_NSSTRING_par(1);
  }

  NSString *name = hb_NSSTRING_par(2);

  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass && [swiftClass respondsToSelector:@selector(setImageName:
                                                                     name:)]) {
    [swiftClass performSelector:@selector(setImageName:name:)
                     withObject:cId
                     withObject:name];
  }
}

HB_FUNC(SWIFTIMAGESETCOLOR) {
  NSString *cId = nil;
  if (HB_ISNUM(1)) {
    cId = [NSString stringWithFormat:@"%d", hb_parni(1)];
  } else {
    cId = hb_NSSTRING_par(1);
  }

  long nColor = hb_parnl(2);
  NSString *hexColor = HexColorForImage(nColor);

  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass && [swiftClass respondsToSelector:@selector(setImageColor:
                                                                  colorHex:)]) {
    [swiftClass performSelector:@selector(setImageColor:colorHex:)
                     withObject:cId
                     withObject:hexColor];
  }
}

HB_FUNC(SWIFTIMAGESETRESIZABLE) {
  NSString *cId = nil;
  if (HB_ISNUM(1)) {
    cId = [NSString stringWithFormat:@"%d", hb_parni(1)];
  } else {
    cId = hb_NSSTRING_par(1);
  }

  BOOL bResizable = hb_parl(2);
  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass &&
      [swiftClass respondsToSelector:@selector(setImageResizable:resizable:)]) {
    [swiftClass performSelector:@selector(setImageResizable:resizable:)
                     withObject:cId
                     withObject:[NSNumber numberWithBool:bResizable]];
  }
}

HB_FUNC(SWIFTIMAGESETFILE) {
  NSString *cId = nil;
  if (HB_ISNUM(1)) {
    cId = [NSString stringWithFormat:@"%d", hb_parni(1)];
  } else {
    cId = hb_NSSTRING_par(1);
  }

  NSString *file = hb_NSSTRING_par(2);
  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass && [swiftClass respondsToSelector:@selector(setImageFile:
                                                                     path:)]) {
    [swiftClass performSelector:@selector(setImageFile:path:)
                     withObject:cId
                     withObject:file];
  }
}

HB_FUNC(SWIFTIMAGESETASPECTRATIO) {
  NSString *cId = nil;
  if (HB_ISNUM(1)) {
    cId = [NSString stringWithFormat:@"%d", hb_parni(1)];
  } else {
    cId = hb_NSSTRING_par(1);
  }

  long nMode = hb_parnl(2);
  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass &&
      [swiftClass respondsToSelector:@selector(setImageAspectRatio:mode:)]) {
    [swiftClass performSelector:@selector(setImageAspectRatio:mode:)
                     withObject:cId
                     withObject:[NSNumber numberWithInt:(int)nMode]];
  }
}

HB_FUNC(SWIFTIMAGESETNSIMAGE) {
  NSString *cId = nil;
  if (HB_ISNUM(1)) {
    cId = [NSString stringWithFormat:@"%d", hb_parni(1)];
  } else {
    cId = hb_NSSTRING_par(1);
  }

  NSImage *image = (NSImage *)hb_parnl(2);
  NSString *className = @"SwiftFive.SwiftImageLoader";
  Class swiftClass = NSClassFromString(className);
  if (swiftClass && [swiftClass respondsToSelector:@selector(setImageObj:
                                                                   image:)]) {
    [swiftClass performSelector:@selector(setImageObj:image:)
                     withObject:cId
                     withObject:image];
  }
}
