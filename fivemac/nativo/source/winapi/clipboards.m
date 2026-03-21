#import "Quartz/Quartz.h"
#import <QuickLookUI/QuickLookUI.h>
#import <ScreenCaptureKit/ScreenCaptureKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#include <fivemac.h>

@interface QLPreviewDataSource : NSObject <QLPreviewPanelDataSource>
@property(retain) NSURL *fileURL;
@end

@implementation QLPreviewDataSource

// Cambiado: 'PreviewPanel' en lugar de 'PreviewController'
- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
  return 1;
}

// Cambiado: 'PreviewPanel' en lugar de 'PreviewController'
- (id<QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel
               previewItemAtIndex:(NSInteger)index {
  return self.fileURL;
}

- (void)dealloc {
  [_fileURL release];
  [super dealloc];
}
@end

HB_FUNC(CLIPBOARDPREVIEWIMAGE) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // Obtenemos la ruta desde Harbour (ej. "Downloads/foto.png")
  NSString *path = hb_NSSTRING_par(1);

  if (path && [path length] > 0) {
    NSURL *url = [NSURL fileURLWithPath:path];

    // Obtenemos la instancia compartida del panel de Quick Look
    QLPreviewPanel *panel = [QLPreviewPanel sharedPreviewPanel];

    // Creamos nuestro suministrador de datos (no-ARC)
    QLPreviewDataSource *ds = [[[QLPreviewDataSource alloc] init] autorelease];
    ds.fileURL =
        url; // El setter 'retain' definido arriba se encarga de la copia

    // Configuramos el panel
    [panel setDataSource:ds];

    // Mostramos el panel al frente
    [panel makeKeyAndOrderFront:nil];

    hb_retl(YES);
  } else {
    hb_retl(NO);
  }

  [pool release];
}

//----------------------------------------------------------------------------//

HB_FUNC(CLIPBOARDNEW) {
  // Singleton, no requiere pool
  hb_retnll((HB_LONGLONG)[NSPasteboard generalPasteboard]);
}

HB_FUNC(CLIPBOARDCLEAR) {
  // Obtenemos el puntero enviado desde Harbour
  NSPasteboard *pasteBoard = (NSPasteboard *)hb_parnll(1);

  // Verificación de seguridad: solo procedemos si el puntero no es NULL
  if (pasteBoard) {
    [pasteBoard clearContents];
    hb_retl(YES); // Opcional: devolvemos .T. si se pudo limpiar
  } else {
    hb_retl(NO); // Opcional: devolvemos .F. si el puntero era inválido
  }
}

HB_FUNC(SETCLIPBOARDDATA) {
  // 1. Creamos un pool local para limpiar los NSArray temporales
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];

  NSPasteboard *pasteBoard = (NSPasteboard *)hb_parnll(1);
  int iType = hb_parni(2);

  if (pasteBoard) {
    [pasteBoard clearContents];

    // Los objetos creados con [NSArray arrayWithObject:] son autoreleased.
    // El localPool los liberará al final de esta función.
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

  // 2. Liberamos el pool y toda la memoria temporal usada arriba
  [localPool release];
}

HB_FUNC(CLIPBOARDCOUNT) {
  // 1. Pool local para los objetos temporales que devuelva el pasteboard
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // 2. Cast simple para No-ARC
  NSPasteboard *pb = (NSPasteboard *)hb_parnll(1);
  NSInteger count = 0;

  if (pb) {
    // 3. 'pasteboardItems' devuelve un NSArray con los elementos
    // Es un método de clase, por lo que el array es autoreleased.
    NSArray *items = [pb pasteboardItems];
    count = [items count];
  }

  // 4. Retornamos el número a Harbour
  hb_retni((int)count);

  // 5. Limpiamos la memoria
  [pool release];
}

