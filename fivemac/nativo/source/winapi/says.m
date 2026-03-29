#include <fivemac.h>

HB_FUNC(SAYCREATE) {
  NSTextField *say =
      [[NSTextField alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                    hb_parnl(3), hb_parnl(4))];
  NSWindow *window = (NSWindow *)hb_parnll(5);
  NSString *string = hb_NSSTRING_par(6);

  [say setEditable:FALSE];
  [say setSelectable:FALSE];
  [say setBordered:FALSE];
  [say setDrawsBackground:FALSE];
  [say setStringValue:string];

  [GetView(window) addSubview:say];

  // Liberamos la propiedad del objeto tras añadirlo a la vista.
  // La vista ahora es la encargada de retenerlo.
  [say release];

  hb_retnl((HB_LONG)say);
}

//-------------------------------------------------------------//

HB_FUNC(SAYSETSHADOW) {
  NSTextField *say = (NSTextField *)hb_parnll(1);

  // Verificamos que el objeto sea válido
  if (say && [say isKindOfClass:[NSTextField class]]) {

    // 1. Creamos el objeto Shadow (Manual Reference Counting)
    NSShadow *shadow = [[NSShadow alloc] init];

    // 2. Configuramos la sombra (negra con 30% de opacidad)
    [shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];

    // Desplazamiento: 0 horizontal, -1 vertical (hacia abajo)
    [shadow setShadowOffset:NSMakeSize(0, -1)];

    // Radio de desenfoque (1.0 es sutil, más alto es más suave)
    [shadow setShadowBlurRadius:1.0];

    // 3. Aplicamos la sombra al control
    // Es necesario activar la capa (layer) para que la sombra sea visible
    [say setWantsLayer:YES];
    [say setShadow:shadow];

    // 4. IMPORTANTE: En Non-ARC debemos liberar el objeto que hicimos 'alloc'
    [shadow release];
  }
}

//-------------------------------------------------------------//

HB_FUNC(SAYSETVIBRANT) {
  NSTextField *say = (NSTextField *)hb_parnll(1);

  if (say && [say isKindOfClass:[NSTextField class]]) {
    NSView *parent = [say superview];
    if (parent) {
      NSVisualEffectView *vibrantView =
          [[NSVisualEffectView alloc] initWithFrame:[say frame]];

      // Cambio: Añadimos 'View' al final de la constante
      [vibrantView setMaterial:NSVisualEffectMaterialHeaderView];
      [vibrantView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
      [vibrantView setState:NSVisualEffectStateActive];

      [parent replaceSubview:say with:vibrantView];

      [say setFrameOrigin:NSMakePoint(0, 0)];
      [vibrantView addSubview:say];

      // En Non-ARC liberamos nuestra propiedad inicial
      [vibrantView release];
    }
  }
}

//-------------------------------------------------------------//

HB_FUNC(SAYSETTEXT) {
  // 1. Obtenemos el puntero del objeto
  NSTextField *label = (NSTextField *)hb_parnll(1);

  // 2. Obtenemos el string de Harbour (es un objeto autorelease)
  NSString *string = hb_NSSTRING_par(2);

  // 3. Validación de seguridad: verificamos que 'label' exista y sea un
  // NSTextField
  if (label && [label isKindOfClass:[NSTextField class]]) {
    [label setStringValue:string];
  }
}

//-------------------------------------------------------------//

HB_FUNC(SETTEXTCOLOR) {
  NSView *view = (NSView *)hb_parnll(1);

  // Si la vista es nula, salimos para evitar un crash
  if (!view)
    return;

  NSColor *color = [NSColor colorWithSRGBRed:(hb_parnl(2) / 255.0)
                                       green:(hb_parnl(3) / 255.0)
                                        blue:(hb_parnl(4) / 255.0)
                                       alpha:(hb_parnl(5) / 100.0)];

  if ([view isKindOfClass:[NSTextField class]]) {
    [(NSTextField *)view setTextColor:color];
  } else if ([view isKindOfClass:[NSButton class]]) {
    NSButton *button = (NSButton *)view;
    NSAttributedString *currentTitle = [button attributedTitle];

    if (currentTitle) {
      NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc]
          initWithAttributedString:currentTitle];

      [attrTitle addAttribute:NSForegroundColorAttributeName
                        value:color
                        range:NSMakeRange(0, [attrTitle length])];

      [button setAttributedTitle:attrTitle];

      // Correcto: Liberamos lo que creamos con 'alloc'
      [attrTitle release];
    }
  }
}

//-------------------------------------------------------------//

