#import "Quartz/Quartz.h"
#import <ScreenCaptureKit/ScreenCaptureKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#include <fivemac.h>

NSAutoreleasePool *pool;

void CocoaInit(void) {
  static BOOL bInit = FALSE;

  if (!bInit) {
    pool = [[NSAutoreleasePool alloc] init];
    NSApp = [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp activateIgnoringOtherApps:YES];
    bInit = TRUE;
  }
}

HB_FUNC(COCOAINIT) { CocoaInit(); }

void CocoaExit(void) {
  static BOOL bExit = FALSE;

  if (!bExit) {
    [NSApp release];
    [pool release];
    bExit = TRUE;
  }
}

void MsgAlert(NSString *detailedInformation, NSString *messageText) {
  NSAlert *alert = [[NSAlert alloc] init];

  alert.messageText = messageText;
  alert.informativeText = detailedInformation;
  alert.alertStyle = NSAlertStyleWarning;

  [alert addButtonWithTitle:@"OK"];
  [alert runModal];
}

HB_FUNC(COCOAEXIT) { CocoaExit(); }

HB_FUNC(MSGBADGE) {
  ValToChar(hb_param(1, HB_IT_ANY));

  [[NSApp dockTile] setBadgeLabel:hb_NSSTRING_par(-1)];
}

HB_FUNC(MSGINFO) {
  NSString *msg, *title;

  CocoaInit();

  ValToChar(hb_param(1, HB_IT_ANY));
  msg = hb_NSSTRING_par(-1);
  if ([msg length] == 0)
    msg = @" ";

  if (hb_pcount() > 1) {
    ValToChar(hb_param(2, HB_IT_ANY));
    title = hb_NSSTRING_par(-1);
    if ([title length] == 0)
      title = @"Attention";
  } else
    title = @"Attention";

  NSAlert *alert = [[NSAlert alloc] init];

  alert.alertStyle = NSAlertStyleInformational;
  alert.informativeText = msg;
  alert.messageText = title;

  [alert addButtonWithTitle:@"OK"];
  [alert runModal];
  [alert release];

  hb_ret();
}
@interface Alert : NSAlert {
}
- (void)killWindow:(NSAlert *)alert;
@end

@implementation Alert

- (void)killWindow:(NSAlert *)alert;
{ [NSApp abortModal]; }

@end

HB_FUNC(MSGWAIT) {
  NSString *msg, *title;
  NSTimer *myTimer;

  CocoaInit();

  ValToChar(hb_param(1, HB_IT_ANY));
  msg = hb_NSSTRING_par(-1);
  if ([msg length] == 0)
    msg = @" ";

  if (hb_pcount() > 1) {
    ValToChar(hb_param(2, HB_IT_ANY));
    title = hb_NSSTRING_par(-1);
    if ([title length] == 0)
      title = @"Attention";
  } else
    title = @"Attention";

  Alert *alert = [[Alert alloc] init];

  alert.alertStyle = NSAlertStyleInformational;
  alert.informativeText = msg;
  alert.messageText = title;

  myTimer = [NSTimer timerWithTimeInterval:hb_parnl(3)
                                    target:alert
                                  selector:@selector(killWindow:)
                                  userInfo:nil
                                   repeats:NO];

  [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSModalPanelRunLoopMode];

  [alert addButtonWithTitle:@""];
  [alert runModal];
  [alert release];

  hb_ret();
}
HB_FUNC(MSGSTOP) {
  CocoaInit();

  NSAlert *dlg = [[NSAlert alloc] init];

  ValToChar(hb_param(1, HB_IT_ANY));
  dlg.informativeText = hb_NSSTRING_par(-1);
  dlg.messageText = @"Stop";
  dlg.alertStyle = NSAlertStyleWarning;

  [dlg addButtonWithTitle:@"OK"];
  [dlg runModal];

  hb_ret();
}

HB_FUNC(MSGALERT) {
  CocoaInit();

  NSAlert *dlg = [[NSAlert alloc] init];

  ValToChar(hb_param(1, HB_IT_ANY));
  dlg.informativeText = hb_NSSTRING_par(-1);
  dlg.messageText = @"Alert";
  dlg.alertStyle = NSAlertStyleWarning;

  [dlg addButtonWithTitle:@"OK"];
  [dlg runModal];

  hb_ret();
}

