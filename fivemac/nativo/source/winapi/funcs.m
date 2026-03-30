#include "fivemac.h"

#import <AVFoundation/AVFoundation.h>
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#include <IOKit/IOKitLib.h>
#include <mach/mach.h>
#include <stdlib.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <time.h>

#include "hbapi.h"

// Prototipo interno para generar números aleatorios si no están en tu core
// Si hb_rand_fill falla al compilar, puedes usar rand() estándar de C

#define CGAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]
#define DURATION_ANIMATION 3.0

@interface HBVoiceDelegate : NSObject <AVSpeechSynthesizerDelegate>
@property(nonatomic, assign)
    PHB_ITEM pCodeBlock; // Referencia al bloque de Harbour
@end

@implementation HBVoiceDelegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer
    didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
  if (self.pCodeBlock) {
    // Volvemos al hilo principal para ejecutar Harbour de forma segura
    dispatch_async(dispatch_get_main_queue(), ^{
      hb_vmEvalBlock(self.pCodeBlock);
    });
  }
}
@end

static __attribute__((unused)) HBVoiceDelegate *voiceDelegate = nil;

//----------------------------------------------------------------------//

NSString *NumToStr(NSInteger myInteger) {
  int myInt = myInteger;
  NSString *intString = [NSString stringWithFormat:@"%d", myInt];

  return intString;
}

//----------------------------------------------------------------------//

void hb_retstr_NS(NSString *string) {
  if (string != nil) {
    // Convertimos el NSString (UTF16) a una C-String en UTF8
    // [string UTF8String] devuelve un puntero temporal (const char *)
    hb_retc([string UTF8String]);
  } else {
    // Si el objeto es nil, devolvemos una cadena vacía a Harbour
    hb_retc("");
  }
}

//----------------------------------------------------------------------//

NSString *hb_NSSTRING_par(int iParam) {
  // 1. Validación rigurosa del tipo de parámetro
  if (!HB_ISCHAR(iParam)) {
    return @"";
  }
  const char *szText = hb_parc(iParam);
  // 2. Si el puntero es nulo, evitar el crash de Cocoa
  if (szText == NULL) {
    return @"";
  }
  // 3. Intento de conversión rápida (incluye alloc/init/autorelease interno)
  NSString *nsText = [NSString stringWithUTF8String:szText];

  // 4. FALLBACK: Si nsText es nil (p.e. por acentos en formato Windows/ISO)
  // intentamos con Latin1 para no perder el dato y evitar el crash posterior.

  if (nsText == nil) {
    nsText = [NSString stringWithCString:szText
                                encoding:NSISOLatin1StringEncoding];
  }
  return (nsText != nil) ? nsText : @"";
}

//----------------------------------------------------------------------//

id hb_NSObjPar(int iParam) { return (id)hb_parnll(iParam); }

NSAttributedString *hb_NSASTRING_par(int iParam) {
  // 1. Obtenemos el NSString usando tu función segura ya corregida
  NSString *string = hb_NSSTRING_par(iParam);

  // 2. Validación de seguridad
  if (!string || [string length] == 0) {
    return nil;
  }

  // 3. CASO RTF: Detección y conversión segura
  if ([string hasPrefix:@"{\\rtf"]) {
    // Usamos ISOLatin1 como fallback si UTF8 falla para no perder el RTF
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
      data = [string dataUsingEncoding:NSISOLatin1StringEncoding];
    }

    if (data) {
      return [[[NSAttributedString alloc] initWithRTF:data
                                   documentAttributes:NULL] autorelease];
    }
  }

  // 4. CASO TEXTO PLANO: Inicializador moderno (Equivalente al
  // alloc/init/autorelease) Nota: Si usas FiveMac antiguo, mantén el alloc/init
  // para máxima compatibilidad
  return [[[NSAttributedString alloc] initWithString:string] autorelease];
}

HB_FUNC(RANDOMMINMAX) {
  hb_retni((arc4random() % (hb_parni(2) - hb_parni(1) + 1)) + hb_parni(1));
}

