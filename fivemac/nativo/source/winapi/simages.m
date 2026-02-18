#import <Cocoa/Cocoa.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#include <fivemac.h>

@interface MIKImageView : NSImageView {
  NSURL *selectedImageURL;
  BOOL isCropping;
  NSPoint startPoint;
  NSRect cropRect;
  CAShapeLayer *selectionLayer;
  NSImage *sourceImage; // Original image for filtering
}

@property(assign) BOOL isCropping;
@property(assign) NSRect cropRect;

- (NSURL *)selectedImageURL;
- (void)setSelectedImageURL:(NSURL *)url;
- (NSString *)fileName;
- (void)rotateImageRight;
- (void)setCropMode:(BOOL)enable;
- (void)performCrop;
- (void)setFilterBrightness:(float)b contrast:(float)c saturation:(float)s;
@end

@implementation MIKImageView

@synthesize isCropping;
@synthesize cropRect;

- (void)setImage:(NSImage *)image {
  if (sourceImage != image) {
    [sourceImage release];
    sourceImage = [image copy];
  }
  [super setImage:image];
}

// New method to force a new source image (e.g. after open or save)
- (void)resetSourceImage {
  [sourceImage release];
  sourceImage = [[self image] copy];
}

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    isCropping = NO;
    cropRect = NSZeroRect;

    // Enable Layer-backing
    [self setWantsLayer:YES];

    selectionLayer = [CAShapeLayer layer];
    // Use Red for high visibility debugging, clear fill to not obscure image
    selectionLayer.strokeColor = [[NSColor redColor] CGColor];
    selectionLayer.fillColor = [[NSColor colorWithCalibratedWhite:1.0
                                                            alpha:0.2] CGColor];
    selectionLayer.lineWidth = 2.0;
    selectionLayer.lineDashPattern = @[ @5, @5 ];
    selectionLayer.zPosition = 1000; // Force on top
    selectionLayer.hidden = YES;

    // REVERTED: geometryFlipped = YES causes visibility issues if not handled
    // everywhere. We will handle logic flipping in performCrop.

    [self.layer addSublayer:selectionLayer];
  }
  return self;
}

- (BOOL)isFlipped {
  return YES; // Match typical Harbor FLIPPED windows
}

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

// Rotation
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

