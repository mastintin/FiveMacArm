#include <fivemac.h>

@interface SearchGet : NSSearchField <NSTextFieldDelegate> {
@public
  NSWindow *hWnd;
}
- (BOOL)textShouldEndEditing:(NSText *)text;
- (void)controlTextDidChange:(NSNotification *)aNotification;
@end

@interface ToolBar : NSToolbar <NSToolbarDelegate> {
  NSMutableArray *itemsSelectables;
}

- (void)dealloc;
- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar
        itemForItemIdentifier:(NSString *)itemIdentifier
    willBeInsertedIntoToolbar:(BOOL)flag;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)aToolbar;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)aToolbar;
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar;
- (void)addselectable:(NSToolbarItem *)item;

@end

@implementation ToolBar

// 1. EL PASO MÁS IMPORTANTE EN NON-ARC:
- (void)dealloc {
  if (itemsSelectables != nil) {
    [itemsSelectables release]; // Liberamos el array de la memoria
    itemsSelectables = nil;
  }
  [super dealloc]; // Llamada obligatoria al padre
}

- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar
        itemForItemIdentifier:(NSString *)itemIdentifier
    willBeInsertedIntoToolbar:(BOOL)flag {
  return [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier]
      autorelease];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)aToolbar {
  return [NSArray array];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)aToolbar {
  return [NSArray array];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
  // Si es nil, devolvemos un array vacío para evitar errores de Cocoa
  if (!itemsSelectables)
    return [NSArray array];

  // Correcto: copy + autorelease es la forma segura de devolver arrays internos
  return [[itemsSelectables copy] autorelease];
}

- (void)addselectable:(NSToolbarItem *)item {
  if (itemsSelectables == nil) {
    // Reservamos memoria. Esta memoria DEBE liberarse en dealloc
    itemsSelectables = [[NSMutableArray alloc] init];
  }

  if (item) {
    [itemsSelectables addObject:[item itemIdentifier]];
  }
}

@end

HB_FUNC(TBRCREATE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSString *identifier = hb_NSSTRING_par(2);

  ToolBar *toolbar =
      [[[ToolBar alloc] initWithIdentifier:identifier] autorelease];

  [toolbar setAllowsUserCustomization:NO];
  [toolbar setAutosavesConfiguration:NO];

  BOOL lSmall = hb_parl(3) ? hb_parl(3) : NO;

  if (lSmall) {
    //  NSLog( @"yes" );

    [toolbar setSizeMode:NSToolbarSizeModeSmall];
  } else {
    // NSLog( @"no" );
    [toolbar
        setSizeMode:NSToolbarSizeModeRegular]; // NSToolbarSizeModeSmall ]; //
                                               // NSToolbarSizeModeRegular ];
  }

  [toolbar setDelegate:toolbar];
  [window setToolbar:toolbar];

  hb_retnll((HB_LONGLONG)toolbar);
}

HB_FUNC(TBRFROMWND) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSToolbar *tool = (NSToolbar *)[window toolbar];

  return hb_retnll((HB_LONGLONG)tool);
}

HB_FUNC(TBRADDITEM) {
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);
  NSString *label = hb_NSSTRING_par(2);
  NSInteger index = hb_parnl(3);
  NSString *tooltip = hb_NSSTRING_par(4);

  NSToolbarItem *item;
  NSImage *Image = nil;

  if (HB_ISNUM(5)) {
    Image = (NSImage *)hb_parnll(5);
  } else {
    NSString *filename = hb_NSSTRING_par(5);
    if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
      // USAR autorelease para evitar fugas de memoria
      Image = [[[NSImage alloc] initWithContentsOfFile:filename] autorelease];
    } else {
      Image = ImgTemplate(filename); // Se asume que ImgTemplate ya devuelve un
                                     // autorelease o un template global
    }
  }

  [toolbar insertItemWithItemIdentifier:label atIndex:index];
  item = [[toolbar items] objectAtIndex:index];

  [item setLabel:label];
  //[ item setPaletteLabel : label ];
  [item setToolTip:tooltip];

  if (Image)
    [item setImage:Image];

  [item setAction:@selector(TbrClick:)]; // Gets routed to the window view
  [item setAutovalidates:NO];

  [item setEnabled:YES];

  hb_retnll((HB_LONGLONG)item);
}