HB_FUNC(GET_CPU_ARCHITECTURE) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  int cpu_type;
  size_t size = sizeof(cpu_type);
  NSString *archName = @"Desconocido";

  // Consultamos al kernel de macOS por el tipo de CPU
  if (sysctlbyname("hw.cputype", &cpu_type, &size, NULL, 0) == 0) {
    // CPU_TYPE_ARM64 = 0x0100000c (Apple Silicon)
    // CPU_TYPE_X86_64 = 0x01000007 (Intel)
    if (cpu_type == 0x0100000c) {
      archName = @"Apple Silicon";
    } else if (cpu_type == 0x01000007) {
      archName = @"Intel";
    }
  }

  hb_retc([archName UTF8String]);
  [pool release];
}

HB_FUNC(GET_MEMORY_USAGE) {
  struct mach_task_basic_info info;
  mach_msg_type_number_t count = MACH_TASK_BASIC_INFO_COUNT;

  // Consultamos las estadísticas de la tarea actual al kernel
  if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info,
                &count) == KERN_SUCCESS) {
    // resident_size es la RAM física usada en bytes
    hb_retnll((HB_LONGLONG)info.resident_size);
  } else {
    hb_retnll(0);
  }
}

HB_FUNC(OSVERSION) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // Obtenemos la versión (ej: "Version 14.4 (Build 23E214)")
  NSString *version =
      [[NSProcessInfo processInfo] operatingSystemVersionString];

  if (version) {
    hb_retc([version UTF8String]);
  } else {
    hb_retc("");
  }

  [pool release];
}

HB_FUNC(OSVERSION_NUMERIC) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // Obtenemos la estructura de versión del sistema
  NSOperatingSystemVersion osVersion =
      [[NSProcessInfo processInfo] operatingSystemVersion];

  PHB_ITEM pArray = hb_itemArrayNew(3);
  hb_arraySet(pArray, 1, hb_itemPutNL(NULL, osVersion.majorVersion));
  hb_arraySet(pArray, 2, hb_itemPutNL(NULL, osVersion.minorVersion));
  hb_arraySet(pArray, 3, hb_itemPutNL(NULL, osVersion.patchVersion));

  hb_itemReturnForward(pArray);
  hb_itemRelease(pArray);
  [pool release];
}

HB_FUNC(OSVERSION_NAME) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSInteger major =
      [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion;
  NSString *name = @"Desconocido";

  // Mapeo de versiones modernas
  if (major == 26)
    name = @"Tahoe"; // Lanzado en 2025
  else if (major == 15)
    name = @"Sequoia"; // Lanzado en 2024
  else if (major == 14)
    name = @"Sonoma";
  else if (major == 13)
    name = @"Ventura";
  else if (major == 12)
    name = @"Monterey";
  else if (major == 11)
    name = @"Big Sur";
  else if (major >= 10)
    name = @"Mac OS X / OS X";

  hb_retc([name UTF8String]);
  [pool release];
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

/*
void generate_uuid_bytes(unsigned char *uuid) {
  for (int i = 0; i < 16; i++) {
    uuid[i] = rand() % 256;
  }
  // Ajustes para cumplir con UUID v4 (RFC 4122)
  uuid[6] = (uuid[6] & 0x0F) | 0x40;
  uuid[8] = (uuid[8] & 0x3F) | 0x80;
}

HB_FUNC(HB_UUID) {
  unsigned char uuid[16];
  char szUUID[37];

  // Inicializar semilla si es necesario
  static int seeded = 0;
  if (!seeded) {
    srand((unsigned int)time(NULL));
    seeded = 1;
  }

  generate_uuid_bytes(uuid);

  // Formatear a string: 8-4-4-4-12
  sprintf(
      szUUID,
      "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
      uuid[0], uuid[1], uuid[2], uuid[3], uuid[4], uuid[5], uuid[6], uuid[7],
      uuid[8], uuid[9], uuid[10], uuid[11], uuid[12], uuid[13], uuid[14],
      uuid[15]);

  hb_retc(szUUID);
}
*/

HB_FUNC(VALIDEMAIL) {
  NSString *string = hb_NSSTRING_par(1);
  NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
  NSPredicate *emailTest =
      [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

  hb_retl([emailTest evaluateWithObject:string]);
}

// Declaración global al archivo (fuera de las funciones)
static AVSpeechSynthesizer *g_synth = nil;
static HBVoiceDelegate *g_voiceDelegate = nil;

HB_FUNC(SPEAK) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // Usamos la variable global del archivo
  if (g_synth == nil) {
    g_synth = [[AVSpeechSynthesizer alloc] init];
  }

  NSString *string = hb_NSSTRING_par(1);
  float rate = (float)hb_parnd(2);
  NSString *langCode = (hb_pcount() >= 3) ? hb_NSSTRING_par(3) : @"es-ES";

  if (rate <= 0)
    rate = AVSpeechUtteranceDefaultSpeechRate;
  if (rate > 1.0)
    rate = rate / 400.0f;

  if (string && [string length] > 0) {
    AVSpeechUtterance *utterance =
        [AVSpeechUtterance speechUtteranceWithString:string];
    AVSpeechSynthesisVoice *voice =
        [AVSpeechSynthesisVoice voiceWithLanguage:langCode];

    if (!voice) {
      voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"es-ES"];
    }

    [utterance setVoice:voice];
    [utterance setRate:rate];

    [g_synth speakUtterance:utterance]; // Usamos g_synth
    hb_retl(YES);
  } else {
    hb_retl(NO);
  }

  [pool release];
}