// Crop Logic
- (void)setCropMode:(BOOL)enable {
  NSLog(@"DEBUG: setCropMode: %d", enable);
  isCropping = enable;
  if (enable) {
    [[self window] makeFirstResponder:self];
  } else {
    cropRect = NSZeroRect;
    selectionLayer.hidden = YES;
  }
  [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event {
  NSLog(@"DEBUG: mouseDown. isCropping: %d", isCropping);
  if (isCropping) {
    startPoint = [self convertPoint:[event locationInWindow] fromView:nil];
    cropRect = NSZeroRect;
    selectionLayer.hidden = NO;
    [self updateSelectionLayer];
  } else {
    [super mouseDown:event];
  }
}

- (void)mouseDragged:(NSEvent *)event {
  if (isCropping) {
    NSPoint currentPoint = [self convertPoint:[event locationInWindow]
                                     fromView:nil];
    cropRect = NSMakeRect(
        MIN(startPoint.x, currentPoint.x), MIN(startPoint.y, currentPoint.y),
        ABS(currentPoint.x - startPoint.x), ABS(currentPoint.y - startPoint.y));
    // NSLog(@"DEBUG: dragging cropRect: %@", NSStringFromRect(cropRect));
    [self updateSelectionLayer];
  } else {
    [super mouseDragged:event];
  }
}

- (void)mouseUp:(NSEvent *)event {
  if (isCropping) {
    NSLog(@"DEBUG: mouseUp. Final cropRect: %@", NSStringFromRect(cropRect));
  } else {
    [super mouseUp:event];
  }
}

- (void)updateSelectionLayer {
  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  CGPathRef path = CGPathCreateWithRect(cropRect, NULL);
  selectionLayer.path = path;
  CGPathRelease(path);
  selectionLayer.hidden = NO;
  [CATransaction commit];
}

- (void)performCrop {
  if (NSIsEmptyRect(cropRect) || ![self image])
    return;

  NSRect bounds = [self bounds];
  NSImage *image = [self image];
  NSSize imgSize = [image size];

  // Calculate aspect ratio
  CGFloat viewAR = bounds.size.width / bounds.size.height;
  CGFloat imgAR = imgSize.width / imgSize.height;

  NSRect drawingRect; // The rect where image is actually drawn in view

  if (imgAR > viewAR) {
    // Image is wider than view, it fits width
    CGFloat scale = bounds.size.width / imgSize.width;
    CGFloat drawnHeight = imgSize.height * scale;
    drawingRect = NSMakeRect(0, (bounds.size.height - drawnHeight) / 2,
                             bounds.size.width, drawnHeight);
  } else {
    // Image is taller, fits height
    CGFloat scale = bounds.size.height / imgSize.height;
    CGFloat drawnWidth = imgSize.width * scale;
    drawingRect = NSMakeRect((bounds.size.width - drawnWidth) / 2, 0,
                             drawnWidth, bounds.size.height);
  }

  // Intersection of cropRect and drawingRect
  NSRect validCrop = NSIntersectionRect(cropRect, drawingRect);

  if (NSIsEmptyRect(validCrop))
    return;

  // Convert validCrop back to image coordinates
  CGFloat scaleX = imgSize.width / drawingRect.size.width;
  CGFloat scaleY = imgSize.height / drawingRect.size.height;

  NSRect imgCropRect;
  imgCropRect.origin.x = (validCrop.origin.x - drawingRect.origin.x) * scaleX;
  imgCropRect.size.width = validCrop.size.width * scaleX;
  imgCropRect.size.height = validCrop.size.height * scaleY;

  // FIX: Flip Y coordinate (View is Top-Left, Image is Bottom-Left)
  // Calculate distance from Top of drawn image
  CGFloat y_from_top = (validCrop.origin.y - drawingRect.origin.y) * scaleY;
  // Invert for Bottom-Left origin
  imgCropRect.origin.y = imgSize.height - y_from_top - imgCropRect.size.height;

  NSLog(@"DEBUG: performCrop. ViewRect: %@ -> ImageRect: %@",
        NSStringFromRect(validCrop), NSStringFromRect(imgCropRect));

  NSImage *cropped = [[NSImage alloc] initWithSize:imgCropRect.size];
  [cropped lockFocus];
  [image drawAtPoint:NSZeroPoint
            fromRect:imgCropRect
           operation:NSCompositingOperationCopy
            fraction:1.0];
  [cropped unlockFocus];

  [self setImage:cropped];
  [cropped release];

  // Reset crop mode
  [self setCropMode:NO];
}

- (void)setFilterBrightness:(float)b contrast:(float)c saturation:(float)s {
  if (!sourceImage) {
    if ([self image])
      sourceImage = [[self image] copy];
    else
      return;
  }

  // Map Slider (0-100) to Core Image Values
  // Brightness: Default 0. Range -1 to 1.
  //   Input 50 -> 0.   Input 0 -> -0.5.  Input 100 -> 0.5.
  float brightness = (b - 50.0) / 100.0;

  // Contrast: Default 1. Range 0 to 4.
  //   Input 25 (default in prg) -> 1.0.
  //   Wait, 25 is low.
  // Let's assume input 50 is default (1.0).
  //   Input 0 -> 0.0.  Input 100 -> 2.0.
  float contrast = c / 25.0; // If default is 25, then 25/25 = 1.0. Correct.

  // Saturation: Default 1. Range 0 to 2.
  //   Input 50 (default) -> 1.0.
  float saturation = s / 50.0; // 50/50 = 1.0.

  NSLog(@"Filter: B:%.2f C:%.2f S:%.2f", brightness, contrast, saturation);

  CIImage *inputCIImage =
      [[CIImage alloc] initWithData:[sourceImage TIFFRepresentation]];
  if (!inputCIImage)
    return;

  CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
  [filter setDefaults];
  [filter setValue:inputCIImage forKey:kCIInputImageKey];
  [filter setValue:[NSNumber numberWithFloat:brightness]
            forKey:@"inputBrightness"];
  [filter setValue:[NSNumber numberWithFloat:contrast] forKey:@"inputContrast"];
  [filter setValue:[NSNumber numberWithFloat:saturation]
            forKey:@"inputSaturation"];

  CIImage *outputCIImage = [filter outputImage];

  if (outputCIImage) {
    // Force rendering to a CGImage (bitmap) to ensure visual update
    // We use a temporary context (nil options = default CPU or GPU context)
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputCIImage
                                       fromRect:[outputCIImage extent]];

    if (cgImage) {
      NSImage *finalImage =
          [[NSImage alloc] initWithCGImage:cgImage
                                      size:[outputCIImage extent].size];

      // Call super setImage to update view
      [super setImage:finalImage];
      [finalImage release];

      CGImageRelease(cgImage);
    } else {
      NSLog(@"ERROR: Failed to create CGImage from filter output");
    }
  }

  [inputCIImage release];
}

@end

// ---------------------------------------------------------------------------------------------------------------------

HB_FUNC(PHOTOCAMLOAD) {
  // Deprecated IKPictureTaker
  NSAlert *alert = [[[NSAlert alloc] init] autorelease];
  [alert setMessageText:@"Camera not supported"];
  [alert setInformativeText:
             @"IKPictureTaker is deprecated in macOS. Use external app."];
  [alert runModal];
}

HB_FUNC(SIMAGECREATE) {
  long top = hb_parnl(1);
  long left = hb_parnl(2);
  long w = hb_parnl(3);
  long h = hb_parnl(4);
  NSWindow *window = (NSWindow *)hb_parnll(5);

  // Create ScrollView for Zoom support
  NSScrollView *scroll =
      [[NSScrollView alloc] initWithFrame:NSMakeRect(left, top, w, h)];

  NSLog(@"DEBUG: SIMAGECREATE ScrollView created: %@", scroll);

  [scroll setHasVerticalScroller:YES];
  [scroll setHasHorizontalScroller:YES];
  [scroll setBorderType:NSBezelBorder];
  [scroll setAutohidesScrollers:YES];
  // Disable native magnification since we are doing manual frame zoom
  [scroll setAllowsMagnification:NO];
  [scroll setMagnification:1.0];

  // Create ImageView
  MIKImageView *vista =
      [[MIKImageView alloc] initWithFrame:NSMakeRect(0, 0, w, h)];
  [vista setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [vista setImageScaling:NSImageScaleProportionallyUpOrDown];
  [vista registerForDraggedTypes:[NSImage imageTypes]];
  [vista setEditable:YES];

  [scroll setDocumentView:vista];

  // Add ScrollView to Window
  [GetView(window) addSubview:scroll];

  // Important: Autoresizing
  scroll.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

  [vista release];  // Retained by scrollview
  [scroll release]; // Retained by window

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
  NSScrollView *scroll = [vista enclosingScrollView];
  if (scroll) {
    // Re-enable autoresizing to stick to edges
    [vista setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    // Reset frame to content bounds
    [vista setFrame:[[scroll contentView] bounds]];
  }
}

HB_FUNC(SIMAGEZOOMIN) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);

  // FIX: Manual Frame Zoom
  [vista setAutoresizingMask:NSViewNotSizable];

  NSRect frame = [vista frame];
  frame.size.width *= 1.25;
  frame.size.height *= 1.25;
  [vista setFrame:frame];

  [vista setNeedsDisplay:YES];
  NSLog(@"DEBUG: FrameZoomIn. New Size: %@", NSStringFromSize(frame.size));
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

  // FIX: Manual Frame Zoom
  [vista setAutoresizingMask:NSViewNotSizable];

  NSRect frame = [vista frame];
  frame.size.width *= 0.8;
  frame.size.height *= 0.8;
  [vista setFrame:frame];

  [vista setNeedsDisplay:YES];

  NSLog(@"DEBUG: FrameZoomOut. New Size: %@", NSStringFromSize(frame.size));
}

HB_FUNC(SIMAGEVFLIP) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  NSImage *image = [vista image];
  if (image) {
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
  // Legacy generic edit? Map to Crop?
}

HB_FUNC(SIMAGEAUTORESIZE) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  [vista setAutoresizesSubviews:hb_parl(2)];
}