HB_FUNC(TBRADDSEPARATOR) {
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);
  NSInteger index = hb_parnl(2);
  NSToolbarItem *item;

  [toolbar insertItemWithItemIdentifier:NSToolbarSpaceItemIdentifier
                                atIndex:index];

  item = [[toolbar items] objectAtIndex:index];

  hb_retnll((HB_LONGLONG)item);
}
//-------------------------------------------------------

HB_FUNC(TBRITEMSETVIEW) {
  NSToolbarItem *item = (NSToolbarItem *)hb_parnll(1);

  [item setView:(NSView *)hb_parnll(2)];
}

HB_FUNC(TBRITEMSETSIZE) {
  /*   -- deprecated ------
  NSToolbarItem *item = (NSToolbarItem *)hb_parnl(1);
  NSSize size = [item maxSize];

  size.width = hb_parnl(2);
  [item setMaxSize:size];
  */
}

HB_FUNC(TBRITEMSETMINSIZE) {
  /*   -- deprecated ------
  NSToolbarItem *item = (NSToolbarItem *)hb_parnl(1);
  NSSize size = [item minSize];

  size.width = hb_parnl(2);
  [item setMinSize:size];
  */
}

HB_FUNC(TBRITEMSETMAXSIZE) {
  /*   -- deprecated ------
  NSToolbarItem *item = (NSToolbarItem *)hb_parnl(1);
  NSSize size = [item maxSize];

  size.width = hb_parnl(2);
  [item setMaxSize:size];
  */
}

//-------------------------------------------------------

// Función de conveniencia interna
BOOL ToolBarItem_InternalSetPriority(HB_LONGLONG pItemPtr,
                                     NSInteger nPriority) {
  NSToolbarItem *item = (NSToolbarItem *)pItemPtr;

  if (item && [item isKindOfClass:[NSToolbarItem class]]) {
    [item setVisibilityPriority:nPriority];
    return YES;
  }
  return NO;
}

// Función específica para Alta Prioridad (No se oculta al encoger la ventana)
HB_FUNC(TBRITEMSETHIGHVISPRIORITY) {
  // 1000 = NSToolbarItemVisibilityPriorityHigh
  hb_retl(ToolBarItem_InternalSetPriority(hb_parnll(1), 1000));
}

// Función específica para Baja Prioridad (Se oculta de los primeros)
HB_FUNC(TBRITEMSETLOWVISPRIORITY) {
  // -1000 = NSToolbarItemVisibilityPriorityLow
  hb_retl(ToolBarItem_InternalSetPriority(hb_parnll(1), -1000));
}

// Función genérica para cualquier valor de prioridad
HB_FUNC(TBRITEMSETPRIORITY) {
  hb_retl(ToolBarItem_InternalSetPriority(hb_parnll(1), hb_parnl(2)));
}

HB_FUNC(TBRITEMSETSTANDARDVISPRIORITY) {
  hb_retl(ToolBarItem_InternalSetPriority(hb_parnll(1), 0));
}

HB_FUNC(TBRITEMSETUSERVISPRIORITY) {
  hb_retl(ToolBarItem_InternalSetPriority(hb_parnll(1), 1000));
}

//--------------------------------------------------------------------------//