HB_FUNC(SPEAK_STOP) {
  // Ahora esta función SI ve a g_synth y el error desaparece
  if (g_synth && [g_synth isSpeaking]) {
    [g_synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    hb_retl(YES);
  } else {
    hb_retl(NO);
  }
}

HB_FUNC(SPEAK_CALLBACK) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // Inicialización única del singleton manual
  if (g_synth == nil) {
    g_synth = [[AVSpeechSynthesizer alloc] init];
    g_voiceDelegate = [[HBVoiceDelegate alloc] init];
    [g_synth setDelegate:g_voiceDelegate];
  }

  NSString *string = hb_NSSTRING_par(1);
  PHB_ITEM pBlock = hb_param(2, HB_IT_BLOCK);

  if (pBlock) {
    if (g_voiceDelegate.pCodeBlock)
      hb_itemRelease(g_voiceDelegate.pCodeBlock);
    g_voiceDelegate.pCodeBlock = hb_itemPutPtr(NULL, pBlock);
  }

  if (string && [string length] > 0) {
    AVSpeechUtterance *utterance =
        [AVSpeechUtterance speechUtteranceWithString:string];
    [utterance setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:@"es-ES"]];
    [g_synth speakUtterance:utterance];
  }

  [pool release];
}

HB_FUNC(SPEAK_GETVOICES) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // Obtener todas las voces instaladas
  NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
  PHB_ITEM pMainArray = hb_itemArrayNew(0);

  for (AVSpeechSynthesisVoice *voice in voices) {
    PHB_ITEM pSubArray = hb_itemArrayNew(3);

    hb_arraySet(pSubArray, 1, hb_itemPutC(NULL, [[voice name] UTF8String]));
    hb_arraySet(pSubArray, 2, hb_itemPutC(NULL, [[voice language] UTF8String]));
    hb_arraySet(pSubArray, 3,
                hb_itemPutC(NULL, [[voice identifier] UTF8String]));

    hb_arrayAddForward(pMainArray, pSubArray);
    hb_itemRelease(pSubArray);
  }

  hb_itemReturnForward(pMainArray);
  hb_itemRelease(pMainArray);
  [pool release];
}

HB_FUNC(SLEEP) {
  // Convertimos milisegundos de Harbour a segundos de macOS
  [NSThread sleepForTimeInterval:(double)hb_parnd(1) / 1000.0];
}

