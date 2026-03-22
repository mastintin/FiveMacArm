#import <Cocoa/Cocoa.h>
#include <fivemac.h>

@interface NSImageSymbolConfiguration (ModernAPIs)
+ (NSImageSymbolConfiguration *)configurationWithPreferringMulticolor;
+ (NSImageSymbolConfiguration *)configurationWithHierarchicalColor:
    (NSColor *)color;
+ (NSImageSymbolConfiguration *)configurationWithPaletteColors:
    (NSArray<NSColor *> *)colors;
@end

void MsgAlert(NSString *, NSString *messageText);

static PHB_SYMB symFMH = NULL;

@interface ImageView : NSImageView {
}
- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseUp:(NSEvent *)theEvent;

@end

@implementation ImageView

FIVEMAC_DRAGDROP_METHODS

- (void)mouseDown:(NSEvent *)theEvent {

  NSPoint point = [theEvent locationInWindow];

  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)[self window]);
  hb_vmPushLong(WM_LBUTTONDOWN);
  hb_vmPushNLL((HB_LONGLONG)self);
  hb_vmPushLong(point.y);
  hb_vmPushLong(point.x);
  hb_vmDo(5);
}

- (void)mouseUp:(NSEvent *)theEvent {
  NSPoint point = [theEvent locationInWindow];

  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)[self window]);
  hb_vmPushLong(WM_LBUTTONUP);
  hb_vmPushNLL((HB_LONGLONG)self);
  hb_vmPushLong(point.y);
  hb_vmPushLong(point.x);
  hb_vmDo(5);
}

@end

//--------------------------------------------------------------------------------//

void ImgResize(NSImage *image, int nWidth, int nHeight) {
  NSSize newSize;
  newSize.width = nWidth;
  if (0 == nHeight)
    newSize.height = nWidth;
  else
    newSize.height = nHeight;

  image.size = newSize;
}

//--------------------------------------------------------------------------------//

HB_FUNC(IMGCREATE) // hWnd
{
  // Añadimos autorelease al crear la instancia
  ImageView *image = [[[ImageView alloc]
      initWithFrame:NSMakeRect((CGFloat)hb_parnd(2), (CGFloat)hb_parnd(1),
                               (CGFloat)hb_parnd(3), (CGFloat)hb_parnd(4))]
      autorelease];

  NSWindow *window = (NSWindow *)hb_parnll(5);

  [GetView(window) addSubview:image];

  hb_retnll((HB_LONGLONG)image);
}

HB_FUNC(IMAGEVIEWRELEASE) {
  NSImageView *imageView = (NSImageView *)hb_parnll(1);

  if (imageView) {
    [imageView removeFromSuperview];
  }
}

//--------------------------------------------------------------------------------//


