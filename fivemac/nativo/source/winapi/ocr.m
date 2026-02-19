#import <Cocoa/Cocoa.h>
#import <Vision/Vision.h>
#include <fivemac.h>

// HB_FUNC( NSIMGTEXTOCR ) // ( hImage, cLanguageCode )
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