HB_FUNC(SLEEP_WITH_PROGRESS) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  double milliseconds = hb_parnd(1);
  if (milliseconds <= 0) {
    [pool release];
    return;
  }

  // 1. Crear ventana flotante (Panel)
  NSRect frame = NSMakeRect(0, 0, 200, 80);
  NSWindow *window =
      [[NSWindow alloc] initWithContentRect:frame
                                  styleMask:NSWindowStyleMaskTitled
                                    backing:NSBackingStoreBuffered
                                      defer:NO];
  [window center];
  [window setTitle:@"Espere... (ESC para cancelar)"];

  // 2. Añadir el Indicador de Progreso (Spinner)
  NSProgressIndicator *spinner =
      [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(85, 20, 32, 32)];
  [spinner setStyle:NSProgressIndicatorStyleSpinning];
  [spinner setIndeterminate:YES];
  [spinner setDisplayedWhenStopped:NO];
  [spinner startAnimation:nil];

  [[window contentView] addSubview:spinner];
  [window makeKeyAndOrderFront:nil];

  // 3. Bucle de espera con detección de ESC
  NSDate *limitDate =
      [NSDate dateWithTimeIntervalSinceNow:(milliseconds / 1000.0)];
  NSRunLoop *currentLoop = [NSRunLoop currentRunLoop];
  BOOL cancelled = NO;

  while ([limitDate timeIntervalSinceNow] > 0 && !cancelled) {
    NSAutoreleasePool *innerPool = [[NSAutoreleasePool alloc] init];

    // Procesar eventos
    [currentLoop runMode:NSDefaultRunLoopMode
              beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    // Chequear si se pulsó ESC (Key code 53)
    // kCGEventSourceStateCombinedSessionState detecta la pulsación actual
    if (CGEventSourceKeyState(kCGEventSourceStateCombinedSessionState, 53)) {
      cancelled = YES;
    }

    [innerPool release];
  }

  // 4. Limpieza Manual (Reglas No-ARC)
  [spinner stopAnimation:nil];
  [spinner release];
  [window orderOut:nil];
  [window release];

  hb_retl(
      !cancelled); // Devolvemos .T. si terminó por tiempo, .F. si se canceló
  [pool release];
}

HB_FUNC(NSSTRINGTOSTRING) {
  NSString *string = (NSString *)hb_parnll(1);

  // Verificamos que el objeto exista antes de pedirle el texto
  if (string) {
    hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
  } else {
    hb_retc(""); // Devolvemos cadena vacía si el puntero es nulo
  }
}

HB_FUNC(STRINGTONSTRING) {
  // Sin autorelease: el objeto se queda en memoria con un contador de 1
  NSString *string =
      [[NSString alloc] initWithCString:HB_ISCHAR(1) ? hb_parc(1) : ""
                               encoding:hb_parnl(2)];

  hb_retnll((HB_LONGLONG)string);
}

// Y necesitarás esta para cuando termines de usarlo en Harbour:
HB_FUNC(RELEASE_NSTRING) {
  NSString *string = (NSString *)hb_parnll(1);
  if (string) {
    [string release];
  }
}

HB_FUNC(NSSTRINGCANCONVERENCODE) {
  NSString *string = (NSString *)hb_parnll(1);

  // Verificamos que el puntero no sea NULL antes de llamar al método
  if (string) {
    hb_retl([string canBeConvertedToEncoding:(NSStringEncoding)hb_parnl(2)]);
  } else {
    hb_retl(NO);
  }
}

HB_FUNC(GETSERIALNUMBER) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  const char *cSerial = ""; // Valor por defecto

  // kIOMainPortDefault es el estándar desde macOS 12
  io_service_t platformExpert = IOServiceGetMatchingService(
      kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"));

  if (platformExpert) {
    CFTypeRef serialNumber = IORegistryEntryCreateCFProperty(
        platformExpert, CFSTR(kIOPlatformSerialNumberKey), kCFAllocatorDefault,
        0);

    if (serialNumber) {
      // Convertimos a C string antes de liberar el objeto de Apple
      cSerial = [((NSString *)serialNumber) UTF8String];

      // Harbour copia el string inmediatamente con hb_retc
      hb_retc(cSerial);

      // REGLA NO-ARC: Liberamos lo que creamos con 'Create'
      CFRelease(serialNumber);
    } else {
      hb_retc("");
    }

    IOObjectRelease(platformExpert);
  } else {
    hb_retc("");
  }

  [pool release];
}

