#import <Cocoa/Cocoa.h>
#import <CoreImage/CoreImage.h>
#import <fivemac.h>

// Helper to get MIKImageView from handle (defined in simages.m but we can cast
// generic NSView) actually we need to import headers or just cast.
@interface MIKImageView : NSImageView
@property(assign) NSImage *sourceImage;
@end

#include <hbapiitm.h>

// Crear el filtro por nombre
HB_FUNC(CIFILTERCREATE) {
  NSString *filterName = [NSString stringWithUTF8String:hb_parc(1)];
  CIFilter *filter = [CIFilter filterWithName:filterName];

  if (filter) {
    [filter setDefaults];
    // Retain the filter because we are passing it to Harbour as a number
    // (pointer cast) and we want it to persist.
    [filter retain];
    hb_retnll((HB_LONGLONG)filter);
  } else {
    hb_retnll(0);
  }
}

// Asignar valores (Key-Value Coding)
HB_FUNC(CIFILTERSETVALUE) {
  CIFilter *filter = (CIFilter *)hb_parnll(1);
  char *cKey = (char *)hb_parc(2);

  if (filter && cKey) {
    NSString *key = [NSString stringWithUTF8String:cKey];

    // Detectar si el valor es numérico o cadena
    if (HB_ISNUM(3)) {
      [filter setValue:[NSNumber numberWithFloat:(float)hb_parnd(3)]
                forKey:key];
    } else if (HB_ISCHAR(3)) {
      [filter setValue:[NSString stringWithUTF8String:hb_parc(3)] forKey:key];
    }
  }
}

// Helper function to apply the filter to an MIKImageView
HB_FUNC(SIMAGEAPPLYFROMFILTER) {
  MIKImageView *vista = (MIKImageView *)hb_parnll(1);
  CIFilter *filter = (CIFilter *)hb_parnll(2);

  if (vista && filter) {
    NSImage *src = nil;
    @try {
      src = [vista valueForKey:@"sourceImage"];
    } @catch (NSException *e) {
    }

    if (!src)
      src = [vista image];
    if (!src)
      return;

    CIImage *inputCIImage =
        [[CIImage alloc] initWithData:[src TIFFRepresentation]];
    if (!inputCIImage)
      return;

    [filter setValue:inputCIImage forKey:kCIInputImageKey];

    CIImage *outputCIImage = [filter outputImage];

    if (outputCIImage) {
      CIContext *context = [CIContext contextWithOptions:nil];
      CGImageRef cgImage = [context createCGImage:outputCIImage
                                         fromRect:[outputCIImage extent]];

      if (cgImage) {
        NSImage *finalImage =
            [[NSImage alloc] initWithCGImage:cgImage
                                        size:[outputCIImage extent].size];

        [vista setImage:finalImage];
        [finalImage release];

        CGImageRelease(cgImage);
      }
    }

    [inputCIImage release];
  }
}

HB_FUNC(CIFILTERRELEASE) {
  CIFilter *filter = (CIFilter *)hb_parnll(1);
  if (filter) {
    [filter release];
  }
}

HB_FUNC(SIMAGESETFILTERSTACK) {
  NSView *vista = (NSView *)hb_parnll(1);
  if (!vista)
    return;

  NSMutableArray *filters = nil;

  if (HB_ISARRAY(2)) {
    PHB_ITEM pArray = hb_param(2, HB_IT_ARRAY);
    HB_SIZE nLen = hb_arrayLen(pArray);
    filters = [NSMutableArray arrayWithCapacity:(NSUInteger)nLen];
    for (HB_SIZE i = 1; i <= nLen; i++) {
      // Here we expect numbers (handles) in the array
      HB_LONGLONG hPtr = hb_arrayGetNLL(pArray, i);
      if (hPtr) {
        CIFilter *original = (CIFilter *)hPtr;
        CIFilter *clone = [original copy];
        if (clone) {
          [filters addObject:clone];
          [clone release];
        } else {
          [filters addObject:original];
        }
      }
    }
  }

  if ([vista layer]) {
    [[vista layer] setFilters:filters];
  }
}