HB_FUNC(MSGALERTSHEET) {

  //  CocoaInit();

  ValToChar(hb_param(1, HB_IT_ANY));
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = @"Alert";
  alert.informativeText = hb_NSSTRING_par(-1);

  [alert addButtonWithTitle:@"OK"];

  [alert runModal];

  // hb_ret();
}

HB_FUNC(MSGYESNO) // cMsg --> lYesNo
{
  NSString *text;
  NSAlert *alert = [[NSAlert alloc] init];

  CocoaInit();

  ValToChar(hb_param(2, HB_IT_ANY));
  text = hb_NSSTRING_par(-1);
  if ([text isEqualToString:@""])
    text = @"Please select";

  alert.messageText = text;

  ValToChar(hb_param(1, HB_IT_ANY));
  text = hb_NSSTRING_par(-1);
  if ([text isEqualToString:@""])
    text = @"make a choice";

  alert.informativeText = text;

  [alert addButtonWithTitle:@"Yes"];
  [alert addButtonWithTitle:@"No"];

  hb_retl([alert runModal] == NSAlertFirstButtonReturn);

  [alert release];
}

HB_FUNC(MSGNOYES) // cMsg --> lYesNo
{
  NSString *text;
  NSAlert *alert = [[NSAlert alloc] init];

  CocoaInit();

  ValToChar(hb_param(2, HB_IT_ANY));
  text = hb_NSSTRING_par(-1);
  if ([text isEqualToString:@""])
    text = @"Please select";

  alert.messageText = text;

  ValToChar(hb_param(1, HB_IT_ANY));
  text = hb_NSSTRING_par(-1);
  if ([text isEqualToString:@""])
    text = @"make a choice";

  alert.informativeText = text;

  [alert addButtonWithTitle:@"No"];
  [alert addButtonWithTitle:@"Yes"];

  hb_retl([alert runModal] != NSAlertFirstButtonReturn);

  [alert release];
}

HB_FUNC(MSGBEEP) { NSBeep(); }

HB_FUNC(CHOOSETEXT) {
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060

  NSString *string = hb_NSSTRING_par(1);
  NSOpenPanel *panel = [NSOpenPanel openPanel];

  if ([string length] != 0) {
    [panel setDirectoryURL:[NSURL fileURLWithPath:string]];
  }

  panel.canChooseDirectories = YES;
  panel.message = @"Please select ";
  if (panel.runModal == NSModalResponseOK) {
    NSString *source =
        [[[[panel URLs] objectAtIndex:0] path] stringByRemovingPercentEncoding];

    hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
  } else
    hb_retc("");
#endif
}

HB_FUNC(CHOOSEFILE) {
  NSString *types = hb_NSSTRING_par(2);
  NSOpenPanel *op = [NSOpenPanel openPanel]; //[ [ NSOpenPanel alloc ] init ];

  [op setPrompt:@"Ok"];

  if (!HB_ISCHAR(1))
    [op setTitle:@"Please select a filename"];
  else
    [op setTitle:hb_NSSTRING_par(1)];

  if (![types isEqualToString:@""]) {
    NSMutableArray *allowedTypes = [NSMutableArray array];
    NSArray *extensions;

    if ([types containsString:@","]) {
      extensions = [types componentsSeparatedByString:@","];
    } else {
      extensions = @[ types ];
    }

    for (NSString *ext in extensions) {
      if (@available(macOS 11.0, *)) {
        UTType *type = [UTType typeWithFilenameExtension:ext];
        if (type) {
          [allowedTypes addObject:type];
        }
      }
    }

    if (@available(macOS 11.0, *)) {
      [op setAllowedContentTypes:allowedTypes];
    }
  }

  if ([op runModal] == NSModalResponseOK) {
    NSString *source =
        [[[[op URLs] objectAtIndex:0] path] stringByRemovingPercentEncoding];

    hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
  } else
    hb_retc("");
}

HB_FUNC(CHOOSEFILEURL) {
  NSOpenPanel *op = [[NSOpenPanel alloc] init];
  NSURL *source;

  [op setPrompt:@"Ok"];
  [op setMessage:@"Please select a file"];

  if ([op runModal] == NSModalResponseOK) {
    source = [[op URLs] objectAtIndex:0];
    hb_retnll((HB_LONGLONG)source);
  } else
    hb_ret();
}