HB_FUNC(TBRADDPRINT) {

  ToolBar *toolbar = (ToolBar *)hb_parnll(1);

  NSToolbarItem *item;

  [toolbar insertItemWithItemIdentifier:NSToolbarPrintItemIdentifier
                                atIndex:hb_parnl(2)];
  item = [[toolbar items] objectAtIndex:hb_parnl(2)];

  hb_retnll((HB_LONGLONG)item);
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRADDSPACEFLEX) {
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);
  NSInteger nIdx = hb_parnl(2);

  // 1. Validación de seguridad del objeto
  if (toolbar && [toolbar isKindOfClass:[NSToolbar class]]) {

    // 2. Insertar el identificador estándar de Apple para espacios flexibles
    [toolbar insertItemWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier
                                  atIndex:nIdx];

    // 3. Recuperar el ítem de forma segura
    NSArray *items = [toolbar items];
    if (nIdx < [items count]) {
      NSToolbarItem *item = [items objectAtIndex:nIdx];
      hb_retnll((HB_LONGLONG)item);
    } else {
      // Si por alguna razón la inserción falló o el índice fue inválido
      hb_retnll(0);
    }
  } else {
    hb_retnll(0);
  }
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRGETITEM) {
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);

  // 1. Validación de puntero de objeto
  if (toolbar && [toolbar isKindOfClass:[NSToolbar class]]) {

    NSArray *items = [toolbar items];
    NSUInteger nIdx = hb_parnl(2); // En Harbour los arrays son 1-based,
                                   // pero aquí depende de cómo lo pases.

    // 2. Validación crítica de límites (Bounds checking)
    if (nIdx < [items count]) {
      NSToolbarItem *item = [items objectAtIndex:nIdx];
      hb_retnll((HB_LONGLONG)item);
    } else {
      // Índice fuera de rango
      hb_retnll(0);
    }
  } else {
    // Objeto toolbar no válido
    hb_retnll(0);
  }
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRITEMSCOUNT) {
  // 1. Obtener el puntero de la Toolbar
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);

  // 2. Validación de seguridad
  // Verificamos que no sea nulo y que sea realmente una instancia de NSToolbar
  if (toolbar && [toolbar isKindOfClass:[NSToolbar class]]) {
    // [ toolbar items ] devuelve un NSArray, count devuelve un NSUInteger (64
    // bits en Mac)
    hb_retnl((HB_LONG)[[toolbar items] count]);
  } else {
    // Si el puntero es inválido, devolvemos 0 a Harbour
    hb_retnl(0);
  }
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRADDSPACE) {
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);
  NSInteger nIdx = hb_parnl(2);

  // 1. Validación de seguridad del objeto y del índice
  if (toolbar && [toolbar isKindOfClass:[NSToolbar class]]) {

    // 2. Insertar el identificador de espacio fijo de Apple
    [toolbar insertItemWithItemIdentifier:NSToolbarSpaceItemIdentifier
                                  atIndex:nIdx];

    // 3. Recuperar el ítem recién insertado de forma segura
    NSArray *items = [toolbar items];
    if (nIdx < [items count]) {
      NSToolbarItem *item = [items objectAtIndex:nIdx];
      hb_retnll((HB_LONGLONG)item);
    } else {
      // Si el índice fue inválido para el array de Cocoa
      hb_retnll(0);
    }
  } else {
    // Si el puntero de la toolbar es nulo o inválido
    hb_retnll(0);
  }
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRREMOVEITEM) {
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);
  NSInteger nIdx = hb_parnl(2); // Índice que viene de Harbour

  // 1. Validación de seguridad del objeto
  if (toolbar && [toolbar isKindOfClass:[NSToolbar class]]) {
    NSArray *items = [toolbar items];

    // 2. Validación crítica de límites (Bounds checking)
    // Si el índice es válido para el array de Cocoa (0 a count-1)
    if (nIdx >= 0 && nIdx < [items count]) {
      // 3. Eliminar el ítem físicamente de la Toolbar
      [toolbar removeItemAtIndex:nIdx];

      hb_retl(TRUE); // Éxito
    } else {
      // Índice fuera de rango, no hacemos nada
      hb_retl(FALSE);
    }
  } else {
    // Objeto no válido
    hb_retl(FALSE);
  }
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRCLEARALL) {
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);

  // 1. Validación de seguridad del objeto
  if (toolbar && [toolbar isKindOfClass:[NSToolbar class]]) {
    // 2. Obtenemos el número de ítems actuales
    NSInteger nCount = [[toolbar items] count];

    // 3. Borramos de atrás hacia adelante (Downwards)
    // Esto evita que los índices cambien de posición mientras borramos
    for (NSInteger i = nCount - 1; i >= 0; i--) {
      [toolbar removeItemAtIndex:i];
    }

    hb_retl(TRUE); // Éxito: Toolbar vacía
  } else {
    hb_retl(FALSE); // Objeto no válido
  }
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRCHANGEITEMIMAGE) {
  NSToolbarItem *item = (NSToolbarItem *)hb_parnll(1);
  NSImage *image = nil;

  // 1. Validación del ítem
  if (item && [item isKindOfClass:[NSToolbarItem class]]) {

    // 2. Obtener la nueva imagen (Lógica idéntica a TBRADDITEM)
    if (HB_ISNUM(2)) {
      image = (NSImage *)hb_parnll(2);
    } else {
      NSString *filename = hb_NSSTRING_par(2);
      if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        // Usamos autorelease para evitar fugas de memoria en Non-ARC
        image = [[[NSImage alloc] initWithContentsOfFile:filename] autorelease];
      } else {
        image = ImgTemplate(filename);
      }
    }

    // 3. Aplicar la imagen al ítem
    if (image) {
      [item setImage:image];
      hb_retl(TRUE);
    } else {
      hb_retl(FALSE);
    }

  } else {
    hb_retl(FALSE);
  }
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRCHANGEITEMLABEL) {
  NSToolbarItem *item = (NSToolbarItem *)hb_parnll(1);
  NSString *label = hb_NSSTRING_par(2);

  // 1. Validación de seguridad para evitar crashes si el ítem es nulo
  if (item && [item isKindOfClass:[NSToolbarItem class]]) {
    // 2. Cambiar la etiqueta que se ve en la barra
    [item setLabel:label];

    // 3. Cambiar la etiqueta que se ve en el panel de personalización
    // (Importante en Mac)
    [item setPaletteLabel:label];

    hb_retl(TRUE);
  } else {
    hb_retl(FALSE);
  }
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRCHANGEITEMTOOLTIP) {
  NSToolbarItem *item = (NSToolbarItem *)hb_parnll(1);
  NSString *cToolTip = hb_NSSTRING_par(2);

  // 1. Validación de seguridad del objeto
  if (item && [item isKindOfClass:[NSToolbarItem class]]) {
    // 2. Aplicar el nuevo texto de ayuda (Tooltip)
    [item setToolTip:cToolTip];

    hb_retl(TRUE);
  } else {
    hb_retl(FALSE);
  }
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRITEMDISABLE) {
  NSToolbarItem *item = (NSToolbarItem *)hb_parnll(1);

  // 1. Validación de seguridad
  if (item && [item isKindOfClass:[NSToolbarItem class]]) {
    [item setEnabled:NO];
    hb_retl(TRUE);
  } else {
    hb_retl(FALSE);
  }
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRITEMENABLE) {
  NSToolbarItem *item = (NSToolbarItem *)hb_parnll(1);

  // 1. Validación de seguridad
  if (item && [item isKindOfClass:[NSToolbarItem class]]) {
    // 2. Si se pasa el segundo parámetro, lo usamos. Si no, por defecto es
    // TRUE.
    BOOL lEnable = hb_pcount() > 1 ? hb_parl(2) : YES;

    [item setEnabled:lEnable];

    hb_retl(TRUE);
  } else {
    hb_retl(FALSE);
  }
}