HB_FUNC(SETBKCOLOR) {
  NSView *view = (NSView *)hb_parnll(1);
  if (!view)
    return;

  // Usamos SRGB para pantallas modernas
  NSColor *color = [NSColor colorWithSRGBRed:(hb_parnl(2) / 255.0)
                                       green:(hb_parnl(3) / 255.0)
                                        blue:(hb_parnl(4) / 255.0)
                                       alpha:(hb_parnl(5) / 100.0)];

  if ([view isKindOfClass:[NSTextField class]]) {
    NSTextField *say = (NSTextField *)view;
    [say setDrawsBackground:YES];
    [say setBackgroundColor:color];
    // Forzamos el redibujado para evitar "fantasmas" al cambiar colores rápido
    [say setNeedsDisplay:YES];
  } else {
    // Aseguramos que la vista tenga una capa (Layer-Backed)
    if (![view wantsLayer]) {
      [view setWantsLayer:YES];
    }
    // Acceso directo al método por corchetes (más estable en entornos antiguos)
    [[view layer] setBackgroundColor:[color CGColor]];
    [view setNeedsDisplay:YES];
  }
}

//-------------------------------------------------------------//
HB_FUNC(SAYSETBEZELED) {
  NSTextField *say = (NSTextField *)hb_parnll(1);

  if (say && [say isKindOfClass:[NSTextField class]]) {
    BOOL bBezeled = hb_parl(2);

    [say setBezeled:bBezeled];

    if (bBezeled) {
      // Para campos de texto, el estilo estándar es NSTextFieldSquareBezel.
      // El estilo 'Push' es para botones; aquí usamos el estilo de entrada.
      if (hb_parl(3)) {
        [say setBezelStyle:NSTextFieldSquareBezel];
      } else {
        [say setBezelStyle:NSTextFieldRoundedBezel]; // Más moderno y redondeado
      }
    }
  }
}

//-------------------------------------------------------------//

HB_FUNC(SAYSETBEZELSQUARE) {
  NSTextField *say = (NSTextField *)hb_parnll(1);

  if (say && [say isKindOfClass:[NSTextField class]]) {
    // Aseguramos que el borde esté activo primero
    [say setBezeled:YES];

    // Usamos la constante específica para campos de texto
    [say setBezelStyle:NSTextFieldSquareBezel];

    // Forzamos el redibujado para aplicar el cambio visual
    [say setNeedsDisplay:YES];
  }
}

//-------------------------------------------------------------//

HB_FUNC(SAYSETBEZELROUNDED) {
  NSTextField *say = (NSTextField *)hb_parnll(1);

  if (say && [say isKindOfClass:[NSTextField class]]) {
    // 1. Aseguramos que el borde esté activo
    [say setBezeled:YES];

    // 2. Usamos la constante nativa para campos de texto redondeados
    [say setBezelStyle:NSTextFieldRoundedBezel];

    // 3. Forzamos el redibujado
    [say setNeedsDisplay:YES];
  }
}

//-------------------------------------------------------------//

HB_FUNC(SAYSETSIZEFONT) {
  NSTextField *say = (NSTextField *)hb_parnll(1);
  CGFloat nSize = (CGFloat)hb_parnl(2);

  if (say && [say isKindOfClass:[NSTextField class]]) {
    // Si el tamaño pasado es 0, macOS suele usar el tamaño por defecto (13)
    // labelFontOfSize devuelve un objeto autorelease, es seguro.
    [say setFont:[NSFont labelFontOfSize:nSize]];

    // Ajustamos el control para que el texto no se corte si la fuente es muy
    // grande
    [say setNeedsDisplay:YES];
  }
}

//-------------------------------------------------------------//

HB_FUNC(SAYSETFONT) {
  NSTextField *say = (NSTextField *)hb_parnll(1);
  NSString *name = hb_NSSTRING_par(2);
  CGFloat nSize = (CGFloat)hb_parnl(3);

  if (say && [say isKindOfClass:[NSTextField class]]) {
    // 1. Intentamos cargar la fuente solicitada
    NSFont *newFont = [NSFont fontWithName:name size:nSize];

    // 2. Si la fuente no existe (nombre mal escrito o no instalada),
    // usamos la del sistema para evitar que el texto desaparezca.
    if (!newFont) {
      newFont = [NSFont systemFontOfSize:nSize];
    }

    if (newFont) {
      [say setFont:newFont];

      // 3. Opcional: sizeToFit ajusta el marco (frame) al nuevo texto,
      // pero ten cuidado si el control tiene una posición fija en tu diálogo.
      // [say sizeToFit];

      [say setNeedsDisplay:YES];
    }
  }
}

//-------------------------------------------------------------//