HB_FUNC(CHOOSEFOLDER) {
  NSString *types = hb_NSSTRING_par(2);
  NSOpenPanel *op = [NSOpenPanel openPanel]; //[ [ NSOpenPanel alloc ] init ];

  [op setCanChooseFiles:NO];
  [op setCanChooseDirectories:YES];
  [op setPrompt:@"Ok"];

  if (!HB_ISCHAR(1))
    [op setTitle:@"Please select a folder"];
  else
    [op setTitle:hb_NSSTRING_par(1)];

  if (![types isEqualToString:@""]) {
    NSMutableArray *allowedTypes = [NSMutableArray array];
    NSArray *extensions;

    if ([types containsString:@","]) {
      extensions = [types componentsSeparatedByString:@","];
    } else {
      extensions = @[ types ];
    }

    for (NSString *ext in extensions) {
      if (@available(macOS 11.0, *)) {
        UTType *type = [UTType typeWithFilenameExtension:ext];
        if (type) {
          [allowedTypes addObject:type];
        }
      }
    }

    if (@available(macOS 11.0, *)) {
      [op setAllowedContentTypes:allowedTypes];
    }
  }

  if ([op runModal] == NSModalResponseOK) {
    NSString *source =
        [[[[op URLs] objectAtIndex:0] path] stringByRemovingPercentEncoding];

    hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
  } else
    hb_retc("");
}

HB_FUNC(SAVEFILE) {
  NSSavePanel *op = [[NSSavePanel alloc] init];

  [op setPrompt:@"Ok"];

  if (!HB_ISCHAR(1))
    [op setTitle:@"Please select a filename"];
  else
    [op setTitle:hb_NSSTRING_par(1)];

#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
  if (HB_ISCHAR(2))
    [op setNameFieldStringValue:hb_NSSTRING_par(2)];
#endif

  if ([op runModal] == NSModalResponseOK) {

    NSString *source = [[[op URL] path] stringByRemovingPercentEncoding];
    hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
  } else
    hb_retc("");
}

HB_FUNC(CHOOSEIMAGEFILE) {
  NSOpenPanel *op = [[NSOpenPanel alloc] init];
  NSArray *imageTypes = [NSImage imageTypes];

  [op setPrompt:@"Ok"];
  [op setMessage:@"Please select a file"];
  [op setAllowedContentTypes:imageTypes];

  if ([op runModal] == NSModalResponseOK) {
    NSString *source =
        [[[[op URLs] objectAtIndex:0] path] stringByRemovingPercentEncoding];

    hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
  } else
    hb_retc("");
}

HB_FUNC(CHOOSESHEETTXTIMG) {
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
  NSTextField *texto = (NSTextField *)hb_parnll(1);
  NSImageView *vista = (NSImageView *)hb_parnll(2);
  NSOpenPanel *panel = [NSOpenPanel openPanel];

  [panel setDirectoryURL:[NSURL fileURLWithPath:[texto stringValue]]];
  [panel setMessage:@"Import the file"];

  [panel
      beginSheetModalForWindow:[vista window]
             completionHandler:^(NSInteger result) {
               if (result == NSModalResponseOK) {
                 [vista setHidden:NO];
                 [vista
                     setImage:[[NSImage alloc]
                                  initWithContentsOfURL:[[panel URLs]
                                                            objectAtIndex:0]]];

                 NSString *source = [[[[panel URLs] objectAtIndex:0] path]
                     stringByRemovingPercentEncoding];

                 [texto setStringValue:source];
                 [[vista image] setName:source];
               }
             }];
#endif
}

HB_FUNC(CHOOSESHEETTEXT) {
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060

  NSString *string = hb_NSSTRING_par(1);
  NSOpenPanel *panel = [NSOpenPanel openPanel];

  if ([string length] != 0) {
    [panel setDirectoryURL:[NSURL fileURLWithPath:string]];
  }

  panel.canChooseDirectories = YES;
  panel.message = @"Importe Texto";
  if (panel.runModal == NSModalResponseOK) {
    NSString *source =
        [[[[panel URLs] objectAtIndex:0] path] stringByRemovingPercentEncoding];

    hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
  } else
    hb_retc("");
#endif
}

//----------------------------------------------------------------------------//

HB_FUNC(CLIPBOARDNEW) {
  NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
  hb_retnll((HB_LONGLONG)pasteBoard);
}

HB_FUNC(SETCLIPBOARDDATA) {
  NSPasteboard *pasteBoard = (NSPasteboard *)hb_parnll(1);
  int iType = hb_parnl(2);

  [pasteBoard clearContents];

  switch (iType) {
  case 1:
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString]
                       owner:nil];
    break;

  case 2:
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSPasteboardTypePNG]
                       owner:nil];
    break;

  case 12:
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeSound]
                       owner:nil];
    break;

  default:
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString]
                       owner:nil];
    break;
  }
}