//-----------------------------------------------------------------------------//
/*
  Modos estándar de macOS:
  0 = NSToolbarDisplayModeDefault
  1 = NSToolbarDisplayModeIconAndLabel
  2 = NSToolbarDisplayModeIconOnly
  3 = NSToolbarDisplayModeLabelOnly
*/

// Función de soporte interna
BOOL ToolBar_InternalSetMode(HB_LONGLONG pPtr, NSInteger nMode) {
  ToolBar *toolbar = (ToolBar *)pPtr;

  // Verificación de seguridad: ¿Es un puntero válido de NSToolbar?
  if (toolbar && [toolbar isKindOfClass:[NSToolbar class]]) {
    [toolbar setDisplayMode:(NSToolbarDisplayMode)nMode];
    return YES;
  }
  return NO;
}

// Opción genérica: Permite pasar el modo (0, 1, 2, 3) desde el .prg
HB_FUNC(TBRSETDISPLAYMODE) {
  BOOL lSuccess = ToolBar_InternalSetMode(hb_parnll(1), hb_parnl(2));
  hb_retl(lSuccess);
}

// Opción específica: Fuerza el modo "Solo etiquetas" (Label Only = 3)
HB_FUNC(TBSETMODELABEL) {
  BOOL lSuccess = ToolBar_InternalSetMode(hb_parnll(1), 3);
  hb_retl(lSuccess);
}

HB_FUNC(TBSETMODEICOLBL) {
  BOOL lSuccess = ToolBar_InternalSetMode(hb_parnll(1), 1);
  hb_retl(lSuccess);
}