HB_FUNC(SETTEXTALIGN) {
  id view = (id)hb_parnll(
      1); // Usamos 'id' para ser más flexibles con el tipo de objeto
  NSInteger nAlign = (NSInteger)hb_parni(2);

  if (view) {
    if ([view isKindOfClass:[NSTextField class]]) {
      // Caso estándar: Es un control TextField
      [view setAlignment:nAlign];
    } else if ([view respondsToSelector:@selector(cell)]) {
      // Caso genérico: No es un TextField pero tiene una 'cell' (como
      // NSControl)
      [[view cell] setAlignment:nAlign];
    } else if ([view respondsToSelector:@selector(setAlignment:)]) {
      // Caso último: El objeto acepta alineación directamente
      [view setAlignment:nAlign];
    }

    // Forzamos el redibujado si es una vista
    if ([view isKindOfClass:[NSView class]]) {
      [view setNeedsDisplay:YES];
    }
  }
}

//-------------------------------------------------------------//

HB_FUNC(TXTSETENABLED) {
  NSTextField *get = (NSTextField *)hb_parnll(1);

  // Si el parámetro 2 es NIL (no se pasó), hb_parl devuelve FALSE.
  // Usamos hb_pcount() para saber cuántos parámetros se enviaron.
  BOOL bEnabled = (hb_pcount() < 2) ? YES : hb_parl(2);

  if (get && [get isKindOfClass:[NSTextField class]]) {
    [get setEnabled:bEnabled];

    if (bEnabled) {
      [get setTextColor:[NSColor controlTextColor]];
    } else {
      [get setTextColor:[NSColor disabledControlTextColor]];
    }

    [get setNeedsDisplay:YES];
  }
}

//-------------------------------------------------------------//

HB_FUNC(TXTSETNOSELECT) {
  NSTextField *get = (NSTextField *)hb_parnll(1);

  if (get && [get isKindOfClass:[NSTextField class]]) {
    // 1. Desactivamos la capacidad de seleccionar el texto
    [get setSelectable:NO];

    // 2. Si lo que buscas es bloquearlo totalmente (como en tu original):
    [get setEnabled:NO];

    // 3. Opcional: Cambiamos el color a gris de "desactivado" (es autorelease)
    [get setTextColor:[NSColor disabledControlTextColor]];

    [get setNeedsDisplay:YES];
  }
}

//-------------------------------------------------------------//

HB_FUNC(TXTSETDISABLED) {
  NSTextField *get = (NSTextField *)hb_parnll(1);

  if (get && [get isKindOfClass:[NSTextField class]]) {
    // 1. Deshabilitamos el control
    [get setEnabled:NO];

    // 2. Usamos el color estándar de texto desactivado (es autorelease)
    // Esto asegura legibilidad y estética nativa de macOS
    [get setTextColor:[NSColor disabledControlTextColor]];

    // 3. Forzamos el redibujado
    [get setNeedsDisplay:YES];
  }
}

//-------------------------------------------------------------//

HB_FUNC(TXTISENABLED) {
  // 1. Obtenemos el puntero del objeto
  NSTextField *get = (NSTextField *)hb_parnll(1);
  BOOL bEnabled = NO; // Valor por defecto si el objeto no es válido

  // 2. Validación de seguridad
  if (get && [get isKindOfClass:[NSTextField class]]) {
    bEnabled = [get isEnabled];
  }

  // 3. Devolvemos el valor lógico a Harbour
  hb_retl(bEnabled);
}

//-------------------------------------------------------------//

HB_FUNC(TXTGETWIDTH) {
  NSString *text = hb_NSSTRING_par(1);
  NSString *name = hb_NSSTRING_par(2);
  CGFloat nSize = (CGFloat)hb_parnl(3);

  // 1. Intentamos cargar la fuente. Si falla (nil), usamos la del sistema.
  // Si pasas un 'nil' al diccionario de atributos, la app se cierra (crash).
  NSFont *font = [NSFont fontWithName:name size:nSize];
  if (!font) {
    font = [NSFont systemFontOfSize:nSize];
  }

  // 2. Definimos el espacio máximo de cálculo (Size)
  CGSize frameSize =
      CGSizeMake(10000, 1000); // Un ancho grande para medir sin cortes

  // 3. Creamos el diccionario de atributos (es un objeto autorelease)
  NSDictionary *attrs = [NSDictionary dictionaryWithObject:font
                                                    forKey:NSFontAttributeName];

  // 4. Calculamos el rectángulo necesario
  CGRect idealFrame =
      [text boundingRectWithSize:frameSize
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:attrs
                         context:nil];

  // 5. Devolvemos el ancho redondeado (hb_retnl espera un entero)
  hb_retnl((HB_LONG)idealFrame.size.width);
}

