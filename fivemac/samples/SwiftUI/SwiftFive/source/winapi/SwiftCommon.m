#import "SwiftCommon.h"

void SwiftMsgAlert(NSString *title, NSString *msg) {
  NSAlert *alert = [[NSAlert alloc] init];
  [alert setMessageText:title];
  [alert setInformativeText:msg];
  [alert addButtonWithTitle:@"OK"];
  [alert runModal];
}

void setupSwiftView(NSView *swiftView, NSWindow *window, CGFloat x, CGFloat y,
                    CGFloat w, CGFloat h) {
  NSLog(@"setupSwiftView: Adding view %@ to window at %f,%f %fx%f", swiftView,
        x, y, w, h);
  NSView *contentView = [window contentView];
  [contentView addSubview:swiftView];
  [swiftView setTranslatesAutoresizingMaskIntoConstraints:NO];

  // Top
  [contentView addConstraint:[NSLayoutConstraint
                                 constraintWithItem:swiftView
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:contentView
                                          attribute:NSLayoutAttributeTop
                                         multiplier:1.0
                                           constant:x]]; // x param maps to Top
                                                         // (row in Harbour)

  // Left (Leading)
  [contentView addConstraint:[NSLayoutConstraint
                                 constraintWithItem:swiftView
                                          attribute:NSLayoutAttributeLeading
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:contentView
                                          attribute:NSLayoutAttributeLeading
                                         multiplier:1.0
                                           constant:y]]; // y param maps to Left
                                                         // (col in Harbour)

  // Width
  [swiftView
      addConstraint:[NSLayoutConstraint
                        constraintWithItem:swiftView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:w]];
  // Height
  [swiftView
      addConstraint:[NSLayoutConstraint
                        constraintWithItem:swiftView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:h]];
}

HB_FUNC(CREATESWIFTVIEW) {
  NSWindow *window = (NSWindow *)hb_parnl(1);
  NSString *className = hb_NSSTRING_par(2); // Second param: Class Name

  if (window && className) {

    // 1. Try to find the class directly (e.g. "SwiftUIAPP.SwiftLoader")
    Class swiftClass = NSClassFromString(className);

    // 2. If not found, try to prepend the module name if the user didn't
    // provide it.
    //    We assume the module name matches the executable name or a standard
    //    convention if needed. For now, we expect the user to pass
    //    "Module.Class".

    if (!swiftClass) {
      NSLog(@"Error: Could not find Swift class '%@'", className);
      return;
    }

    // 3. Check for makeViewWithCallback: first
    if ([swiftClass respondsToSelector:@selector(makeViewWithCallback:)]) {

      // Get optional callback name (param 7)
      NSString *callbackName = (hb_pcount() >= 7) ? hb_NSSTRING_par(7) : nil;

      // Define the callback block
      void (^callbackBlock)(NSString *) = ^(NSString *msg) {
        // Dispatch to main queue to avoid blocking
        dispatch_async(dispatch_get_main_queue(), ^{
          if (callbackName && [callbackName length] > 0) {
            // Call specific Harbour function
            PHB_DYNS pDynSym = hb_dynsymFindName([callbackName UTF8String]);
            if (pDynSym) {
              hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
              hb_vmPushNil();
              hb_vmPushString([msg UTF8String], [msg length]);
              hb_vmDo(1);
            } else {
              NSLog(@"Error: Harbour function '%@' not found", callbackName);
            }
          } else {
            SwiftMsgAlert(msg, @"SwiftUI Message"); // MsgAlert( info, title )
          }
        });
      };

      NSView *swiftView =
          [swiftClass performSelector:@selector(makeViewWithCallback:)
                           withObject:callbackBlock];

      if (swiftView) {
        // Param 3, 4, 5, 6 are coordinates
        CGFloat top = (hb_pcount() >= 6) ? hb_parnd(3) : 0;
        CGFloat left = (hb_pcount() >= 6) ? hb_parnd(4) : 0;
        CGFloat w = (hb_pcount() >= 6) ? hb_parnd(5) : 0;
        CGFloat h = (hb_pcount() >= 6) ? hb_parnd(6) : 0;
        setupSwiftView(swiftView, window, top, left, w, h);
      }
    } else {
      NSLog(@"Error: Class '%@' does not respond to 'makeView'", className);
    }
  }
}