HB_FUNC(TBSETMODEICO) {
  BOOL lSuccess = ToolBar_InternalSetMode(hb_parnll(1), 2);
  hb_retl(lSuccess);
}

HB_FUNC(TBSETMODEDEFAULT) {
  BOOL lSuccess = ToolBar_InternalSetMode(hb_parnll(1), 0);
  hb_retl(lSuccess);
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRADDSEARCH) {
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);
  NSString *label = hb_NSSTRING_par(2);
  NSString *tooltip = hb_NSSTRING_par(4);

  NSToolbarItem *item;
  SearchGet *edit = (SearchGet *)hb_parnll(5);

  [toolbar insertItemWithItemIdentifier:@"Buscador" atIndex:hb_parnl(3)];
  item = [[toolbar items] objectAtIndex:hb_parnl(3)];

  [item setLabel:label];
  [item setPaletteLabel:label];
  [item setToolTip:tooltip];
  [item setEnabled:YES];
  [item setView:edit];

  hb_retnll((HB_LONGLONG)item);
}

HB_FUNC(TBRSEARCHTEXT) {
  NSToolbarItem *item = (NSToolbarItem *)hb_parnll(1);
  SearchGet *edit = (SearchGet *)[item view];
  NSString *string = [edit stringValue];

  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(TBRADDCONTROL) {
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);
  NSString *label = hb_NSSTRING_par(3);
  NSString *tooltip = hb_NSSTRING_par(4);
  NSToolbarItem *item;
  NSView *view = (NSView *)hb_parnll(2);

  [toolbar insertItemWithItemIdentifier:@"ctrl" atIndex:hb_parnl(5)];
  item = [[toolbar items] objectAtIndex:hb_parnl(5)];

  [item setLabel:label];
  [item setPaletteLabel:label];
  [item setToolTip:tooltip];
  [item setEnabled:YES];
  [view removeFromSuperview];
  [item setView:view];

  hb_retnll((HB_LONGLONG)item);
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRHEIGHT) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  CGFloat h = 0;

  if (window && [window isKindOfClass:[NSWindow class]]) {
    NSToolbar *toolbar = [window toolbar];

    // 1. Si la ventana tiene toolbar y es visible
    if (toolbar && [toolbar isVisible]) {
      NSRect windowFrame = [window frame];
      // Calculamos la diferencia entre el frame total y el contentRect
      NSRect contentRect =
          [NSWindow contentRectForFrameRect:windowFrame
                                  styleMask:[window styleMask]];

      // La altura de la barra de título + toolbar es la diferencia de alturas
      h = NSHeight(windowFrame) - NSHeight(contentRect);
    }
  }

  hb_retnd(
      (double)h); // Devolvemos double para mayor precisión en pantallas Retina
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRITEMSELECTED) {
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);
  NSToolbarItem *item = (NSToolbarItem *)hb_parnll(2);

  [toolbar setSelectedItemIdentifier:[item itemIdentifier]];
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRITEMSELECTABLE) {
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);
  NSToolbarItem *item = (NSToolbarItem *)hb_parnll(2);

  // Validación: verificamos que la toolbar sea de nuestra clase 'ToolBar'
  // (la que contiene el método addselectable:) y que el ítem no sea nulo.
  if (toolbar && [toolbar isKindOfClass:[ToolBar class]] && item) {
    [toolbar addselectable:item];
    hb_retl(TRUE);
  } else {
    hb_retl(FALSE);
  }
}

//-----------------------------------------------------------------------------//