HB_FUNC(IMGRETAIN) {
  NSImage *image = (NSImage *)hb_parnll(1);

  if (image) {
    [image retain]; // Incrementamos el contador de referencias (+1)
    hb_retnll((HB_LONGLONG)image);
  } else {
    hb_retnll(0);
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(IMGRELEASE) {
  NSImage *image = (NSImage *)hb_parnll(1);
  if (image) {
    [image release]; // Esto compensa el retain de NSIMAGEFROMNAME
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(IMGSETFILE) {
  NSImageView *imageView = (NSImageView *)hb_parnll(1);
  NSString *path = hb_NSSTRING_par(2);

  if (imageView && path) {
    // 1. Creamos la imagen con autorelease para cumplir con No-ARC
    NSImage *image =
        [[[NSImage alloc] initWithContentsOfFile:path] autorelease];

    if (image) {
      // 2. Ajustamos el tamaño del objeto NSImage
      ImgResize(image, (int)hb_parnl(3), (int)hb_parnl(4));

      // 3. Lo asignamos al control (el control hace su propio 'retain')
      [imageView setImage:image];

      // 4. Opcional: ponerle nombre para caché interna de macOS
      [image setName:path];
    }
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(IMGSETNSIMAGE) {
  NSImageView *image = (NSImageView *)hb_parnll(1);
  NSImage *hImg = (NSImage *)hb_parnll(2);

  [image setImage:hImg];
}

//--------------------------------------------------------------------------------//

HB_FUNC(IMGGETNSIMAGE) {
  NSImageView *imageView = (NSImageView *)hb_parnll(1);
  NSImage *image = [imageView image];

  if (image) {
    [image retain]; // <--- CRÍTICO: Harbour ahora es "dueño" de un ticket de
                    // esta imagen
  }

  hb_retnll((HB_LONGLONG)image);
}

//--------------------------------------------------------------------------------//

HB_FUNC(NSIMAGEFROMNAME) {
  NSString *string = hb_NSSTRING_par(1);
  NSImage *image = nil;
  NSFileManager *filemgr = [NSFileManager defaultManager];

  // 1. Intentamos cargar desde archivo
  if ([filemgr fileExistsAtPath:string]) {
    image = [[[NSImage alloc] initWithContentsOfFile:string] autorelease];
  } else {
    // 2. Si no es archivo, usamos tu función de plantilla (recursos/sistema)
    image = ImgTemplate(string);
  }

  hb_retnll((HB_LONGLONG)image);
}

//--------------------------------------------------------------------------------//

HB_FUNC(IMGSYMBOLCONFIG) // ( pointSize, weight, scale )
{
  Class configClass = NSClassFromString(@"NSImageSymbolConfiguration");
  if (configClass) {
    CGFloat pointSize = hb_parnd(1);
    NSFontWeight weight = hb_parnd(2);
    NSImageSymbolScale scale = hb_parnl(3);

    if (pointSize <= 0)
      pointSize = [NSFont systemFontSize];

    NSImageSymbolConfiguration *config =
        [configClass configurationWithPointSize:pointSize
                                         weight:weight
                                          scale:scale];
    hb_retnll((HB_LONGLONG)config);
  } else {
    hb_retnll(0);
  }
}

HB_FUNC(IMGSYMBOLWITHVARIABLE) // ( name, variableValue, hConfig )
{
  NSString *name = hb_NSSTRING_par(1);
  double value = hb_parnd(2);
  NSImageSymbolConfiguration *config =
      (NSImageSymbolConfiguration *)hb_parnll(3);
  NSImage *image = nil;

  if (HB_ISNIL(2)) {
    image = [NSImage imageWithSystemSymbolName:name
                      accessibilityDescription:nil];
  } else {
    image = [NSImage imageWithSystemSymbolName:name
                                 variableValue:value
                      accessibilityDescription:nil];
  }

  if (image && config) {
    image = [image imageWithSymbolConfiguration:config];
  }

  hb_retnll((HB_LONGLONG)image);
}

HB_FUNC(IMGSYMBOLHIERARCHICAL) // ( hConfig, nColor )
{
  NSImageSymbolConfiguration *config =
      (NSImageSymbolConfiguration *)hb_parnll(1);

  NSInteger nCol = (NSInteger)hb_parnll(2);
  NSColor *color = [NSColor colorWithDeviceRed:(nCol & 0xFF) / 255.0
                                         green:((nCol >> 8) & 0xFF) / 255.0
                                          blue:((nCol >> 16) & 0xFF) / 255.0
                                         alpha:1.0];

  NSImageSymbolConfiguration *colorConfig =
      [NSImageSymbolConfiguration configurationWithHierarchicalColor:color];
  if (config)
    colorConfig = [config configurationByApplyingConfiguration:colorConfig];

  hb_retnll((HB_LONGLONG)colorConfig);
}

HB_FUNC(IMGSYMBOLMULTICOLOR) // ( hConfig )
{
  NSImageSymbolConfiguration *config =
      (NSImageSymbolConfiguration *)hb_parnll(1);

  NSImageSymbolConfiguration *mcConfig =
      [NSImageSymbolConfiguration configurationWithPreferringMulticolor];
  if (config)
    mcConfig = [config configurationByApplyingConfiguration:mcConfig];

  hb_retnll((HB_LONGLONG)mcConfig);
}

HB_FUNC(IMGSYMBOLPALETTE) // ( hConfig, nCol1, nCol2, nCol3 )
{
  NSImageSymbolConfiguration *config =
      (NSImageSymbolConfiguration *)hb_parnll(1);

  NSMutableArray *colors = [NSMutableArray array];
  for (int i = 2; i <= 4; i++) {
    if (!HB_ISNIL(i)) {
      long nCol = hb_parnl(i);
      NSColor *color = [NSColor colorWithDeviceRed:(nCol & 0xFF) / 255.0
                                             green:((nCol >> 8) & 0xFF) / 255.0
                                              blue:((nCol >> 16) & 0xFF) / 255.0
                                             alpha:1.0];
      [colors addObject:color];
    }
  }
  NSImageSymbolConfiguration *pConfig =
      [NSImageSymbolConfiguration configurationWithPaletteColors:colors];
  if (config)
    pConfig = [config configurationByApplyingConfiguration:pConfig];

  hb_retnll((HB_LONGLONG)pConfig);
}
HB_FUNC(IMGSYMBOLS) {
  NSString *name = hb_NSSTRING_par(1);
  NSString *descrip = hb_NSSTRING_par(2);
  NSImage *img = [NSImage imageWithSystemSymbolName:name
                           accessibilityDescription:descrip];

  hb_retnll((HB_LONGLONG)img);
}

HB_FUNC(IMGNAMED) {
  hb_retnll((HB_LONGLONG)[NSImage imageNamed:hb_NSSTRING_par(1)]);
}

HB_FUNC(IMGGETFILE) {
  NSImageView *image = (NSImageView *)hb_parnll(1);
  NSString *string = [[image image] name];

  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(IMGGETWIDTH) {

  NSImageView *image = (NSImageView *)hb_parnll(1);
  NSImageRep *rep = [[[image image] representations] objectAtIndex:0];

  hb_retnl(rep.pixelsWide);
}

HB_FUNC(IMGGETHEIGHT) {
  NSImageView *imageView = (NSImageView *)hb_parnll(1);
  NSImage *image = [imageView image];

  if (image && [[image representations] count] > 0) {
    // Obtenemos la primera representación (objeto prestado, no requiere
    // retain/release)
    NSImageRep *rep = [[image representations] objectAtIndex:0];
    hb_retnl((long)rep.pixelsHigh);
  } else {
    hb_retnl(0);
  }
}

HB_FUNC(IMGSETFRAME) {
  NSImageView *image = (NSImageView *)hb_parnll(1);

  [[image animator] setImageFrameStyle:hb_parni(2)];

  // [ image setImageFrameStyle : NSImageFrameGrayBezel ];
}

HB_FUNC(IMGSETSCALING) {
  NSImageView *image = (NSImageView *)hb_parnll(1);

  [image setImageScaling:hb_parni(2)];
}

HB_FUNC(IMGSETRESFILE) // Read image from the app resources folder
{
  NSImageView *image = (NSImageView *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);
  NSString *myImagePath =
      [[[NSBundle mainBundle] resourcePath] stringByAppendingString:string];

  [image setImage:[[[NSImage alloc] initWithContentsOfFile:myImagePath]
                      autorelease]];
}

HB_FUNC(CHOOSESHEETIMAGE) {
  // 1. Usamos __block para que la variable sea modificable si fuera necesario,
  // pero en No-ARC lo más importante es que 'vista' no sea liberada antes que
  // el panel.
  NSImageView *vista = (NSImageView *)hb_parnll(1);
  NSOpenPanel *panel = [NSOpenPanel openPanel];

  [panel setMessage:@"Import the file"];

  // 2. En No-ARC, el panel retiene el bloque, y el bloque retiene a 'vista'.
  [panel beginSheetModalForWindow:[vista window]
                completionHandler:^(NSInteger result) {
                  if (result == NSModalResponseOK) {
                    NSURL *url = [[panel URLs] objectAtIndex:0];

                    // 3. Creamos la imagen con autorelease (Obligatorio en
                    // No-ARC)
                    NSImage *image = [[[NSImage alloc]
                        initWithContentsOfURL:url] autorelease];

                    if (image) {
                      [vista setHidden:NO];
                      [vista setImage:image];

                      NSString *source =
                          [[url path] stringByRemovingPercentEncoding];
                      [image setName:source];
                    }
                  }
                  // El panel se cierra solo al terminar el bloque.
                }];
}

//--------------------------------------------------------------------------------//

HB_FUNC(NEWRESIZEIMAGE) {
  // 1. Pool local: Crítico aquí porque TIFFRepresentation genera muchos datos
  // temporales
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSImageView *vista = (NSImageView *)hb_parnll(1);
  NSString *fileName = hb_NSSTRING_par(2);
  NSImage *sourceImage = [vista image];

  if (![sourceImage isValid]) {
    NSLog(@"Invalid Image");
  } else {
    NSSize newSize = NSMakeSize(hb_parnl(3), hb_parnl(4));

    // 2. Imagen de destino con autorelease
    NSImage *smallImage = [[[NSImage alloc] initWithSize:newSize] autorelease];

    [smallImage lockFocus];
    [[NSGraphicsContext currentContext]
        setImageInterpolation:NSImageInterpolationHigh];

    // Dibujamos la imagen original escalada en la nueva
    [sourceImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
                   fromRect:NSZeroRect
                  operation:NSCompositingOperationCopy
                   fraction:1.0];
    [smallImage unlockFocus];

    // 3. Procesamiento de datos (objetos temporales automáticos)
    NSData *imageData = [smallImage TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];

    // Usamos dictionaryWithObjects... que ya devuelve un objeto autorelease
    NSDictionary *imageProps =
        [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                    forKey:NSImageCompressionFactor];

    NSString *extension = [[fileName pathExtension] uppercaseString];
    NSBitmapImageFileType type;
    BOOL supported = YES;

    if ([extension isEqualToString:@"JPG"] ||
        [extension isEqualToString:@"JPEG"]) {
      type = NSBitmapImageFileTypeJPEG;
    } else if ([extension isEqualToString:@"PNG"]) {
      type = NSBitmapImageFileTypePNG;
    } else if ([extension isEqualToString:@"BMP"]) {
      type = NSBitmapImageFileTypeBMP;
    } else if ([extension isEqualToString:@"GIF"]) {
      type = NSBitmapImageFileTypeGIF;
    } else if ([extension isEqualToString:@"TIF"] ||
               [extension isEqualToString:@"TIFF"]) {
      type = NSBitmapImageFileTypeTIFF;
    } else {
      supported = NO;
    }

    if (supported) {
      NSData *finalData = [imageRep representationUsingType:type
                                                 properties:imageProps];
      [finalData writeToFile:fileName atomically:NO];
    } else {
      MsgAlert(@"Formato no soportado. Use JPG, PNG, BMP, GIF o TIF",
               @"Atención");
    }
  }
  // 4. Liberamos toda la memoria temporal (TIFFs, Reps, Dictionaries) de un
  // golpe
  [pool drain];
}

//--------------------------------------------------------------------------------//

HB_FUNC(RESIZEIMAGE) {
  NSImageView *vista = (NSImageView *)hb_parnll(1);
  if (vista) {
    NSImage *image = [vista image];
    if (image) {
      ImgResize(image, hb_parni(2), hb_parni(3));
      [vista setNeedsDisplay:YES]; // Forzamos al control a redibujarse con el
                                   // nuevo tamaño
    }
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(RESIZENSIMAGE) {
  NSImage *image = (NSImage *)hb_parnll(1);
  if (image) {
    ImgResize(image, hb_parni(2), hb_parni(3));
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(IMGCROP) {
  // 1. Pool local para limpiar los buffers de dibujo inmediatamente
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSImage *sourceImage = (NSImage *)hb_parnll(1);

  // Coordenadas del recorte (x, y, ancho, alto)
  CGFloat x = hb_parnd(2);
  CGFloat y = hb_parnd(3);
  CGFloat w = hb_parnd(4);
  CGFloat h = hb_parnd(5);

  NSImage *croppedImage = nil;

  if (sourceImage && [sourceImage isValid]) {
    NSSize cropSize = NSMakeSize(w, h);
    NSRect fromRect = NSMakeRect(x, y, w, h);

    // 2. Creamos la nueva imagen con autorelease (Obligatorio en No-ARC)
    croppedImage = [[[NSImage alloc] initWithSize:cropSize] autorelease];

    [croppedImage lockFocus];
    [sourceImage drawInRect:NSMakeRect(0, 0, w, h)
                   fromRect:fromRect
                  operation:NSCompositingOperationCopy
                   fraction:1.0];
    [croppedImage unlockFocus];

    // 3. Retenemos el objeto porque lo vamos a devolver a Harbour
    if (croppedImage) {
      [croppedImage retain];
    }
  }

  [pool drain];

  // Devolvemos el puntero a Harbour (ahora Harbour es "dueño" del objeto)
  hb_retnll((HB_LONGLONG)croppedImage);
}

//--------------------------------------------------------------------------------//

HB_FUNC(SIZEWIDTHIMAGE) {

  NSImageView *vista = (NSImageView *)hb_parnll(1);

  NSImage *sourceImage = [vista image];
  NSData *imageData = [sourceImage TIFFRepresentation];
  NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];

  NSInteger width = [imageRep pixelsWide];
  // NSInteger height = [imageRep pixelsHigh];

  hb_retnl((HB_LONG)width);
}

HB_FUNC(SIZEHEIGHTIMAGE) {

  NSImageView *vista = (NSImageView *)hb_parnll(1);
  //  NSString * fileName = hb_NSSTRING_par( 2 );

  NSImage *sourceImage = [vista image];
  NSData *imageData = [sourceImage TIFFRepresentation];
  NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];

  //   NSInteger width = [imageRep pixelsWide];
  NSInteger height = [imageRep pixelsHigh];

  hb_retnl((HB_LONG)height);
}

HB_FUNC(NSIMAGEFROMIMAGEVIEW) {
  NSImageView *vista = (NSImageView *)hb_parnll(1);
  NSImage *sourceImage = [vista image];
  hb_retnll((HB_LONGLONG)sourceImage);
}

HB_FUNC(NSIMGFROMFILE) {
  NSString *fileName = hb_NSSTRING_par(1);
  NSImage *image =
      [[[NSImage alloc] initWithContentsOfFile:fileName] autorelease];
  hb_retnll((HB_LONGLONG)image);
}

HB_FUNC(NSIMGGETWIDTH) {

  NSImage *image = (NSImage *)hb_parnll(1);
  NSImageRep *rep = [[image representations] objectAtIndex:0];

  hb_retnl(rep.pixelsWide);
}

HB_FUNC(NSIMGGETHEIGHT) {
  NSImage *image = (NSImage *)hb_parnll(1);
  NSImageRep *rep = [[image representations] objectAtIndex:0];

  hb_retnl(rep.pixelsHigh);
}

//--------------------------------------------------------------------------------//

HB_FUNC(SAVETEXTINIMAGE) {
  // 1. Pool local para limpiar buffers de imagen inmediatamente
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSString *fileIni = hb_NSSTRING_par(1);
  NSString *fileFin = hb_NSSTRING_par(2);
  NSString *text = hb_NSSTRING_par(3);
  NSString *extension = [[fileFin pathExtension] uppercaseString];

  // 2. Imagen base con autorelease
  NSImage *iniImage =
      [[[NSImage alloc] initWithContentsOfFile:fileIni] autorelease];

  if (iniImage) {
    // 3. Crear imagen nueva con el texto
    // El Block captura iniImage y text. En No-ARC esto es seguro mientras no
    // salgamos de la función.
    NSImage *finImage =
        [NSImage imageWithSize:iniImage.size
                       flipped:YES
                drawingHandler:^BOOL(NSRect dstRect) {
                  [iniImage drawInRect:dstRect];

                  // Diccionario compatible con No-ARC (evitamos sintaxis @{})
                  NSDictionary *attributes = [NSDictionary
                      dictionaryWithObject:[NSFont systemFontOfSize:hb_parnl(4)]
                                    forKey:NSFontAttributeName];

                  [text drawAtPoint:NSMakePoint(hb_parnl(6), hb_parnl(5))
                      withAttributes:attributes];
                  return YES;
                }];

    // 4. Convertir a representación de mapa de bits para guardar
    NSBitmapImageRep *imageRep = [[[NSBitmapImageRep alloc]
        initWithCGImage:[finImage CGImageForProposedRect:NULL
                                                 context:nil
                                                   hints:nil]] autorelease];

    NSDictionary *imageProps =
        [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                    forKey:NSImageCompressionFactor];

    NSBitmapImageFileType type;
    BOOL supported = YES;

    if ([extension isEqualToString:@"JPG"] ||
        [extension isEqualToString:@"JPEG"])
      type = NSBitmapImageFileTypeJPEG;
    else if ([extension isEqualToString:@"PNG"])
      type = NSBitmapImageFileTypePNG;
    else if ([extension isEqualToString:@"BMP"])
      type = NSBitmapImageFileTypeBMP;
    else if ([extension isEqualToString:@"GIF"])
      type = NSBitmapImageFileTypeGIF;
    else if ([extension isEqualToString:@"TIF"] ||
             [extension isEqualToString:@"TIFF"])
      type = NSBitmapImageFileTypeTIFF;
    else
      supported = NO;

    if (supported) {
      NSData *imageData = [imageRep representationUsingType:type
                                                 properties:imageProps];
      [imageData writeToFile:fileFin atomically:NO];
    }
  }

  // 5. Liberar toda la memoria temporal del proceso
  [pool drain];
}

/*
 HB_FUNC( IMGMASREFLEXSETFILE )
 {
 NSImageView * imageView = ( NSImageView * ) hb_parnl( 1 );
 NSString * string =  hb_NSSTRING_par( 2 ) ;
 NSImage * image = [ [ NSImage alloc ] initWithContentsOfFile : string ] ;

 (CGFloat)percentage = ( hb_parnl( 3 )/100.0 ) ;

 CGRect offscreenFrame = CGRectMake(0, 0, image.size.width,
image.size.height*(1.0+percentage)); NSBitmapImageRep * offscreen =
[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                 pixelsWide:offscreenFrame.size.width
                 pixelsHigh:offscreenFrame.size.height
                 bitsPerSample:8
                 samplesPerPixel:4
                 hasAlpha:YES
                 isPlanar:NO
                 colorSpaceName:NSDeviceRGBColorSpace
                 bitmapFormat:0
                 bytesPerRow:offscreenFrame.size.width * 4
                 bitsPerPixel:32];

  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:[NSGraphicsContext
graphicsContextWithBitmapImageRep:offscreen]];
  [[NSColor clearColor] set];

  NSRectFill(offscreenFrame);

  NSGradient * fade = [[NSGradient alloc] initWithStartingColor:
                      [NSColor colorWithCalibratedWhite:1.0 alpha:0.2]
endingColor:[NSColor clearColor]];

  CGRect fadeFrame = CGRectMake(0, 0, image.size.width, offscreen.size.height -
image.size.height); [fade drawInRect:fadeFrame angle:270.0];

  NSAffineTransform* transform = [NSAffineTransform transform];
  [transform translateXBy:0.0 yBy:fadeFrame.size.height];
  [transform scaleXBy:1.0 yBy:-1.0];
  [transform concat];

  [self drawAtPoint:NSMakePoint(0, 0) fromRect:CGRectMake(0, 0, self.size.width,
self.size.height) operation:NSCompositeSourceIn fraction:1.0];

  [transform invert];
  [transform concat];

  [image drawAtPoint:CGPointMake(0, offscreenFrame.size.height -
self.size.height) fromRect:NSZeroRect operation:NSCompositeSourceOver
fraction:1.0];

   [NSGraphicsContext restoreGraphicsState];

   NSImage * imageWithReflection = [[NSImage alloc]
initWithSize:offscreenFrame.size]; [imageWithReflection
addRepresentation:offscreen];

  [ imageView setImage : imageWithReflection ];

}

HB_FUNC( IMAGESETROTATE )
{
NSImageView * imageView = ( NSImageView * ) hb_parnl( 1 );
NSImage * image = [imageView image ] ;

(CGFloat)degrees = ( hb_parnl( 2 )/100.0 ) ;

 NSRect imageBounds = {NSZeroPoint, [image size]};
 NSBezierPath* boundsPath = [NSBezierPath bezierPathWithRect:imageBounds];
 NSAffineTransform* transform = [NSAffineTransform transform];
[transform rotateByDegrees:degrees];
[boundsPath transformUsingAffineTransform:transform];

 NSRect rotatedBounds = {NSZeroPoint, [boundsPath bounds].size};

 NSImage* rotatedImage = [[NSImage alloc] initWithSize:rotatedBounds.size];
 imageBounds.origin.x = NSMidX(rotatedBounds) - (NSWidth (imageBounds) / 2);
 imageBounds.origin.y = NSMidY(rotatedBounds) - (NSHeight (imageBounds) / 2);

 transform = [NSAffineTransform transform];

 [transform translateXBy:+(NSWidth(rotatedBounds) / 2) yBy:+
(NSHeight(rotatedBounds) / 2)];

 [transform rotateByDegrees:degrees];
 [transform translateXBy:-(NSWidth(rotatedBounds) / 2) yBy:-
(NSHeight(rotatedBounds) / 2)];

 [rotatedImage lockFocus];
 [transform concat];

 [image drawInRect:imageBounds fromRect:NSZeroRect operation:NSCompositeCopy
fraction:1.0] ;

 [rotatedImage unlockFocus];
 [ imageView setImage : rotatedImage ];

 // [rotatedImage autorelease];

}
*/

//---------------------------------------------------------------//

HB_FUNC(IMAGETODESKTOPWALLPAPER) {
  // 1. Creamos el pool local para limpiar los diccionarios y números temporales
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSString *path = hb_NSSTRING_par(1);

  // 2. CRÍTICO: Añadimos autorelease al NSURL (antes faltaba y causaba leak)
  NSURL *imageURL = [[[NSURL alloc] initFileURLWithPath:path] autorelease];

  NSError *error = nil;

  // 3. Opciones (objetos autoreleased por defecto)
  NSDictionary *options = [NSDictionary
      dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:NO], NSWorkspaceDesktopImageAllowClippingKey,
          [NSNumber numberWithInteger:NSImageScaleProportionallyUpOrDown],
          NSWorkspaceDesktopImageScalingKey, nil];

  // 4. Aplicar al último monitor (normalmente el externo o el principal)
  BOOL result = [[NSWorkspace sharedWorkspace]
      setDesktopImageURL:imageURL
               forScreen:[[NSScreen screens] lastObject]
                 options:options
                   error:&error];

  if (!result && error) {
    [NSApp presentError:error];
  }

  // 5. Limpiamos toda la memoria temporal
  [pool drain];
}

//---------------------------------------------------------------//

HB_FUNC(SAVEIMAGEFROMIMAGE) {
  // 1. Pool local para evitar picos de RAM al procesar píxeles
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSString *fileIni = hb_NSSTRING_par(1);
  NSString *fileFin = hb_NSSTRING_par(2);

  // Usamos pathExtension para obtener la extensión de forma segura
  NSString *extension = [[fileFin pathExtension] uppercaseString];

  // 2. Cargamos la imagen original con autorelease
  NSImage *sourceImage =
      [[[NSImage alloc] initWithContentsOfFile:fileIni] autorelease];

  if (![sourceImage isValid]) {
    NSLog(@"Invalid Image: %@", fileIni);
  } else {
    NSSize newSize = NSMakeSize(hb_parnl(3), hb_parnl(4));

    // 3. Creamos el lienzo de destino
    NSImage *smallImage = [[[NSImage alloc] initWithSize:newSize] autorelease];

    [smallImage lockFocus];
    [[NSGraphicsContext currentContext]
        setImageInterpolation:NSImageInterpolationHigh];

    // Dibujamos escalando (mejor que cambiar setSize al original)
    [sourceImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
                   fromRect:NSZeroRect
                  operation:NSCompositingOperationCopy
                   fraction:1.0];
    [smallImage unlockFocus];

    // 4. Conversión a datos de mapa de bits
    NSData *imageData = [smallImage TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps =
        [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                    forKey:NSImageCompressionFactor];

    NSBitmapImageFileType type = NSBitmapImageFileTypeJPEG; // por defecto
    BOOL supported = YES;

    if ([extension isEqualToString:@"JPG"] ||
        [extension isEqualToString:@"JPEG"])
      type = NSBitmapImageFileTypeJPEG;
    else if ([extension isEqualToString:@"PNG"])
      type = NSBitmapImageFileTypePNG;
    else if ([extension isEqualToString:@"BMP"])
      type = NSBitmapImageFileTypeBMP;
    else if ([extension isEqualToString:@"GIF"])
      type = NSBitmapImageFileTypeGIF;
    else if ([extension isEqualToString:@"TIF"] ||
             [extension isEqualToString:@"TIFF"])
      type = NSBitmapImageFileTypeTIFF;
    else
      supported = NO;

    if (supported) {
      NSData *finalData = [imageRep representationUsingType:type
                                                 properties:imageProps];
      [finalData writeToFile:fileFin atomically:NO];
    }
  }

  // 5. Liberamos todos los objetos temporales (incluyendo los buffers de datos)
  [pool drain];
}

//--------------------------------------------------------------------------------//

HB_FUNC(IMGSAVETOFILE) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSImage *image = (NSImage *)hb_parnll(1);
  NSString *path = hb_NSSTRING_par(2);
  NSString *extension = [[path pathExtension] uppercaseString];

  if (image && [image isValid]) {
    // 1. Obtenemos la representación de mapa de bits
    NSData *tiffData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:tiffData];

    // 2. Definimos propiedades (calidad 1.0 para JPG)
    NSDictionary *props =
        [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                    forKey:NSImageCompressionFactor];

    NSBitmapImageFileType type = NSBitmapImageFileTypePNG; // Por defecto PNG
    BOOL supported = YES;

    if ([extension isEqualToString:@"JPG"] ||
        [extension isEqualToString:@"JPEG"])
      type = NSBitmapImageFileTypeJPEG;
    else if ([extension isEqualToString:@"PNG"])
      type = NSBitmapImageFileTypePNG;
    else if ([extension isEqualToString:@"BMP"])
      type = NSBitmapImageFileTypeBMP;
    else if ([extension isEqualToString:@"GIF"])
      type = NSBitmapImageFileTypeGIF;
    else if ([extension isEqualToString:@"TIF"] ||
             [extension isEqualToString:@"TIFF"])
      type = NSBitmapImageFileTypeTIFF;
    else
      supported = NO;

    if (supported) {
      // 3. Generamos los datos finales y escribimos a disco
      NSData *finalData = [imageRep representationUsingType:type
                                                 properties:props];
      [finalData writeToFile:path atomically:YES];
    } else {
      NSLog(@"Formato no soportado: %@", extension);
    }
  }

  [pool drain]; // Limpia toda la memoria temporal (TIFFs y buffers)
}
