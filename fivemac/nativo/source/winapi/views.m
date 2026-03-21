#include <QuartzCore/QuartzCore.h>
#include <fivemac.h>
#include <hbapiitm.h>

HB_FUNC(VIEWSETAUTORESIZE) {
  NSView *view = (NSView *)hb_parnll(1);

  if ([[view class] isSubclassOfClass:[NSTableView class]])
    view = [view enclosingScrollView];

  [view setAutoresizingMask:hb_parnl(2)];
}

HB_FUNC(VIEWAUTORESIZE) {
  NSView *view = (NSView *)hb_parnll(1);

  if ([[view class] isSubclassOfClass:[NSTableView class]])
    view = [view enclosingScrollView];

  hb_retnl([view autoresizingMask]);
}

HB_FUNC(VIEWSETBACKCOLOR) {
  // 1. Pool local para los objetos temporales (NSColor -> CGColor)
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSView *view = (NSView *)hb_parnll(1);
  NSColor *color = (NSColor *)hb_parnll(2);

  if (view && [view isKindOfClass:[NSView class]]) {
    // 2. ACTIVAR CAPA: Imprescindible para que funcione el color de fondo
    [view setWantsLayer:YES];

    if (color && [color isKindOfClass:[NSColor class]]) {
      // 3. Sintaxis de corchetes segura para No-ARC
      CALayer *layer = [view layer];
      if (layer) {
        // CGColor es una propiedad de NSColor que no requiere release manual
        [layer setBackgroundColor:[color CGColor]];
      }
    }
  }

  [pool release];
  hb_ret();
}

HB_FUNC(VIEWSETSIZE) {
  NSView *view = (NSView *)hb_parnll(1);

  [view setFrameSize:NSMakeSize(hb_parnl(2), hb_parnl(3))];
}

HB_FUNC(VIEWHIDE) {
  NSView *window = (NSView *)hb_parnll(1);

  [window setHidden:YES];
}

HB_FUNC(VIEWSHOW) {
  NSView *window = (NSView *)hb_parnll(1);

  [window setHidden:NO];
}

HB_FUNC(VIEWSETTOOLTIP) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);

  [(NSView *)window setToolTip:string];
}

HB_FUNC(VIEWEND) {
  NSView *view = (NSView *)hb_parnll(1);

  if (view) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([view isKindOfClass:[NSTableView class]])
      view = [view enclosingScrollView];

    [view removeFromSuperview];
    [pool release];
  }
}





HB_FUNC(OSCONTROLGETSIZE) {
  // 1. Usamos un pool local por si el acceso a la vista genera objetos
  // temporales internos
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSView *object = (NSView *)hb_parnll(1);
  CGFloat width = 0.0, height = 0.0;

  if (object) {
    // 2. Extraemos el tamaño (NSSize es una estructura, no un objeto)
    NSSize size = [object frame].size;
    width = size.width;
    height = size.height;
  }

  // 3. Retorno de Array a Harbour (Forma estándar y limpia)
  PHB_ITEM pArray = hb_itemArrayNew(2);
  hb_arraySet(pArray, 1, hb_itemPutND(NULL, (double)width));
  hb_arraySet(pArray, 2, hb_itemPutND(NULL, (double)height));

  hb_itemReturnForward(pArray);
  hb_itemRelease(pArray);

  [pool release];
}

// --- New Functions from Main.prg ---

HB_FUNC(VIEWCLEAN) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSView *parentView = (NSView *)hb_parnll(1);

  if (parentView && [parentView isKindOfClass:[NSView class]]) {
    NSArray *subviews = [[parentView subviews] copy];

    for (NSView *view in subviews) {
      NSView *targetView = view;
      
      // If it's a table/browse, we must clean its delegate to stop calls
      if ([view isKindOfClass:[NSTableView class]]) {
         NSTableView *tv = (NSTableView *)view;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
         // If it's a Wbrowse, it might need extra cleanup
         if ([tv respondsToSelector:@selector(setDataSource:)]) {
            [tv setDataSource:nil];
            [tv setDelegate:nil];
         }
#pragma clang diagnostic pop
         targetView = [view enclosingScrollView];
      }

      [targetView removeFromSuperview];
    }


    [subviews release];
  }


  [pool release];
  hb_ret();
}

