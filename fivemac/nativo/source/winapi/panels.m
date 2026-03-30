#include <fivemac.h>

@interface FiveFlippedView : NSView {
  BOOL _isFlipped;
@public
  BOOL bVibrancy;
}
- (id)initWithFrame:(NSRect)frame flipped:(BOOL)flipped;
- (BOOL)isFlipped;
- (NSView *)view;
- (NSView *)contentView;
@end

@implementation FiveFlippedView

FIVEMAC_DRAGDROP_METHODS

- (id)initWithFrame:(NSRect)frame flipped:(BOOL)flipped {
  self = [super initWithFrame:frame];
  if (self) {
    _isFlipped = flipped;
    // if (flipped) {
    //   _isFlipped = YES; // FORCED: Reverted to hardcoded YES as requested
    // } else {
    //   _isFlipped = NO;
    // }
  }
  return self;
}

- (BOOL)isFlipped {
  return _isFlipped;
}
- (NSView *)view {
  return self;
}
- (NSView *)contentView {
  return self;
}
@end

HB_FUNC(PANELCREATE) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSView *parent = GetView((NSWindow *)hb_parnll(5));
  BOOL bFlipped = hb_parl(6);

  // 1. Creamos la vista (Retain Count = 1)
  FiveFlippedView *view = [[FiveFlippedView alloc]
      initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1), hb_parnl(3),
                               hb_parnl(4))
            flipped:bFlipped];

  if (parent && view) {
    // 2. addSubview le hace un retain internamente (Retain Count = 2)
    [parent addSubview:view];
  }

  // 3. Devolvemos el puntero a Harbour
  hb_retnll((HB_LONGLONG)view);

  // 4. Liberamos nuestra propiedad sobre el objeto (Retain Count vuelve a 1)
  // Ahora solo el 'parent' es dueño de la vista.
  [view release];

  [pool release];
}

HB_FUNC(PANELSETCOLOR) {
  // Iniciamos el pool para gestión manual de memoria
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSView *view = (NSView *)hb_parnll(1);

  if (view) {
    [view setWantsLayer:YES];

    float fRed = hb_parnl(2) / 255.0;
    float fGreen = hb_parnl(3) / 255.0;
    float fBlue = hb_parnl(4) / 255.0;
    float fAlpha = hb_parnl(5) / 100.0;

    if (fAlpha == 0)
      fAlpha = 1.0;

    NSColor *color = [NSColor colorWithSRGBRed:fRed
                                               green:fGreen
                                                blue:fBlue
                                               alpha:fAlpha];
    [view.layer setBackgroundColor:[color CGColor]];
  }

  // Liberamos el pool y todos los objetos marcados como autorelease (como
  // 'color')
  [pool release];
}

HB_FUNC(PANELSETSHADOW) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSView *view = (NSView *)hb_parnll(1);

  if (view) {
    float fOpacity = hb_parnl(2) / 100.0;
    float fRadius = hb_parnl(3);
    float fOffSetW = hb_parnl(4);
    float fOffSetH = hb_parnl(5);

    [view setWantsLayer:YES];

    // Importante: En no-ARC usamos la propiedad del layer directamente
    CALayer *layer = [view layer];

    [layer setMasksToBounds:NO]; // Permite que la sombra se vea fuera del marco

    NSColor *black = [NSColor blackColor];
    [layer setShadowColor:[black CGColor]];
    [layer setShadowOpacity:fOpacity];
    [layer setShadowRadius:fRadius];
    [layer setShadowOffset:CGSizeMake(fOffSetW, fOffSetH)];
  }

  [pool release];
}

HB_FUNC(PNLALLOWVIBRANCY) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSView *view = (NSView *)hb_parnll(1);

  // Verificamos que la vista no sea nula y sea de la clase esperada
  if (view && [view isKindOfClass:[FiveFlippedView class]]) {
    FiveFlippedView *fView = (FiveFlippedView *)view;

    // Acceso directo a la variable de instancia (iVar)
    fView->bVibrancy = hb_parl(2);

    // Forzamos el redibujado para que macOS consulte de nuevo allowsVibrancy
    [fView setNeedsDisplay:YES];
  }

  [pool release];
}

HB_FUNC(PANELDESTROY) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSView *view = (NSView *)hb_parnll(1);

  if (view && [view isKindOfClass:[NSView class]]) {
    // 1. Esto reduce el retain count de la vista.
    // Si el parent era el único dueño, la vista se libera de memoria.
    [view removeFromSuperview];

    // 2. Opcional: Si quieres ser extremadamente agresivo con la limpieza
    // de capas (layers) antes de destruir:
    if ([view wantsLayer]) {
      [view.layer setDelegate:nil];
      [view setLayer:nil];
    }
  }

  [pool release];
}