HB_FUNC(CLIPBOARDCOPYFILE) {
  // 1. Pool local para gestionar los objetos NSURL temporales
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // 2. Obtenemos la ruta enviada desde Harbour
  NSString *path = hb_NSSTRING_par(1);
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  BOOL success = NO;

  if (path && [path length] > 0) {
    // 3. Creamos el objeto URL del archivo (es autoreleased)
    NSURL *fileURL = [NSURL fileURLWithPath:path];

    if (fileURL) {
      // 4. Limpiamos el portapapeles antes de escribir
      [pb clearContents];

      // 5. Escribimos el objeto URL. El Finder reconocerá esto como un archivo.
      // Usamos un array autoreleased [NSArray arrayWithObject:]
      success = [pb writeObjects:[NSArray arrayWithObject:fileURL]];
    }
  }

  // 6. Devolvemos el resultado a Harbour y liberamos el pool
  hb_retl(success);
  [pool release];
}

HB_FUNC(CLIPBOARDCOPYIMAGE) {
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];

  NSPasteboard *pb = (NSPasteboard *)hb_parnll(1);
  NSImage *image = (NSImage *)hb_parnll(2);
  BOOL success = NO;

  if (pb && image) {
    [pb clearContents];

    // Al usar writeObjects con la imagen directamente, macOS coloca
    // automáticamente múltiples formatos (TIFF, PNG, etc.) para máxima
    // compatibilidad. [NSArray arrayWithObject:] es autoreleased.
    success = [pb writeObjects:[NSArray arrayWithObject:image]];
  }

  hb_retl(success);
  [localPool release];
}

HB_FUNC(CLIPBOARDCOPYPNG) {
  // 1. Pool local: Vital al manejar imágenes (NSData/NSBitmapImageRep)
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];

  NSPasteboard *pasteBoard = (NSPasteboard *)hb_parnll(1);
  NSImage *image = (NSImage *)hb_parnll(2);
  bool lResult = false;

  if (pasteBoard && image) {
    // CGImageRef NO es un objeto de Objective-C (es CoreGraphics)
    // No necesita release porque no lo estamos 'creando', solo obteniendo una
    // referencia
    CGImageRef CGImage = [image CGImageForProposedRect:nil
                                               context:nil
                                                 hints:nil];

    // NSBitmapImageRep: Usamos alloc/init/autorelease (Correcto para no-ARC)
    NSBitmapImageRep *rep =
        [[[NSBitmapImageRep alloc] initWithCGImage:CGImage] autorelease];

    // NSDictionary y NSNumber: Métodos de clase (son autoreleased por defecto)
    NSDictionary *dict =
        [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.5]
                                    forKey:NSImageCompressionFactor];

    // NSData: El método 'representationUsingType' devuelve un objeto
    // autoreleased
    NSData *data = [rep representationUsingType:NSBitmapImageFileTypePNG
                                     properties:dict];

    if (data) {
      [pasteBoard clearContents];
      lResult = [pasteBoard setData:data forType:NSPasteboardTypePNG];
    }
  }

  hb_retl(lResult);

  // 2. Limpieza inmediata de toda la memoria de la imagen
  [localPool release];
}

HB_FUNC(CLIPBOARDCOPYSTRING) {
  // 1. Pool manual para limpiar el string temporal
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // 2. Cast directo (No-ARC)
  NSPasteboard *pb = (NSPasteboard *)hb_parnll(1);

  // 3. Usamos tu función optimizada que devuelve un objeto autoreleased
  NSString *string = hb_NSSTRING_par(2);
  BOOL success = NO;

  if (pb && string) {
    [pb clearContents];
    success = [pb setString:string forType:NSPasteboardTypeString];
  }

  // 4. Retornamos el resultado
  hb_retl(success);

  // 5. Limpiamos la memoria
  [pool release];
}