HB_FUNC(VIEWSETCORNERRADIUS) {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSView *view = (NSView *)hb_parnll(1);
  CGFloat radius = (CGFloat)hb_parnd(2);

  if (view) {
    // 2. Activar la capa de CoreAnimation (necesario para el radio)
    [view setWantsLayer:YES];

    // 3. Sintaxis de corchetes estándar para No-ARC
    CALayer *layer = [view layer];
    if (layer) {
      [layer setCornerRadius:radius];
      [layer setMasksToBounds:YES];

      // Mejora: Suavizado de bordes (Antialiasing)
      [layer setEdgeAntialiasingMask:kCALayerLeftEdge | kCALayerRightEdge |
                                     kCALayerTopEdge | kCALayerBottomEdge];
    }
  }

  [pool release];
}

HB_FUNC(VIEWSETGRADIENTCOLOR) {
  NSView *view = (NSView *)hb_parnll(1);
  // Color 1: Dark Blue
  /*
   CGFloat r1 = 0.0;
   CGFloat g1 = 50.0 / 255.0;
   CGFloat b1 = 150.0 / 255.0;
   CGFloat a1 = 0.9;

   // Color 2: Regular Blue
   CGFloat r2 = 0.0;
   CGFloat g2 = 0.0;
   CGFloat b2 = 1.0;
   CGFloat a2 = 0.6;
 */

  CGFloat r1 = hb_parnd(2) / 255.0;
  CGFloat g1 = hb_parnd(3) / 255.0;
  CGFloat b1 = hb_parnd(4) / 255.0;
  CGFloat a1 = hb_parnd(5);

  // Color 2: Regular Blue
  CGFloat r2 = hb_parnd(6) / 255.0;
  CGFloat g2 = hb_parnd(7) / 255.0;
  CGFloat b2 = hb_parnd(8) / 255.0;
  CGFloat a2 = hb_parnd(9);

  [view setWantsLayer:YES];

  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = view.layer.bounds;

  [gradient setNeedsDisplayOnBoundsChange:YES];

  gradient.startPoint = CGPointMake(0.0, 0.5);
  gradient.endPoint = CGPointMake(1.0, 0.5);

  NSColor *c1 = [NSColor colorWithCalibratedRed:r1 green:g1 blue:b1 alpha:a1];
  NSColor *c2 = [NSColor colorWithCalibratedRed:r2 green:g2 blue:b2 alpha:a2];

  gradient.colors =
      [NSArray arrayWithObjects:(id)[c1 CGColor], (id)[c2 CGColor], nil];

  gradient.autoresizingMask =
      2 | 16; // kCALayerWidthSizable | kCALayerHeightSizable

  view.layer.backgroundColor = [c1 CGColor];

  view.layer.sublayers = nil;
  [view.layer addSublayer:gradient];
}

HB_FUNC(VIEWSETPOS) {
  // 1. Usamos CGFloat para evitar problemas de precisión en procesadores
  // M1/M2/M3
  NSView *view = (NSView *)hb_parnll(1);
  CGFloat x = (CGFloat)hb_parnd(3); // Usamos hb_parnd para admitir decimales
  CGFloat y = (CGFloat)hb_parnd(2);

  if (view) {
    // 2. Aplicamos la posición
    [view setFrameOrigin:NSMakePoint(x, y)];

    // 3. Opcional: Forzar redibujado si la vista se mueve
    [view setNeedsDisplay:YES];
  }
}

HB_FUNC(VIEWGETLAYER) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSView *view = (NSView *)hb_parnll(1);
  CALayer *layer = NULL;

  if (view) {
    // Si la vista no tiene capa, la activamos para evitar devolver NULL
    if (![view wantsLayer]) {
      [view setWantsLayer:YES];
    }
    layer = [view layer];
  }

  hb_retnll((HB_LONGLONG)layer);
  [pool release];
}

HB_FUNC(VIEWSETWANTSLAYER) {
  NSView *view = (NSView *)hb_parnll(1);
  BOOL wants = hb_parl(2); // Recibe el .T. o .F. de Harbour

  if (view) {
    [view setWantsLayer:wants];
    // Forzamos el redibujado para que el motor de capas se active ya
    [view setNeedsDisplay:YES];
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(VIEWENABLEDRAGANDDROP) {
  NSView *view = (NSView *)hb_parnll(1);

  if (hb_parl(2)) {
    [view registerForDraggedTypes:[NSArray
                                      arrayWithObjects:NSPasteboardTypeFileURL,
                                                       nil]];
  } else {
    [view unregisterDraggedTypes];
  }
}

//----------------------------------------------------------------------------//