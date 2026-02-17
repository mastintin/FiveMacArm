#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#include <IOKit/IOKitLib.h>
#include <fivemac.h>

#define CGAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]
#define DURATION_ANIMATION 3.0

/*
@interface NSApplication()
- (void) speakString: (NSString *) string;
// NSApp speaks!
@end
*/

NSString *NumToStr(NSInteger myInteger) {
  int myInt = myInteger;
  NSString *intString = [NSString stringWithFormat:@"%d", myInt];

  return intString;
}

NSString *hb_NSSTRING_par(int iParam) // NSUTF8StringEncoding
{
  return [[[NSString alloc]
      initWithCString:HB_ISCHAR(iParam) ? hb_parc(iParam) : ""
             encoding:NSUTF8StringEncoding] autorelease];
}

NSAttributedString *hb_NSASTRING_par(int iParam) {
  NSString *string = [[[NSString alloc]
      initWithCString:HB_ISCHAR(iParam) ? hb_parc(iParam) : ""
             encoding:NSUTF8StringEncoding] autorelease];

  NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

  return [[[NSAttributedString alloc] initWithRTF:data
                               documentAttributes:NULL] autorelease];

  //    return  [ [ NSAttributedString alloc ] initWithString: string ] ;
}

HB_FUNC(RANDOMMINMAX) {
  hb_retni((arc4random() % (hb_parni(2) - hb_parni(1) + 1)) + hb_parni(1));
}

