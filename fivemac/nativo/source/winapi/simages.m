#import <Cocoa/Cocoa.h>
#include <fivemac.h>

@interface MIKImageView : NSImageView {
  NSURL *selectedImageURL;
}

- (NSURL *)selectedImageURL;
- (void)setSelectedImageURL:(NSURL *)url;
- (NSString *)fileName;
- (void)rotateImageLeft;
- (void)rotateImageRight;

@end

@implementation MIKImageView

- (NSString *)fileName {
  return [[[self selectedImageURL] path] lastPathComponent];
}

- (NSURL *)selectedImageURL {
  return selectedImageURL;
}

- (void)setSelectedImageURL:(NSURL *)url {
  [self willChangeValueForKey:@"fileName"];
  if (selectedImageURL != url) {
    [selectedImageURL release];
    selectedImageURL = [url retain];
  }
  [self didChangeValueForKey:@"fileName"];
}

- (void)setImageWithURL:(NSURL *)url {
  NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
  if (image) {
    [self setImage:image];
    [self setSelectedImageURL:url];
    [image release];
  }
}

- (void)rotateImage:(CGFloat)degrees {
  NSImage *image = [self image];
  if (!image)
    return;

  NSSize existingSize = [image size];
  NSSize newSize = NSMakeSize(existingSize.height, existingSize.width);
  NSImage *rotatedImage = [[NSImage alloc] initWithSize:newSize];

  [rotatedImage lockFocus];

  NSAffineTransform *rotateTF = [NSAffineTransform transform];
  NSPoint center = NSMakePoint(newSize.width / 2, newSize.height / 2);

  [rotateTF translateXBy:center.x yBy:center.y];
  [rotateTF rotateByDegrees:degrees];
  [rotateTF translateXBy:-existingSize.width / 2 yBy:-existingSize.height / 2];

  [rotateTF concat];

  [image drawAtPoint:NSZeroPoint
            fromRect:NSZeroRect
           operation:NSCompositingOperationCopy
            fraction:1.0];

  [rotatedImage unlockFocus];

  [self setImage:rotatedImage];
  [rotatedImage release];
}

- (void)rotateImageLeft {
  [self rotateImage:90];
}

- (void)rotateImageRight {
  [self rotateImage:-90];
}

@end

// ---------------------------------------------------------------------------------------------------------------------

HB_FUNC(PHOTOCAMLOAD) {
  // Deprecated IKPictureTaker
  // Generic placeholder or TODO
  NSLog(@"PHOTOCAMLOAD: IKPictureTaker is deprecated and not available in this "
        @"version.");
}

HB_FUNC(SIMAGECREATE) {
  MIKImageView *vista =
      [[MIKImageView alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                     hb_parnl(3), hb_parnl(4))];

  vista.autoresizesSubviews = YES;
  [vista setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [vista
      setImageScaling:NSImageScaleProportionallyUpOrDown]; // Default to "Fit"

  // Enable drag and drop for images
  [vista registerForDraggedTypes:[NSImage imageTypes]];
  [vista setEditable:YES]; // Allows drag-drop onto view

  NSWindow *window = (NSWindow *)hb_parnll(5);
  [GetView(window) addSubview:vista];

  hb_retnll((HB_LONGLONG)vista);
}

HB_FUNC(SIMAGEOPEN) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  NSString *path = hb_NSSTRING_par(2);

  if (path) {
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    [vista setImageWithURL:fileURL];
    hb_retnll((HB_LONGLONG)[fileURL path]);
  } else {
    hb_retnll(0);
  }
}

HB_FUNC(SIMAGEFIT) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  [vista setImageScaling:NSImageScaleProportionallyUpOrDown];
}

HB_FUNC(SIMAGEZOOMIN) {
  // NSImageView does not support zoom factor natively without scrollview + mag.
  // We simulate "Actual Size" or "None" scaling
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  [vista setImageScaling:NSImageScaleNone];
}

HB_FUNC(SIMAGEROTALEFT) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  [vista rotateImageLeft];
}

HB_FUNC(SIMAGEROTARIGHT) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  [vista rotateImageRight];
}

HB_FUNC(SIMAGEZOOMOUT) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  [vista setImageScaling:NSImageScaleProportionallyUpOrDown];
}

HB_FUNC(SIMAGEVFLIP) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  NSImage *image = [vista image];
  if (image) {
    // Basic Flip
    NSImage *flipped = [[NSImage alloc] initWithSize:[image size]];
    [flipped lockFocus];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform scaleXBy:1.0 yBy:-1.0];
    [transform translateXBy:0 yBy:-[image size].height];
    [transform concat];
    [image drawAtPoint:NSZeroPoint
              fromRect:NSZeroRect
             operation:NSCompositingOperationCopy
              fraction:1.0];
    [flipped unlockFocus];
    [vista setImage:flipped];
    [flipped release];
  }
}

HB_FUNC(SIMAGEEDIT) {
  // Not supported in NSImageView
}

HB_FUNC(SIMAGEAUTORESIZE) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  // [ vista setAutoresizes: hb_parl( 2 ) ]; // NSView method?
  // autoresizesSubviews is bool
  [vista setAutoresizesSubviews:hb_parl(2)];
}

HB_FUNC(SIMAGEGETAUTORESIZE) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  hb_retl((BOOL)[vista autoresizesSubviews]);
}

HB_FUNC(SIMAGESETCROP) {
  // Not supported
}

HB_FUNC(SIMAGESETROTATE) {
  // Not supported interactive tool
}

HB_FUNC(SIMAGESETNORMAL) {
  // Not supported tool modes
}

HB_FUNC(SIMAGESETHIDE) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  [vista setHidden:YES];
}

HB_FUNC(SIMAGESETSHOW) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  [vista setHidden:NO];
}

HB_FUNC(CHOOSESHEETSIMAGE) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);

  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setMessage:@"Importe el Archivo"];
  [panel setAllowedFileTypes:[NSImage imageTypes]];

  [panel beginSheetModalForWindow:[vista window]
                completionHandler:^(NSInteger result) {
                  if (result == NSModalResponseOK) {
                    NSURL *url = [[panel URLs] objectAtIndex:0];
                    [vista setHidden:NO];
                    [vista setImageWithURL:url];
                  }
                }];
}

HB_FUNC(SIMAGESAVEAS) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);

  NSSavePanel *savePanel = [NSSavePanel savePanel];
  [savePanel setAllowedFileTypes:@[ @"png", @"jpg", @"tiff" ]];
  [savePanel
      setNameFieldStringValue:[[vista fileName] stringByDeletingPathExtension]];
  [savePanel setMessage:@"Grabe el archivo"];

  [savePanel beginSheetModalForWindow:[vista window]
                    completionHandler:^(NSInteger result) {
                      if (result == NSModalResponseOK) {
                        NSURL *url = [savePanel URL];
                        NSImage *image = [vista image];
                        if (image) {
                          CGImageRef cgRef = [image CGImageForProposedRect:NULL
                                                                   context:nil
                                                                     hints:nil];
                          NSBitmapImageRep *newRep =
                              [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
                          [newRep setSize:[image size]];
                          NSData *data = [newRep
                              representationUsingType:NSBitmapImageFileTypePNG
                                           properties:@{}];
                          [data writeToURL:url atomically:YES];
                          [newRep release];
                        }
                      }
                    }];
}
