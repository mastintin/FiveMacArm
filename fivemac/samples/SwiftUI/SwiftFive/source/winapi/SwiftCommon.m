#import "SwiftCommon.h"
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbvm.h>

void SwiftMsgAlert(NSString *title, NSString *msg) {
  NSAlert *alert = [[NSAlert alloc] init];
  [alert setMessageText:title];
  [alert setInformativeText:msg];
  [alert addButtonWithTitle:@"OK"];
  [alert runModal];
}

void setupSwiftView(NSView *swiftView, NSWindow *window, CGFloat top,
                    CGFloat left, CGFloat w, CGFloat h) {
  if (!window) {
    NSLog(@"Error: setupSwiftView called with NULL window");
    return;
  }
  NSView *contentView = [window contentView];
  if (!contentView) {
    NSLog(@"Error: setupSwiftView - Window has no contentView");
    return;
  }

  CGFloat winHeight = contentView.frame.size.height;
  CGFloat cocoaY = winHeight - top - h;

  NSLog(@"setupSwiftView: Adding view %@ (Frame: %f %f %f %f) CocoaY: %f",
        [swiftView class], left, cocoaY, w, h, cocoaY);

  [swiftView setFrame:NSMakeRect(left, cocoaY, w, h)];
  [contentView addSubview:swiftView];

  [swiftView setTranslatesAutoresizingMaskIntoConstraints:YES];
  [swiftView setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
}

HB_FUNC(CREATESWIFTVIEW) {
  NSLog(@"HB_FUNC: CREATESWIFTVIEW start");
  NSWindow *window = (NSWindow *)hb_parnl(1);
  const char *cClassName = hb_parc(2);
  if (!cClassName)
    return;
  NSString *className = [NSString stringWithUTF8String:cClassName];

  if (window && className) {
    Class swiftClass = NSClassFromString(className);
    if (!swiftClass) {
      swiftClass = NSClassFromString(
          [NSString stringWithFormat:@"SwiftFive.%@", className]);
    }

    if (swiftClass &&
        [swiftClass respondsToSelector:@selector(makeViewWithCallback:)]) {
      NSString *callbackName =
          (hb_pcount() >= 7) ? [NSString stringWithUTF8String:hb_parc(7)] : nil;

      void (^callbackBlock)(NSString *) = ^(NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (callbackName && [callbackName length] > 0) {
            PHB_DYNS pDynSym = hb_dynsymFindName([callbackName UTF8String]);
            if (pDynSym) {
              hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
              hb_vmPushNil();
              hb_vmPushString([msg UTF8String], [msg length]);
              hb_vmDo(1);
            }
          } else {
            SwiftMsgAlert(msg, @"SwiftUI Message");
          }
        });
      };

      NSView *swiftView =
          [swiftClass performSelector:@selector(makeViewWithCallback:)
                           withObject:callbackBlock];

      if (swiftView) {
        CGFloat top = hb_parnd(3);
        CGFloat left = hb_parnd(4);
        CGFloat w = hb_parnd(5);
        CGFloat h = hb_parnd(6);
        setupSwiftView(swiftView, window, top, left, w, h);
      }
    }
  }
}

HB_FUNC(SWIFTSTANDALONEBATCHCREATE) {
  NSLog(@"HB_FUNC: SWIFTSTANDALONEBATCHCREATE start");
  NSWindow *window = (NSWindow *)hb_parnl(1);
  const char *cJson = hb_parc(2);

  if (!cJson) {
    NSLog(@"SWIFTSTANDALONEBATCHCREATE: Error - JSON parameter is NULL");
    return;
  }

  NSString *jsonString = [NSString stringWithUTF8String:cJson];
  NSLog(@"SWIFTSTANDALONEBATCHCREATE: window=%p, jsonLength=%lu", window,
        (unsigned long)jsonString.length);

  if (!window) {
    NSLog(@"SWIFTSTANDALONEBATCHCREATE: Error - Window handle is NULL");
    // We should still return an empty array if possible to avoid Harbour errors
  }

  NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error = nil;
  NSArray *batch = [NSJSONSerialization JSONObjectWithData:data
                                                   options:0
                                                     error:&error];

  if (error || !batch) {
    NSLog(@"SWIFTSTANDALONEBATCHCREATE: Error parsing JSON: %@", error);
    return;
  }

  NSLog(@"SWIFTSTANDALONEBATCHCREATE: Processing %lu items",
        (unsigned long)batch.count);

  PHB_ITEM pArray = hb_itemNew(NULL);
  hb_arrayNew(pArray, (HB_SIZE)batch.count);

  int i = 0;
  for (NSDictionary *item in batch) {
    NSString *type = item[@"type"];
    NSView *fieldView = nil;

    if ([type isEqualToString:@"textfield"]) {
      NSString *text = item[@"text"] ?: @"";
      NSString *placeholder = item[@"placeholder"] ?: @"";
      NSString *cId = item[@"id"] ?: @"";
      NSInteger nIndex = [item[@"index"] integerValue];
      CGFloat top = [item[@"top"] floatValue];
      CGFloat left = [item[@"left"] floatValue];
      CGFloat width = [item[@"width"] floatValue] ?: 200.0;
      CGFloat height = [item[@"height"] floatValue] ?: 24.0;

      Class swiftClass = NSClassFromString(@"SwiftTextFieldLoader");
      if (!swiftClass)
        swiftClass = NSClassFromString(@"SwiftFive.SwiftTextFieldLoader");

      if (swiftClass) {
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
          [invocation setArgument:&text atIndex:2];
          [invocation setArgument:&placeholder atIndex:3];
          [invocation setArgument:&cId atIndex:4];
          [invocation setArgument:&nIndex atIndex:5];
          [invocation setArgument:&callbackBlock atIndex:6];
          [invocation invoke];
          [invocation getReturnValue:&fieldView];

          if (fieldView && window) {
            setupSwiftView(fieldView, window, top, left, width, height);
          }
        }
      }
    }

    PHB_ITEM pHandle = hb_itemPutPtr(NULL, (void *)fieldView);
    hb_arraySet(pArray, (HB_SIZE)++i, pHandle);
    hb_itemRelease(pHandle);
  }

  NSLog(@"SWIFTSTANDALONEBATCHCREATE: Finished, returning array");
  hb_itemReturnRelease(pArray);
}

HB_FUNC(SWIFT_UUID) {
  NSString *uuid = [[NSUUID UUID] UUIDString];
  hb_retc([uuid UTF8String]);
}