HB_FUNC(OSVERSION) {

  NSString *version =
      [[NSProcessInfo processInfo] operatingSystemVersionString];

  hb_retc([version cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(SDKVERSION) {
  NSPipe *outPipe = [NSPipe pipe];
  NSTask *task = [[NSTask alloc] init];

  [task setLaunchPath:@"/usr/bin/xcrun"];
  [task setArguments:[NSArray arrayWithObjects:@"--show-sdk-version", nil]];
  [task setStandardOutput:outPipe];

  [task launch];
  [task waitUntilExit];

  NSData *data = [[outPipe fileHandleForReading] readDataToEndOfFile];
  NSString *version_raw = [[NSString alloc] initWithData:data
                                                encoding:NSUTF8StringEncoding];

  NSString *version = [version_raw
      stringByTrimmingCharactersInSet:[NSCharacterSet
                                          whitespaceAndNewlineCharacterSet]];

  hb_retc([version cStringUsingEncoding:NSUTF8StringEncoding]);

  [version_raw release];
  [task release];
}

HB_FUNC(VALIDEMAIL) {
  NSString *string = hb_NSSTRING_par(1);
  NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
  NSPredicate *emailTest =
      [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

  hb_retl([emailTest evaluateWithObject:string]);
}

HB_FUNC(SPEAK) {
  static AVSpeechSynthesizer *synth = nil;

  if (synth == nil) {
    synth = [[AVSpeechSynthesizer alloc] init];
  }

  NSString *string = hb_NSSTRING_par(1);
  float rate = hb_parnd(2);

  if (rate == 0) {
    rate = 0.5; // Default for AVSpeechUtterance (0.0 to 1.0)
  }

  // AVSpeechUtterance rate is between 0.0 and 1.0
  // If user passes values like 200 (from previous motor), scale it down
  if (rate > 1.0) {
    rate = rate / 400.0; // Scaled to reasonable range
  }

  AVSpeechUtterance *utterance =
      [AVSpeechUtterance speechUtteranceWithString:string];
  utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"es-ES"];
  utterance.rate = rate;

  [synth speakUtterance:utterance];
}

HB_FUNC(SLEEP) { [NSThread sleepForTimeInterval:hb_parnl(1) / 1.0]; }

HB_FUNC(NSSTRINGTOSTRING) {
  NSString *string = (NSString *)hb_parnll(1);
  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(STRINGTONSTRING) {
  NSString *string =
      [[[NSString alloc] initWithCString:HB_ISCHAR(1) ? hb_parc(1) : ""
                                encoding:hb_parnl(2)] autorelease];
  hb_retnll((HB_LONGLONG)string);
}

HB_FUNC(NSSTRINGCANCONVERENCODE) {
  NSString *string = (NSString *)hb_parnll(1);
  hb_retl([string canBeConvertedToEncoding:hb_parnl(2)]);
}

HB_FUNC(GETSERIALNUMBER) {
  NSString *serial = nil;
  io_service_t platformExpert = IOServiceGetMatchingService(
      kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
  if (platformExpert) {
    CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(
        platformExpert, CFSTR(kIOPlatformSerialNumberKey), kCFAllocatorDefault,
        0);
    if (serialNumberAsCFString) {
      serial = CFBridgingRelease(serialNumberAsCFString);
    }

    IOObjectRelease(platformExpert);
  }
  hb_retc(serial ? [serial cStringUsingEncoding:NSUTF8StringEncoding] : "");
}

HB_FUNC(NSLOG) { NSLog(@"%@", hb_NSSTRING_par(1)); }

HB_FUNC(NSNLOG) { NSLog(@"%i", hb_parni(1)); }

HB_FUNC(ISCAPSLOCKDOWN) {
  bool wasCapsLockDown =
      CGEventSourceKeyState(kCGEventSourceStateHIDSystemState, 57);
  hb_retl((BOOL)wasCapsLockDown);
}

HB_FUNC(FMSAVESCREEN) {

  NSString *cCapName = hb_NSSTRING_par(1);

  NSArray *aArguments = [NSArray arrayWithObjects:@"-m", @"-P", cCapName, nil];
  NSTask *captura = [[NSTask alloc] init];

  [captura setLaunchPath:@"/usr/sbin/screencapture"];
  [captura setArguments:aArguments];

  NSPipe *pipe = [NSPipe pipe];
  [captura setStandardOutput:pipe];
  [captura setStandardError:pipe];

  [captura launch];
  [captura release];

  /*
   static func capture(completionHandler: @escaping ([String]) -> Void) {
       let outputPaths = paths
       let process = Process()
       process.launchPath = "/usr/sbin/screencapture"
       process.arguments = ["-x"] + outputPaths
       process.standardOutput = Pipe()
       process.terminationHandler = { task in
           guard task.terminationStatus == 0 else {
               return
           }

           completionHandler(outputPaths)
       }
       process.launch()
   }
   */
}

/*
HB_FUNC( SAVESCREEN )
{

    // Creamos la captura de pantalla...
    CGImageRef image = CGAutorelease(CGWindowListCreateImage(CGRectInfinite,
                                                               kCGWindowListOptionOnScreenOnly,
                                                               kCGNullWindowID,
                                                               kCGWindowImageDefault));

    //...y la guardamos.

    NSFileManager *fileManager = [NSFileManager defaultManager];
    // guardaremos la captura en formato .tiff
    NSString *extCapture = @".tiff";
    NSString *numCapture = [[NSString alloc] init];
    // Guardaremos la captura en el escritorio.
     NSString *pathCapture = [NSHomeDirectory() stringByAppendingPathComponent:
@"Desktop"]; BOOL saved = NO; int n = 0;

        while (!saved) {
            numCapture = [[[NSNumber alloc] initWithInt: n] stringValue];
            // El nombre por defecto de la captura + un nââ«mero de
captura + su extensiââ¥n. NSString* nameCapture = [[@"CapturaPantalla"
stringByAppendingString: numCapture] stringByAppendingString: extCapture];

            // Comprobamos si ya existe una captura con un determinado
nââ«mero de captura en el
            // escritorio. Si no existe la guardamos, si existe aumentamos el
nââ«mero de captura
            // y comprobamos de nuevo.
            if ([fileManager fileExistsAtPath: [pathCapture
stringByAppendingPathComponent: nameCapture]]) n++; else { NSBitmapImageRep
*capture = [[NSBitmapImageRep alloc] initWithCGImage: image]; NSData *dataImage
= [capture TIFFRepresentation];

                saved = [dataImage writeToFile: [pathCapture
stringByAppendingPathComponent: nameCapture] atomically: YES];
            }
        }

     hb_retl( saved );
 }

*/

HB_FUNC(ANIMASHAKE) {}

HB_FUNC(APPTERMINATE) {
  // [ NSApp terminate : nil ];
  exit(0);
}