//----------------------------------------------------------//

HB_FUNC(NSLOG) { NSLog(@"%@", hb_NSSTRING_par(1)); }

HB_FUNC(NSNLOG) { NSLog(@"%i", hb_parni(1)); }

HB_FUNC(ISCAPSLOCKDOWN) {
  bool wasCapsLockDown =
      CGEventSourceKeyState(kCGEventSourceStateHIDSystemState, 57);
  hb_retl((BOOL)wasCapsLockDown);
}

HB_FUNC(FMSAVESCREEN) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSString *path = hb_NSSTRING_par(1);
  BOOL success = NO;

  if (path && [path length] > 0) {
    // 1. Configurar captura interactiva (-i) y con cursor (-m)
    NSArray *args = [NSArray arrayWithObjects:@"-i", @"-m", path, nil];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/sbin/screencapture"];
    [task setArguments:args];

    [task launch];
    [task waitUntilExit];

    // 2. Si el proceso terminó correctamente (el usuario no canceló con ESC)
    if ([task terminationStatus] == 0) {
      success = YES;

      // Sonido de confirmación
      [[NSSound soundNamed:@"Hero"] play];

      // 3. REVELAR EN EL FINDER (Método moderno)
      // activateFileViewerSelectingURLs requiere un NSArray de URLs
      NSURL *fileURL = [NSURL fileURLWithPath:path];
      [[NSWorkspace sharedWorkspace]
          activateFileViewerSelectingURLs:[NSArray arrayWithObject:fileURL]];
    }

    [task release];
    hb_retl(success);
  } else {
    hb_retl(NO);
  }

  [pool release];
}

HB_FUNC(ANIMASHAKE) {}

HB_FUNC(APPTERMINATE) {
  // [ NSApp terminate : nil ];
  exit(0);
}

//----------------------------------------------------------------------//

HB_FUNC(NSRELEASE) {
  id obj = (id)hb_parnll(1);
  if (obj != nil) {
    [obj release];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(NSAUTORELEASEPOOL_BEGIN) {
  // Creamos un nuevo pool y lo devolvemos como puntero (HB_LONG)
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  hb_retnll((HB_LONG)pool);
}

//----------------------------------------------------------------------//

HB_FUNC(NSAUTORELEASEPOOL_END) {
  // Recuperamos el puntero del pool y lo liberamos
  NSAutoreleasePool *pool = (NSAutoreleasePool *)hb_parnll(1);
  if (pool != nil) {
    [pool release];
  }
}

//----------------------------------------------------------------------//

NSSize GetStringSize(NSString *string, float width, NSFont *font) {
  if (string == nil || [string length] == 0) {
    return NSZeroSize;
  }

  NSSize containerSize = NSMakeSize(width, FLT_MAX);
  NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:string];
  NSTextContainer *textContainer =
      [[NSTextContainer alloc] initWithContainerSize:containerSize];
  NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];

  [layoutManager addTextContainer:textContainer];
  [textStorage addLayoutManager:layoutManager];
  [textStorage addAttribute:NSFontAttributeName
                      value:font
                      range:NSMakeRange(0, [textStorage length])];
  [textContainer setLineFragmentPadding:0.0];
  [layoutManager glyphRangeForTextContainer:textContainer];

  NSRect usedRect = [layoutManager usedRectForTextContainer:textContainer];
  NSSize resultSize = usedRect.size;
  if (resultSize.width < width)
    resultSize.width += 5;
  resultSize.height += 2; // Margen de seguridad vertical

  [layoutManager release];
  [textContainer release];
  [textStorage release];

  return resultSize;
}
