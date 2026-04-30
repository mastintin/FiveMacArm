#import <Vision/Vision.h>
#include <fivemac.h>

HB_FUNC(NSIMGTEXTOCR) {
  NSImage *image = (NSImage *)hb_parnll(1);
  NSString *lang = HB_ISCHAR(2) ? hb_NSSTRING_par(2) : nil;

  if (!image) {
    hb_retc("");
    return;
  }

  @try {
    CGImageRef cgImage = [image CGImageForProposedRect:NULL
                                               context:nil
                                                 hints:nil];
    if (!cgImage) {
      hb_retc("");
      return;
    }

    VNImageRequestHandler *handler =
        [[VNImageRequestHandler alloc] initWithCGImage:cgImage options:@{}];

    __block NSMutableString *recognizedText = [NSMutableString string];

    VNRecognizeTextRequest *request = [[VNRecognizeTextRequest alloc]
        initWithCompletionHandler:^(VNRequest *_Nonnull request,
                                    NSError *_Nullable error) {
          if (error) {
            NSLog(@"Vision OCR Request Error: %@", error.localizedDescription);
            return;
          }

          for (VNRecognizedTextObservation *observation in request.results) {
            VNRecognizedText *topCandidate =
                [[observation topCandidates:1] firstObject];
            if (topCandidate) {
              [recognizedText appendFormat:@"%@\n", topCandidate.string];
            }
          }
        }];

    request.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
    if (lang)
      request.recognitionLanguages = @[ lang ];

    NSError *error = nil;
    [handler performRequests:@[ request ] error:&error];

    if (error) {
      NSLog(@"Vision OCR Performance Error: %@", error.localizedDescription);
    }

    hb_retc([recognizedText UTF8String]);
  } @catch (NSException *exception) {
    NSLog(@"Vision OCR Exception: %@", exception.reason);
    hb_retc("");
  }
}

HB_FUNC(NSIMGCLASSIFY) {
  NSImage *image = (NSImage *)hb_parnll(1);

  if (!image) {
    hb_reta(0);
    return;
  }

  @try {
    CGImageRef cgImage = [image CGImageForProposedRect:NULL
                                               context:nil
                                                 hints:nil];
    if (!cgImage) {
      hb_reta(0);
      return;
    }

    VNImageRequestHandler *handler =
        [[VNImageRequestHandler alloc] initWithCGImage:cgImage options:@{}];

    VNClassifyImageRequest *request = [[VNClassifyImageRequest alloc] init];

    NSError *error = nil;
    [handler performRequests:@[ request ] error:&error];

    if (error || !request.results) {
      hb_reta(0);
      return;
    }

    NSUInteger count = [request.results count];
    if (count > 5) // Limit to only top 5 for maximum stability
      count = 5;

    PHB_ITEM pArray = hb_itemArrayNew(count);

    for (NSUInteger i = 0; i < count; i++) {
      VNClassificationObservation *obs = [request.results objectAtIndex:i];
      PHB_ITEM pSub = hb_itemArrayNew(2);

      NSString *identifier = [obs identifier];
      if (identifier) {
        PHB_ITEM pId = hb_itemPutC(NULL, [identifier UTF8String]);
        hb_itemArrayPut(pSub, 1, pId);
        hb_itemRelease(pId);
      } else {
        PHB_ITEM pId = hb_itemPutC(NULL, "");
        hb_itemArrayPut(pSub, 1, pId);
        hb_itemRelease(pId);
      }

      PHB_ITEM pConf = hb_itemPutND(NULL, (double)[obs confidence]);
      hb_itemArrayPut(pSub, 2, pConf);
      hb_itemRelease(pConf);

      hb_itemArrayPut(pArray, i + 1, pSub);
      hb_itemRelease(pSub);
    }

    hb_itemReturnRelease(pArray);

  } @catch (NSException *exception) {
    NSLog(@"NSIMGCLASSIFY: Exception: %@", exception.reason);
    hb_reta(0);
  }
}