HB_FUNC(CLIPBOARDPASTESTRING) {
  // 1. Pool local para el string que devuelva el portapapeles
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // 2. Cast simple sin __bridge
  NSPasteboard *pb = (NSPasteboard *)hb_parnll(1);

  if (pb) {
    // 3. Obtenemos el string (es un objeto autoreleased por el sistema)
    NSString *string = [pb stringForType:NSPasteboardTypeString];

    // 4. Retornamos a Harbour ANTES de vaciar el pool
    // hb_retc copia el contenido, así que es seguro liberar el objeto después
    hb_retc(string ? [string UTF8String] : "");
  } else {
    hb_retc("");
  }

  // 5. Limpieza de memoria temporal
  [pool release];
}

HB_FUNC(CLIPBOARDGETNAME) {
  // 1. Pool local para el string que devuelve [pb name]
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // 2. Cast simple sin __bridge
  NSPasteboard *pb = (NSPasteboard *)hb_parnll(1);

  if (pb) {
    // 3. Obtenemos el nombre (es un objeto autoreleased)
    NSString *name = [pb name];

    // 4. Retornamos a Harbour antes de vaciar el pool
    hb_retc(name ? [name UTF8String] : "");
  } else {
    hb_retc("");
  }

  // 5. Liberamos memoria temporal
  [pool release];
}

//----------------------------------------------------------------------------//

HB_FUNC(COPYPASTEBOARDSTRING) {
  // 1. Pool local para el string temporal
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // 2. Creamos el string (ya es autoreleased por ser método de clase)
  const char *cStr = (hb_pcount() >= 1) ? hb_parc(1) : "";
  NSString *string = [NSString stringWithUTF8String:cStr];

  // 3. Acceso al singleton (no requiere release)
  NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];

  if (pasteBoard && string) {
    [pasteBoard clearContents];
    [pasteBoard setString:string forType:NSPasteboardTypeString];
  }

  // 4. Limpieza de memoria
  [pool release];

  hb_ret();
}

HB_FUNC(PASTEPASTEBOARDSTRING) {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
  NSString *string = [pasteBoard stringForType:NSPasteboardTypeString];
  if (string) {
    hb_retc([string UTF8String]);
  } else {
    hb_retc("");
  }

  // 5. Limpiamos la memoria temporal
  [pool release];
}

HB_FUNC(CLIPBOARDGETEXTENSIONS) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSPasteboard *pb = (NSPasteboard *)hb_parnll(1);
  PHB_ITEM pMainArray = hb_itemArrayNew(0);

  if (pb) {
    NSArray *items = [pb pasteboardItems];

    for (NSPasteboardItem *item in items) {
      NSString *urlString = [item stringForType:@"public.file-url"];

      if (urlString) {
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *path = [url path];
        NSString *extension = [path pathExtension];

        if (path && [path length] > 0) {
          // MÉTODO MODERNO (macOS 11+): Sin warnings
          UTType *type = [UTType typeWithFilenameExtension:extension];
          BOOL isImage = (type && [type conformsToType:UTTypeImage]);

          PHB_ITEM pSubArray = hb_itemArrayNew(3);
          hb_arraySet(pSubArray, 1, hb_itemPutC(NULL, [path UTF8String]));
          hb_arraySet(pSubArray, 2, hb_itemPutC(NULL, [extension UTF8String]));
          hb_arraySet(pSubArray, 3, hb_itemPutL(NULL, isImage));

          hb_arrayAddForward(pMainArray, pSubArray);
          hb_itemRelease(pSubArray);
        }
      }
    }
  }

  hb_itemReturnForward(pMainArray);
  hb_itemRelease(pMainArray);
  [pool release];
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

HB_FUNC(HASSCREENRECORDINGPERMISSION) {
  if (@available(macOS 10.15, *)) {
    hb_retl(CGPreflightScreenCaptureAccess());
  } else {
    hb_retl(YES);
  }
}

HB_FUNC(REQUESTSCREENRECORDINGPERMISSION) {
  if (@available(macOS 10.15, *)) {
    hb_retl(CGRequestScreenCaptureAccess());
  } else {
    hb_retl(YES);
  }
}
