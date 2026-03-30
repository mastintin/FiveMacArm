#include <fivemac.h>

HB_FUNC(CREATEFONT) {
  NSString *name = hb_NSSTRING_par(1);
  NSFont *font = [NSFont fontWithName:name size:hb_parnll(2)];

  hb_retnll((HB_LONGLONG)font);
}

HB_FUNC(FONT_RELEASE) // ( hFont )
{
  // Obtenemos el puntero que Harbour tiene guardado como un número (Long Long)
  NSFont *font = (NSFont *)hb_parnll(1);

  if (font != NULL) {
    // IMPORTANTE: Solo llamar a release si el objeto existe.
    // Esto decrementa el contador de referencias.
    [font release];
  }
}

HB_FUNC(FONTGETSYSTEM) {
  NSFont *font = [NSFont systemFontOfSize:hb_parnll(1)];

  hb_retnll((HB_LONGLONG)font);
}

HB_FUNC(FONTGETNAME) {
  NSFont *font = [NSFont systemFontOfSize:hb_parnll(1)];

  hb_retc([[font displayName] cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(FONTISVERTICAL) {
  NSFont *font = [NSFont systemFontOfSize:hb_parnll(1)];
  hb_retl([font isVertical]);
}

HB_FUNC(SETBOLDSYSTEMFONT) {
  NSControl *ctrl = (NSControl *)hb_parnll(1);
  CGFloat size = hb_parnl(2);
  [ctrl setFont:[NSFont boldSystemFontOfSize:size]];
}

HB_FUNC(FONTSETVERTICAL) {

  NSFont *font = [NSFont systemFontOfSize:hb_parnll(1)];
  NSFont *fontVertical = [font verticalFont];
  hb_retnll((HB_LONGLONG)fontVertical);
}

//----------------------------------------------------------------------------//

HB_FUNC(DRAWTEXT) // nRow, nCol, cText, hFont
{
  NSString *text = hb_NSSTRING_par(3);
  NSMutableDictionary *attr =
      [NSMutableDictionary dictionaryWithObject:(NSFont *)hb_parnll(4)
                                         forKey:NSFontAttributeName];

  if (hb_pcount() > 4) {
    [attr setObject:(NSColor *)hb_parnll(5)
             forKey:NSForegroundColorAttributeName];
  }

  [text drawAtPoint:NSMakePoint(hb_parnll(1), hb_parnll(2))
      withAttributes:attr];

  // No es necesario liberar 'attr' ni 'text' porque son autoreleased.
  // Si usaras [[NSMutableDictionary alloc] init], entonces sí harías [attr
  // release].
}

//----------------------------------------------------------------------------//

HB_FUNC(FM_AVAILABLEFONTS) {
  // Creamos un pool local por si hay miles de fuentes, liberar memoria de
  // inmediato
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSArray *aFonts = [[NSFontManager sharedFontManager] availableFonts];
  NSUInteger iCount = [aFonts count];
  NSUInteger i;

  hb_reta(iCount);

  for (i = 0; i < iCount; i++) {
    NSString *cFontName = (NSString *)[aFonts objectAtIndex:i];

    // Usamos hb_storvc para asignar al array de Harbour
    // El índice en Harbour empieza en 1
    hb_storvc([cFontName UTF8String], -1, i + 1);
  }

  [pool release]; // Liberamos el pool y todo lo que contenía
}

//----------------------------------------------------------------------------//

HB_FUNC(FM_FONTSARRAY) {
  // Obtenemos el array (es autorelease por defecto)
  NSArray *aFonts = [[NSFontManager sharedFontManager] availableFonts];

  // LE SUMAMOS 1 AL CONTADOR DE REFERENCIAS
  // Ahora el objeto no morirá al salir de la función.
  [aFonts retain];

  hb_retnll((HB_LONGLONG)aFonts);
}