HB_FUNC(SIMAGEGETAUTORESIZE) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  hb_retl((BOOL)[vista autoresizesSubviews]);
}

HB_FUNC(SIMAGESETCROP) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  // Ensure we have focus for key events if needed
  [[vista window] makeFirstResponder:vista];

  if ([vista isCropping]) {
    [vista performCrop];
  } else {
    [vista setCropMode:YES];
  }
}

HB_FUNC(SIMAGESETROTATE) {
  // Maybe toggle rotation mode? We handled rotation directly.
}

HB_FUNC(SIMAGESETNORMAL) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  [vista setCropMode:NO];
}

HB_FUNC(SIMAGESETHIDE) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  [[vista enclosingScrollView] setHidden:YES]; // Hide scrollview
}

HB_FUNC(SIMAGESETSHOW) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  [[vista enclosingScrollView] setHidden:NO];
}

HB_FUNC(SIMAGEFILTER) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  float b = (float)hb_parnd(2);
  float c = (float)hb_parnd(3);
  float s = (float)hb_parnd(4);

  [vista setFilterBrightness:b contrast:c saturation:s];
}

HB_FUNC(SIMAGECLEARFILTERS) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  if (vista && [vista layer]) {
    [[vista layer] setFilters:nil];
  }
}

HB_FUNC(CHOOSESHEETSIMAGE) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);

  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setMessage:@"Importe el Archivo"];

  if (@available(macOS 12.0, *)) {
    [panel setAllowedContentTypes:@[ UTTypeImage ]];
  } else {
    [panel setAllowedFileTypes:[NSImage imageTypes]];
  }

  [panel beginSheetModalForWindow:[vista window]
                completionHandler:^(NSInteger result) {
                  if (result == NSModalResponseOK) {
                    NSURL *url = [[panel URLs] objectAtIndex:0];
                    [[vista enclosingScrollView] setHidden:NO];
                    [vista setImageWithURL:url];
                  }
                }];
}

HB_FUNC(SIMAGESAVEAS) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);

  NSSavePanel *savePanel = [NSSavePanel savePanel];
  // Modern replacement for setAllowedFileTypes
  if (@available(macOS 11.0, *)) {
    [savePanel setAllowedContentTypes:@[
      [UTType typeWithIdentifier:@"public.png"],
      [UTType typeWithIdentifier:@"public.jpeg"],
      [UTType typeWithIdentifier:@"public.tiff"]
    ]];
  } else {
    [savePanel setAllowedFileTypes:@[ @"png", @"jpg", @"tiff" ]];
  }

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