//-------------------------------------------------------------//

HB_FUNC(TXTGETHEIGHT) {
  NSString *text = hb_NSSTRING_par(1);
  NSString *name = hb_NSSTRING_par(2);
  CGFloat nSize = (CGFloat)hb_parnl(3);
  CGFloat nFixedWidth = (CGFloat)hb_parnl(4); // Ancho máximo permitido

  // 1. Validación de fuente para evitar crash
  NSFont *font = [NSFont fontWithName:name size:nSize];
  if (!font) {
    font = [NSFont systemFontOfSize:nSize];
  }

  // 2. Definimos el espacio de cálculo con el ancho fijo que nos dan
  // Ponemos un alto enorme (10000) para que el texto fluya hacia abajo
  // libremente
  CGSize frameSize = CGSizeMake(nFixedWidth, 10000);

  // 3. Atributos (autorelease)
  NSDictionary *attrs = [NSDictionary dictionaryWithObject:font
                                                    forKey:NSFontAttributeName];

  // 4. Calculamos el rectángulo.
  // Usamos 'NSStringDrawingUsesLineFragmentOrigin' para que cuente los saltos
  // de línea.
  CGRect idealFrame =
      [text boundingRectWithSize:frameSize
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:attrs
                         context:nil];

  // 5. Devolvemos el alto redondeado
  hb_retnl((HB_LONG)idealFrame.size.height);
}

//-------------------------------------------------------------//

HB_FUNC(SAYHIPERLINKCREATE) {
  // 1. Creamos el TextField (alloc -> requiere release)
  NSTextField *say =
      [[NSTextField alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                    hb_parnl(3), hb_parnl(4))];
  NSWindow *window = (NSWindow *)hb_parnll(5);
  NSString *string = hb_NSSTRING_par(6);
  NSString *cUrl = hb_NSSTRING_par(7);

  // 2. Creamos el String Atribuido (alloc -> requiere release)
  NSMutableAttributedString *attrString =
      [[NSMutableAttributedString alloc] initWithString:string];
  NSRange range = NSMakeRange(0, [attrString length]);

  [attrString beginEditing];

  // NSURL con autorelease es correcto (ya lo tenías bien)
  NSURL *aURL = [[[NSURL alloc] initWithString:cUrl] autorelease];

  [attrString addAttribute:NSLinkAttributeName
                     value:[aURL absoluteString]
                     range:range];

  [attrString addAttribute:NSForegroundColorAttributeName
                     value:[NSColor blueColor]
                     range:range];

  [attrString addAttribute:NSUnderlineStyleAttributeName
                     value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                     range:range];

  [attrString endEditing];

  [say setAllowsEditingTextAttributes:YES];
  [say setEditable:FALSE];
  [say setSelectable:YES];
  [say setBordered:FALSE];
  [say setDrawsBackground:FALSE];

  // Asignamos el texto (el control hace una copia interna)
  [say setAttributedStringValue:attrString];

  // 3. Liberamos attrString porque ya no lo necesitamos nosotros
  [attrString release];

  [GetView(window) addSubview:say];

  // 4. Liberamos say porque addSubview ya lo retiene
  [say release];

  hb_retnl((HB_LONG)say);
}

//-------------------------------------------------------------//

HB_FUNC(SAYSETLINKCURSOR) {
  NSTextField *say = (NSTextField *)hb_parnll(1);

  if (say && [say isKindOfClass:[NSTextField class]]) {
    // 1. Obtenemos el cursor de "mano que apunta" (pointing hand)
    // Este objeto es compartido por el sistema, no requiere release.
    NSCursor *handCursor = [NSCursor pointingHandCursor];

    // 2. Registramos el área del control para este cursor.
    // bounds indica todo el rectángulo interno del control.
    [say addCursorRect:[say bounds] cursor:handCursor];

    // 3. Forzamos la actualización de los rectángulos de cursor del sistema
    [[say window] invalidateCursorRectsForView:say];
  }
}

//-------------------------------------------------------------//

HB_FUNC(SAYRELEASE) {
  NSTextField *say = (NSTextField *)hb_parnll(1);
  if (say && [say isKindOfClass:[NSTextField class]]) {
    // 1. Lo quitamos de la vista (esto le resta un 'retain')
    [say removeFromSuperview];

    // 2. No necesitamos hacer 'release' manual aquí porque
    // al principio (en el CREATE) ya hicimos el balanceo.
    // Al quitarlo de la superview, su contador llega a 0 solo.
  }
}