HB_FUNC(CLIPBOARDCOPYPNG) {
  NSPasteboard *pasteBoard = (NSPasteboard *)hb_parnll(1);
  NSImage *image = (NSImage *)hb_parnll(2);
  CGImageRef CGImage = [image CGImageForProposedRect:nil context:nil hints:nil];
  NSBitmapImageRep *rep =
      [[[NSBitmapImageRep alloc] initWithCGImage:CGImage] autorelease];
  NSDictionary *dict =
      [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.5]
                                  forKey:NSImageCompressionFactor];
  NSData *data = [rep representationUsingType:NSBitmapImageFileTypePNG
                                   properties:dict];
  bool lResult = [pasteBoard setData:data forType:NSPasteboardTypePNG];

  hb_retl(lResult);
}

HB_FUNC(CLIPBOARDCOPYSTRING) {
  NSPasteboard *pasteBoard = (NSPasteboard *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);

  [pasteBoard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString]
                     owner:nil];
  bool lResult = [pasteBoard setString:string forType:NSPasteboardTypeString];
  hb_retl(lResult);
}

HB_FUNC(CLIPBOARDPASTESTRING) {
  NSPasteboard *pasteBoard = (NSPasteboard *)hb_parnll(1);
  NSString *string;

  string = [pasteBoard stringForType:NSPasteboardTypeString];
  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(CLIPBOARDCLEAR) {
  NSPasteboard *pasteBoard = (NSPasteboard *)hb_parnll(1);
  [pasteBoard clearContents];
}

HB_FUNC(CLIPBOARDGETNAME) {
  NSPasteboard *pasteBoard = (NSPasteboard *)hb_parnll(1);
  NSString *string = pasteBoard.name;
  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

//----------------------------------------------------------------------------//

HB_FUNC(COPYPASTEBOARDSTRING) {
  NSString *string = hb_NSSTRING_par(1);
  NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];

  [pasteBoard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString]
                     owner:nil];
  [pasteBoard setString:string forType:NSPasteboardTypeString];
}

HB_FUNC(PASTEPASTEBOARDSTRING) {
  NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
  NSString *string;

  [pasteBoard
      declareTypes:[NSArray arrayWithObjects:NSPasteboardTypeString, nil]
             owner:nil];
  string = [pasteBoard stringForType:NSPasteboardTypeString];
  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(SCREENTOPASTEBOARD) {
  if (@available(macOS 14.0, *)) {
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block CGImageRef capturedImage = NULL;

    [SCShareableContent getShareableContentWithCompletionHandler:^(
                            SCShareableContent *content, NSError *error) {
      if (error) {
        // NSLog(@"SCShareableContent error: %@", error);
        dispatch_semaphore_signal(sema);
        return;
      }

      SCDisplay *display = [content.displays firstObject];
      if (!display) {
        dispatch_semaphore_signal(sema);
        return;
      }

      SCContentFilter *filter = [[SCContentFilter alloc] initWithDisplay:display
                                                        excludingWindows:@[]];
      SCStreamConfiguration *config = [[SCStreamConfiguration alloc] init];
      config.width = display.width;
      config.height = display.height;
      config.showsCursor = NO;

      [SCScreenshotManager
          captureImageWithFilter:filter
                   configuration:config
               completionHandler:^(CGImageRef image, NSError *error) {
                 if (image) {
                   capturedImage = CGImageRetain(image);
                 } else {
                   // NSLog(@"Capture failed: %@", error);
                 }
                 dispatch_semaphore_signal(sema);
               }];
    }];

    // Wait for async capture (timeout 5s)
    dispatch_semaphore_wait(
        sema, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)));

    if (capturedImage) {
      NSPasteboard *pasteBoard = (NSPasteboard *)hb_parnll(1);
      NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc]
          initWithCGImage:capturedImage] autorelease];
      NSDictionary *dict =
          [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.5]
                                      forKey:NSImageCompressionFactor];
      NSData *data = [rep representationUsingType:NSBitmapImageFileTypePNG
                                       properties:dict];
      BOOL success = [pasteBoard setData:data forType:NSPasteboardTypePNG];

      CGImageRelease(capturedImage);
      hb_retl(success);
    } else {
      hb_retl(FALSE);
    }
  } else {
    // Fallback for older macOS (or return false if obsolete)
    hb_retl(FALSE);
  }
}
