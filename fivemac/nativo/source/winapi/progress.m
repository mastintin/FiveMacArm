#import <QuartzCore/QuartzCore.h>
#include <fivemac.h>

//----------------------------------------------------------------------//

HB_FUNC(PROGRESSCREATE) {
  NSRect frame = NSMakeRect(hb_parnl(2), hb_parnl(1), hb_parnl(3), hb_parnl(4));

  // Usamos autorelease para no dejar "huérfana" la referencia del alloc
  NSProgressIndicator *progressIndicator =
      [[[NSProgressIndicator alloc] initWithFrame:frame] autorelease];

  NSWindow *window = (NSWindow *)hb_parnll(5);
  NSView *vParent = GetView(window);

  if (vParent) {
    [vParent addSubview:progressIndicator]; // Aquí sube el retain count y se
                                            // mantiene vivo
  }

  [progressIndicator setUsesThreadedAnimation:NO];
  [progressIndicator
      setDoubleValue:hb_parnd(6)]; // Nota: para valores double usa hb_parnd
  [progressIndicator setIndeterminate:NO];

  hb_retnll((HB_LONGLONG)progressIndicator);
}

//----------------------------------------------------------------------//

HB_FUNC(PROGRESSUPDATE) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);

  if (progressIndicator) {
    // Usamos hb_parnd para capturar decimales desde Harbour
    [progressIndicator setDoubleValue:hb_parnd(2)];

    // Opcional: Forzar el redibujado si la UI no se actualiza al instante
    [progressIndicator displayIfNeeded];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(PROGRESSSETMAX) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);

  [progressIndicator setMaxValue:hb_parnl(2)];
}

HB_FUNC(PROGRESSSETMIN) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);

  [progressIndicator setMinValue:hb_parnl(2)];
}

HB_FUNC(PROGRESSINCREMEN) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);

  [progressIndicator incrementBy:hb_parnl(2)];
}

//----------------------------------------------------------------------//

HB_FUNC(PROGRESSSETSPIN) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);

  if (progressIndicator) {
    // Cambia el estilo a círculo (spinner)
    [progressIndicator setStyle:NSProgressIndicatorStyleSpinning];

    // En estilo Spinning, casi siempre quieres que sea indeterminado
    [progressIndicator setIndeterminate:YES];

    // Opcional: Ajustar el tamaño si el spinner se ve pequeño
    // [progressIndicator setControlSize:NSControlSizeRegular];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(PROGRESSSETFRAME) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);

  if (progressIndicator) {
    // Definimos el nuevo rectángulo con los parámetros de Harbour
    // par 2: Y (Top), par 3: X (Left), par 4: Width, par 5: Height
    NSRect newFrame =
        NSMakeRect(hb_parnl(3), hb_parnl(2), hb_parnl(4), hb_parnl(5));

    [progressIndicator setFrame:newFrame];

    // Forzamos el redibujado para evitar "fantasmas" visuales
    [progressIndicator setNeedsDisplay:YES];
  }
}
//----------------------------------------------------------------------//

HB_FUNC(PROGRESSSETBAR) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);

  [progressIndicator setStyle:NSProgressIndicatorStyleBar];
}

HB_FUNC(PROGRESSINDETERMINATE) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);

  hb_retl((BOOL)[progressIndicator isIndeterminate]);
}

//----------------------------------------------------------------------//

HB_FUNC(PROGRESSSETHIDDEN) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);

  if (progressIndicator) {
    // hb_parl(2) recibe un lógico (.T. o .F.) desde Harbour
    [progressIndicator setHidden:hb_parl(2)];

    // Si lo ocultamos, es buena práctica detener la animación para ahorrar CPU
    if (hb_parl(2)) {
      [progressIndicator stopAnimation:nil];
    }
  }
}

//----------------------------------------------------------------------//

HB_FUNC(PROGRESSISHIDDEN) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);

  if (progressIndicator) {
    hb_retl([progressIndicator isHidden]);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(PROGRESSSETINDETERMINATE) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);
  if (progressIndicator) {
    [progressIndicator setIndeterminate:hb_parl(2)]; // .T. o .F. desde Harbour
  }
}

//----------------------------------------------------------------------//

HB_FUNC(PROGRESSSTARTANIME) {
  // Convertimos el puntero que viene de Harbour
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);

  if (progressIndicator) {
    // Si quieres que se mueva, asegúrate de que sea indeterminado (la barrita
    // infinita) [progressIndicator setIndeterminate:YES];

    [progressIndicator startAnimation:nil];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(PROGRESSSTOPANIME) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);

  [progressIndicator stopAnimation:nil]; // falta el sender
}

HB_FUNC(PROGRESSSETBEZELED) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);
  BOOL bezeled = hb_parl(2);

  if (bezeled) {
    [progressIndicator setWantsLayer:YES];
    progressIndicator.layer.borderWidth = 1.0;
    progressIndicator.layer.borderColor = [[NSColor lightGrayColor] CGColor];
  } else if (progressIndicator.wantsLayer) {
    progressIndicator.layer.borderWidth = 0.0;
  }
}

HB_FUNC(PROGRESSTINTDEFAULT) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);
  [progressIndicator setContentFilters:@[]];
}

HB_FUNC(PROGRESSTINTBLUE) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);
  [progressIndicator setContentFilters:@[]];
}

HB_FUNC(PROGRESSTINTGRAFITE) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);
  CIFilter *desaturate = [CIFilter filterWithName:@"CIColorControls"];
  [desaturate setDefaults];
  [desaturate setValue:[NSNumber numberWithFloat:0.0]
                forKey:@"inputSaturation"];
  [progressIndicator setContentFilters:@[ desaturate ]];
}

HB_FUNC(PROGRESSTINTCLEAR) {
  NSProgressIndicator *progressIndicator = (NSProgressIndicator *)hb_parnll(1);
  [progressIndicator setContentFilters:@[]];
}