HB_FUNC(TBRADDSEGMENTEDBTN) {
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);
  NSString *label = hb_NSSTRING_par(2);
  NSInteger nIdx = hb_parnl(3);
  NSString *tooltip = hb_NSSTRING_par(4);
  NSSegmentedControl *segment = (NSSegmentedControl *)hb_parnll(5);

  if (toolbar && [toolbar isKindOfClass:[NSToolbar class]] && segment) {

    [toolbar insertItemWithItemIdentifier:label atIndex:nIdx];

    NSArray *items = [toolbar items];
    if (nIdx < [items count]) {
      NSToolbarItem *item = [items objectAtIndex:nIdx];

      [item setLabel:label];
      [item setPaletteLabel:label];
      [item setToolTip:tooltip];

      // 1. ASIGNAR EL CONTROL
      [item setView:segment];

      // 2. MODERNIZACIÓN (Evitar setMinSize/setMaxSize):
      // Activamos las restricciones automáticas para que el ítem
      // se adapte al tamaño intrínseco del NSSegmentedControl.
      [segment setTranslatesAutoresizingMaskIntoConstraints:NO];

      // 3. OPCIONAL (Compatibilidad con sistemas antiguos):
      // Si necesitas que funcione en versiones muy viejas sin warnings,
      // solo se usa setMinSize si el sistema es anterior a macOS 12.
      // Pero con 'translatesAutoresizingMaskIntoConstraints: NO' suele bastar.

      hb_retnll((HB_LONGLONG)item);
    } else {
      hb_retnll(0);
    }
  } else {
    hb_retnll(0);
  }
}

//-----------------------------------------------------------------------------//
/*
0 (Automatic): El sistema decide según la estructura de la ventana.
1 (Expanded): Estilo clásico. El título arriba y la barra de herramientas
completa debajo. 2 (Preference): Ideal para ventanas de configuración; iconos
centrados y sin etiquetas. 3 (Unified): El estilo moderno. El título y los
botones de la barra comparten la misma línea horizontal.
*/

// Función interna para cambiar el estilo visual de la relación Título/Toolbar
BOOL Window_InternalSetToolbarStyle(HB_LONGLONG pWindowPtr, NSInteger nStyle) {
  NSWindow *window = (NSWindow *)pWindowPtr;

  // Validamos que el puntero sea una ventana válida
  if (window && [window isKindOfClass:[NSWindow class]]) {
    // Propiedad disponible desde macOS 11.0+
    if ([window respondsToSelector:@selector(setToolbarStyle:)]) {
      [window setToolbarStyle:(NSWindowToolbarStyle)nStyle];
      return YES;
    }
  }
  return NO;
}

// Función genérica para pasar cualquier estilo (0-4)
HB_FUNC(WNDSETTOOLBARSTYLE) {
  hb_retl(Window_InternalSetToolbarStyle(hb_parnll(1), hb_parnl(2)));
}

// Función específica para el modo "Unificado" (Título y botones en la misma
// línea)
HB_FUNC(WNDSETTOOLBARUNIFIED) {
  // 3 = NSWindowToolbarStyleUnified
  hb_retl(Window_InternalSetToolbarStyle(hb_parnll(1), 3));
}

//--------------------------------------------------------------------------//

HB_FUNC(TBRRESETTODEFAULT) {
  ToolBar *toolbar = (ToolBar *)hb_parnll(1);

  if (toolbar && [toolbar isKindOfClass:[ToolBar class]]) {
    // 1. Obtenemos la lista de ítems por defecto desde el delegado (nuestra
    // clase ToolBar) Este es el método que recomienda Apple para "resetear" la
    // barra.
    NSArray *defaultItems = [toolbar toolbarDefaultItemIdentifiers:toolbar];

    if (defaultItems) {
      // 2. Aplicamos la lista de ítems por defecto de golpe
      [toolbar setItemIdentifiers:defaultItems];

      hb_retl(TRUE);
    }
  }

  hb_retl(FALSE);
}

//--------------------------------------------------------------------------//

// Función interna para abrir el panel de configuración
BOOL ToolBar_InternalRunConfig(HB_LONGLONG pToolbarPtr) {
  NSToolbar *toolbar = (NSToolbar *)pToolbarPtr;

  if (toolbar && [toolbar isKindOfClass:[NSToolbar class]]) {
    // Es obligatorio que allowsUserCustomization sea YES para que el panel
    // funcione
    if ([toolbar allowsUserCustomization]) {
      // nil indica que no hay un objeto 'sender' específico disparando la
      // acción
      [toolbar runCustomizationPalette:nil];
      return YES;
    }
  }
  return NO;
}

HB_FUNC(TBRRUNCONFIG) {
  // Llamamos a la lógica de conveniencia y devolvemos el éxito a Harbour
  hb_retl(ToolBar_InternalRunConfig(hb_parnll(1)));
}

//--------------------------------------------------------------------------//
