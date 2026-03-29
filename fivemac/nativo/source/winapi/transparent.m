#include <fivemac.h>

HB_FUNC(SETTRANS) {
  // Recuperamos el objeto ventana desde el puntero de Harbour
  NSWindow *window = (NSWindow *)hb_parnll(1);

  if (window != nil) {
    // Obtenemos el valor de transparencia (0.0 a 1.0)
    double alpha = hb_parnd(2);

    // Aplicamos la transparencia a la ventana
    [window setAlphaValue:alpha];

    // Si quieres que la ventana sea opaca al ratón en zonas transparentes:
    [window setOpaque:NO];
  }

  // Eliminamos la creación de NSView que causaba el leak
  hb_retl(window != nil);
}

//----------------------------------------------------------------------------//

HB_FUNC(SPLASHCREATE) // nTop, nLeft, nWidth, nHeight
{
  float x = hb_parnd(2);
  float y = hb_parnd(1);
  float width = hb_parnd(3);
  float height = hb_parnd(4);

  NSScreen *screen = [NSScreen mainScreen];
  NSRect screenFrame = [screen frame];

  // Ajuste de coordenadas (Y invertida en macOS)
  NSRect content =
      NSMakeRect(x, screenFrame.size.height - y - height, width, height);

  // CREACIÓN DE LA VENTANA
  NSWindow *w =
      [[NSWindow alloc] initWithContentRect:content
                                  styleMask:NSWindowStyleMaskBorderless
                                    backing:NSBackingStoreBuffered
                                      defer:NO];

  if (w) {
    // --- AJUSTES PARA NO-ARC Y TRANSPARENCIA ---

    // 1. IMPORTANTE: Hace que la ventana se libere de la RAM automáticamente al
    // cerrarse
    [w setReleasedWhenClosed:YES];

    // 2. Configuración visual para Splash
    [w setOpaque:NO];
    [w setHasShadow:YES];
    [w setBackgroundColor:[NSColor clearColor]];
    [w setLevel:NSFloatingWindowLevel]; // Siempre al frente
  }

  hb_retnll((HB_LONGLONG)w);
}

//----------------------------------------------------------------------------//

HB_FUNC(SPLASHSETFILE) // hWnd, cPath
{
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);

  if (window && string) {
    // 1. Cargamos la imagen con autorelease para evitar el LEAK
    NSImage *image =
        [[[NSImage alloc] initByReferencingFile:string] autorelease];

    if (image) {
      // 2. Usar colorWithPatternImage está bien para fondos,
      // pero hay que asegurar que la ventana sea transparente
      [window setOpaque:NO];
      [window setBackgroundColor:[NSColor colorWithPatternImage:image]];

      // 3. Forzar el redibujado
      [window display];
    }
  }
}

//----------------------------------------------------------------------------//
HB_FUNC(SPLASHRUN) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  double delay = hb_parnd(2) > 0 ? hb_parnd(2) : 5.0;

  // CLONAR LOS ITEMS (Importante para evitar el error EVAL)
  PHB_ITEM pBlock = hb_itemNew(hb_param(3, HB_IT_BLOCK));
  PHB_ITEM pSender = hb_itemNew(hb_param(4, HB_IT_OBJECT));

  if (window) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [window makeKeyAndOrderFront:nil];
      [window display];
    });

    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          usleep(delay * 1000000);

          dispatch_async(dispatch_get_main_queue(), ^{
            [NSAnimationContext
                runAnimationGroup:^(NSAnimationContext *context) {
                  [context setDuration:0.8];
                  [[window animator] setAlphaValue:0.0];
                }
                completionHandler:^{
                  [window close];

                  // Ejecutar el bloque { |o| oWnd:Show() }
                  if (pBlock && (hb_itemType(pBlock) & HB_IT_BLOCK)) {
                    hb_evalBlock1(pBlock, pSender);
                  }

                  // Liberar clones (No-ARC)
                  hb_itemRelease(pBlock);
                  hb_itemRelease(pSender);
                }];
          });
        });
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(SPLASHSETIMAGE) // ( hWnd, cPathImagen )
{
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSString *path = [NSString stringWithUTF8String:hb_parc(2)];

  if (window && path) {
    // 1. Cargar la imagen (metodo que devuelve objeto autorelease)
    NSImage *image =
        [[[NSImage alloc] initWithContentsOfFile:path] autorelease];

    if (image) {
      // 2. Crear el contenedor de imagen
      NSRect frame = [[window contentView] bounds];
      NSImageView *imageView =
          [[[NSImageView alloc] initWithFrame:frame] autorelease];

      // 3. Configurar aspecto
      [imageView setImage:image];
      [imageView
          setImageScaling:NSImageScaleAxesIndependently]; // Ajustar al tamaño
      [imageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

      // 4. Asignar a la ventana
      [window setContentView:imageView];
    }
  }
}

//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//

HB_FUNC(SPLASHCLOSE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  if (window) {
    // Usamos el hilo principal para cerrar la UI con seguridad
    dispatch_async(dispatch_get_main_queue(), ^{
      [window close];
      // Al tener 'setReleasedWhenClosed:YES', esto libera la memoria
    });
  }
}
