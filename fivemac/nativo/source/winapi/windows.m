
// #include "hbxvm.h"
#include <fivemac.h>

static PHB_SYMB symFMH = NULL;
static NSWindow *wndMain = NULL;

void CocoaInit(void);

@interface PrnView : NSView {
@public
  NSWindow *hWnd;
}
- (void)drawRect:(NSRect)needsDisplayInRect;
@end

@implementation View

FIVEMAC_DRAGDROP_METHODS

- (void)setOriginalWindow:(NSWindow *)window {
  originalWindow = window;
}

- (void)cancelOperation:(id)sender {
  // Swallow Escape key to prevent automatic window close
}

- (BOOL)windowShouldClose:(NSNotification *)notification // VALID clause !
{
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushLong(WM_WNDVALID);
  hb_vmDo(2);

  if (HB_ISLOG(-1))
    return hb_parl(-1);
  else
    return TRUE;
}

- (void)windowWillClose:(NSNotification *)notification {
  if ([self window] == wndMain)
    [NSApp terminate:self];
  else
    [NSApp stopModal]; // modal dialogs
}

- (BOOL)acceptsFirstResponder {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushLong(WM_WHEN);
  hb_vmDo(2);

  if (HB_ISLOG(-1))
    return hb_parl(-1);
  else
    return TRUE;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushLong(WM_LOSTFOCUS);
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmDo(3);
}

- (void)windowDidBecomeKey:(NSNotification *)notification

{
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushLong(WM_GETFOCUS);
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmDo(3);
}

- (void)windowDidUpdate:(NSNotification *)notification {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_PAINT);
  hb_vmDo(2);
}

- (void)mouseDown:(NSEvent *)theEvent {
  NSPoint point = [theEvent locationInWindow];

  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_LBUTTONDOWN);
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(point.y);
  hb_vmPushNLL(point.x);
  hb_vmDo(5);
}

- (BOOL)isFlipped {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_FLIPPED);
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmDo(3);

  // RED DE SEGURIDAD: SI HARBOUR NO CONTESTA (.NIL.), DEVOLVEMOS YES
  if (!HB_ISLOG(-1))
    return YES;

  return hb_parl(-1);
}

- (void)mouseUp:(NSEvent *)theEvent {
  NSPoint point = [theEvent locationInWindow];

  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_LBUTTONUP);
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(point.y);
  hb_vmPushNLL(point.x);
  hb_vmDo(5);
}

- (void)rightMouseDown:(NSEvent *)theEvent {
  NSPoint point = [theEvent locationInWindow];

  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_RBUTTONDOWN);
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(point.y);
  hb_vmPushNLL(point.x);
  hb_vmDo(5);
}

- (void)mouseMoved:(NSEvent *)theEvent {
  NSPoint point = [theEvent locationInWindow];
  NSPoint absPos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  BOOL isInside = [self mouse:absPos inRect:[self bounds]];

  if (!isInside)
    return;

  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_MOUSEMOVED);
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(point.y);
  hb_vmPushNLL(point.x);
  hb_vmDo(5);
}

- (void)mouseDragged:(NSEvent *)theEvent {
  NSPoint point = [theEvent locationInWindow];
  NSPoint absPos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  BOOL isInside = [self mouse:absPos inRect:[self bounds]];

  if (!isInside)
    return;

  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_MOUSEMOVED);
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(point.y);
  hb_vmPushNLL(point.x);
  hb_vmDo(5);
}

- (void)keyDown:(NSEvent *)theEvent {
  NSString *key = [theEvent characters];
  int unichar = [key characterAtIndex:0];

  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_KEYDOWN);
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(unichar);
  hb_vmDo(4);

  if (hb_parnl(-1) != 1)
    [super keyDown:theEvent];
}

- (void)flagsChanged:(NSEvent *)theEvent {
  [super flagsChanged:theEvent];
}

- (void)windowDidResize:(NSNotification *)notification {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_RESIZE);
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmDo(3);
}

- (void)MenuItem:(id)sender {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_MENUITEM);
  hb_vmPushNLL((HB_LONGLONG)sender);
  hb_vmDo(3);
}

- (void)BtnClick:(id)sender;
{
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_BTNCLICK);
  hb_vmPushNLL((HB_LONGLONG)sender);
  hb_vmDo(3);
}

- (void)BrwDblClick:(id)sender;
{
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_BRWDBLCLICK);
  hb_vmPushNLL((HB_LONGLONG)sender);
  hb_vmDo(3);
}

- (void)CbxChange:(id)sender {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_CBXCHANGE);
  hb_vmPushNLL((HB_LONGLONG)sender);
  hb_vmDo(3);
}

- (void)ChkClick:(id)sender;
{
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_CHKCLICK);
  hb_vmPushNLL((HB_LONGLONG)sender);
  hb_vmDo(3);
}

- (IBAction)changeColor:(id)sender {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_CLRCHANGE);
  hb_vmPushNLL((HB_LONGLONG)sender);
  hb_vmDo(3);
}

- (void)TbrClick:(id)sender;
{
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_TBRCLICK);
  hb_vmPushNLL((HB_LONGLONG)sender);
  hb_vmDo(3);
}

- (void)OnTimerEvent:(NSTimer *)timer {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_TIMER);
  hb_vmPushNLL((HB_LONGLONG)timer);
  hb_vmDo(3);
}

- (void)SliderChanged:(id)sender;
{
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMH"));

  NSWindow *win = (originalWindow ? originalWindow : [self window]);

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)win);
  hb_vmPushNLL(WM_SLIDERCHANGE);
  hb_vmPushNLL((HB_LONGLONG)sender);
  hb_vmDo(3);
}

- (NSView *)hitTest:(NSPoint)aPoint {
  if (bDesign)
    return self;
  else
    return [super hitTest:aPoint];
}
@end

@interface FiveMacPanel : NSPanel
@end

@implementation FiveMacPanel
- (BOOL)canBecomeKeyWindow {
  return YES;
}
- (void)cancelOperation:(id)sender {
  // Swallow Escape to prevent automatic closure
}
@end

HB_FUNC(WNDCREATE) {
  NSPanel *window = [[FiveMacPanel alloc]
      initWithContentRect:NSMakeRect(hb_parnl(2), hb_parnl(1), hb_parnl(3),
                                     hb_parnl(4))
                styleMask:hb_parnl(5)
                  backing:NSBackingStoreBuffered
                    defer:NO];
  View *view = [[View alloc] init];
  view->bDesign = FALSE;

  [window setContentView:view];
  [window setDelegate:view];
  [window setHidesOnDeactivate:NO];

  if (wndMain == NULL)
    wndMain = window;

  [window makeFirstResponder:view];
  [window setAcceptsMouseMovedEvents:YES];

  hb_retnll((HB_LONGLONG)window);
}

HB_FUNC(WNDRUN) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  [window makeKeyAndOrderFront:nil];

  if (window == wndMain)
    [NSApp run];
}

//--------------------------------------------------------------------------------//

HB_FUNC(WNDSAY) {
  // Obtenemos el string (Harbour suele devolverlo como autorelease)
  NSString *string = hb_NSSTRING_par(3);

  if (string) {
    // Creamos el diccionario con alloc/init
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];

    [attr setObject:[NSFont boldSystemFontOfSize:14]
             forKey:NSFontAttributeName];
    [attr setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];

    // Dibujamos el texto
    [string drawAtPoint:NSMakePoint(hb_parnl(1), hb_parnl(2))
         withAttributes:attr];

    // LIBERACIÓN MANUAL: Crucial para no agotar la RAM (No ARC)
    [attr release];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(WNDSETFOCUS) {
  // 1. Recuperamos el puntero de la ventana
  NSWindow *window = (NSWindow *)hb_parnll(1);

  // 2. Verificamos que la ventana exista para evitar un crash
  if (window && [window isKindOfClass:[NSWindow class]]) {

    // 3. Traemos la aplicación al frente (opcional pero recomendado)
    [NSApp activateIgnoringOtherApps:YES];

    // 4. Hacemos que la ventana sea la principal y se muestre
    [window makeKeyAndOrderFront:nil];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(GETFOCUS) {
  // 1. Obtenemos la ventana que está en primer plano
  NSWindow *window = [NSApp keyWindow];

  if (window) {
    // 2. El 'firstResponder' es el objeto que tiene el foco de entrada
    id responder = [window firstResponder];

    // 3. Retornamos el puntero a Harbour
    hb_retnll((HB_LONGLONG)responder);
  } else {
    hb_retnll(0);
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(WNDSETFONT) {
  // 1. Usamos NSControl o NSView (NSControl tiene setFont)
  NSControl *view = (NSControl *)hb_parnll(1);
  NSString *name = hb_NSSTRING_par(2);
  CGFloat size = (CGFloat)hb_parnl(3);

  if (view && [view respondsToSelector:@selector(setFont:)]) {
    // 2. fontWithName ya devuelve un objeto "autoreleased".
    // NO añadas [autorelease] aquí.
    NSFont *font = [NSFont fontWithName:name size:size];

    if (font) {
      [view setFont:font];
    } else {
      // Opcional: Si la fuente no existe, poner la del sistema
      [view setFont:[NSFont systemFontOfSize:size]];
    }
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(WNDCLOSE) {
  // 1. Obtenemos el puntero
  NSWindow *window = (NSWindow *)hb_parnll(1);

  // 2. Validamos que sea realmente una ventana antes de enviar el mensaje
  if (window && [window isKindOfClass:[NSWindow class]]) {

    // performClose simula el clic en el botón rojo de cerrar.
    // Esto disparará las validaciones de guardado si la ventana tiene un
    // delegate.
    [window performClose:nil];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(WNDCLEAN) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  if (window && [window isKindOfClass:[NSWindow class]]) {
    NSView *contentView = [window contentView];

    // 1. Creamos una copia de la lista de subvistas.
    // arrayWithArray devuelve un objeto 'autorelease', perfecto para No ARC.
    NSArray *subviews = [NSArray arrayWithArray:[contentView subviews]];

    // 2. Usamos un bucle for tradicional o rápido sobre la copia
    for (NSView *view in subviews) {
      // 3. Al quitarla de la supervista, Cocoa le envía un 'release'
      // automáticamente.
      [view removeFromSuperview];
    }
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(WNDDESIGN) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  View *view = (View *)[window contentView];

  hb_retl(view->bDesign);

  if (!HB_ISNIL(2))
    view->bDesign = hb_parl(2);
}

HB_FUNC(WNDHITTEST) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  View *view = (View *)[window contentView];
  NSPoint aPoint;
  BOOL bDesign = view->bDesign;
  NSView *ctrl;

  aPoint.y = (float)hb_parnl(2);
  aPoint.x = (float)hb_parnl(3);

  view->bDesign = FALSE;
  ctrl = [view hitTest:aPoint];

  // Robust HitTest Resolution Logic v2
  // Goal: Normalize the hit to what handles fiveform expects.
  // Handles Internal Views (Images in Buttons), Containers (WebViews), and
  // Legacy Memos.

  NSView *temp = ctrl;
  Class wkClass = NSClassFromString(@"WKWebView");

  while (temp && temp != view) {
    // 1. WebView
    if (wkClass && [temp isKindOfClass:wkClass]) {
      if ([temp enclosingScrollView]) {
        ctrl = [temp enclosingScrollView];
      } else {
        ctrl = temp;
      }
      break;
    }

    // 2. ScrollView (Container)
    if ([temp isKindOfClass:[NSScrollView class]]) {
      NSScrollView *sv = (NSScrollView *)temp;
      NSView *docView = [sv documentView];

      // For WebView, we want the ScrollView handle (Container Strategy)
      if (wkClass && [docView isKindOfClass:wkClass]) {
        ctrl = sv;
      } else {
        // For Memos/Browsers, we likely want the Inner View (Legacy behavior)
        if (docView)
          ctrl = docView;
        else
          ctrl = sv;
      }
      break;
    }

    // 3. NSBox (Group)
    if ([temp isKindOfClass:[NSBox class]]) {
      ctrl = temp;
      break;
    }

    // 4. NSControl (standard controls like Button, Slider)
    // Must exclude NSScroller because we want to climb to its ScrollView parent
    if ([temp isKindOfClass:[NSControl class]]) {
      if (![temp isKindOfClass:[NSScroller class]]) {
        ctrl = temp;
        break;
      }
    }

    // 5. NSTextView (Inner Memo hit)
    if ([temp isKindOfClass:[NSTextView class]]) {
      ctrl = temp;
      break;
    }

    temp = [temp superview];
  }

  hb_retnll((HB_LONGLONG)ctrl);
  view->bDesign = bDesign;
}

//--------------------------------------------------------------------------------//

HB_FUNC(WNDICONIZE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  // Validamos que el objeto sea una ventana antes de actuar
  if (window && [window isKindOfClass:[NSWindow class]]) {

    // Solo intentamos minimizar si la ventana no está ya minimizada
    if (![window isMiniaturized]) {
      [window performMiniaturize:nil];
    }
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(WNDMAXIMIZE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  [window performZoom:nil];
}

HB_FUNC(WNDSETHIDEONDEACTIVATE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  window.hidesOnDeactivate = hb_parl(2);
}

HB_FUNC(WNDREFRESH) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  [window update];
}

HB_FUNC(WNDSETTEXT) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);

  [window setTitle:string];
}

HB_FUNC(WNDGETTEXT) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSString *string = @"";

  if ([window isKindOfClass:[NSControl class]])
    string = [((NSControl *)window) stringValue];
  else {
    if ([window respondsToSelector:@selector(title)])
      string = [window title];
  }

  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

/*
HB_FUNC(WNDTOP) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSRect frame = [window frame];

  if ([[window class] isSubclassOfClass:[NSTableView class]]) {
    window = (NSWindow *)[((NSTableView *)window) enclosingScrollView];

    frame = [window frame];
  }

  if (HB_ISNUM(2)) {
    frame.origin.y = hb_parnl(2);

    if ([window isKindOfClass:[NSWindow class]])
      [window setFrame:frame display:YES];
    else {
      [((NSView *)window) setFrame:frame];
      // [ [ ( ( NSControl * ) window ) window ] display ];
    }
  }

  hb_retnl(frame.origin.y);
}
*/

HB_FUNC(WNDTOP) {
  // 1. Identificamos qué objeto hemos recibido (puede ser Window o View)
  id object = (id)hb_parnll(1);
  NSRect frame;

  if (!object) {
    hb_retnl(0);
    return;
  }

  // 2. Lógica para obtener el Frame
  if ([object isKindOfClass:[NSWindow class]]) {
    frame = [object frame];
  } else if ([object isKindOfClass:[NSView class]]) {
    // Si es un TableView, a veces queremos mover su ScrollView contenedor
    if ([object isKindOfClass:[NSTableView class]]) {
      object = [object enclosingScrollView];
    }
    frame = [object frame];
  }

  // 3. Si se pasa el segundo parámetro, asignamos la nueva posición Y
  if (hb_pcount() >= 2) {
    frame.origin.y = (CGFloat)hb_parnd(2);

    if ([object isKindOfClass:[NSWindow class]]) {
      // Para ventanas, movemos con setFrame
      [object setFrame:frame display:YES animate:NO];
    } else {
      // Para vistas (controles), movemos dentro de su superview
      [object setFrame:frame];
      [[object superview] setNeedsDisplay:YES];
    }
  }

  // 4. Retornamos la posición actual
  hb_retnl((long)frame.origin.y);
}

HB_FUNC(WNDLEFT) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSRect frame = [window frame];

  if ([[window class] isSubclassOfClass:[NSTableView class]]) {
    window = (NSWindow *)[((NSTableView *)window) enclosingScrollView];

    frame = [window frame];
  }

  if (HB_ISNUM(2)) {
    frame.origin.x = hb_parnl(2);
    if ([window isKindOfClass:[NSWindow class]])
      [window setFrame:frame display:YES];
    else {
      [((NSControl *)window) setFrame:frame];
      [[((NSControl *)window) window] display];
    }
  }

  hb_retnl(frame.origin.x);
}

HB_FUNC(WNDWIDTH) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSRect frame = [window frame];

  if ([[window class] isSubclassOfClass:[NSTableView class]]) {
    window = (NSWindow *)[((NSTableView *)window) enclosingScrollView];

    frame = [window frame];
  }

  if (HB_ISNUM(2)) {
    frame.size.width = hb_parnl(2);
    if ([window isKindOfClass:[NSWindow class]])
      [window setFrame:frame display:YES];
    else {
      [((NSControl *)window) setFrame:frame];
      [[((NSControl *)window) window] display];
    }
  }

  hb_retnl(frame.size.width);
}

HB_FUNC(WNDHEIGHT) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSRect frame = [window frame];

  if ([[window class] isSubclassOfClass:[NSTableView class]]) {
    window = (NSWindow *)[((NSTableView *)window) enclosingScrollView];

    frame = [window frame];
  }

  if (HB_ISNUM(2)) {
    frame.size.height = hb_parnl(2);
    if ([window isKindOfClass:[NSWindow class]])
      [window setFrame:frame display:YES];
    else {
      [((NSControl *)window) setFrame:frame];
      [[((NSControl *)window) window] display];
    }
  }

  hb_retnl(frame.size.height);
}

HB_FUNC(WNDCENTER) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  [window center];
}

HB_FUNC(WNDFULLSCREEN) {
// Check for Lion, Mountain Lion
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
  NSWindow *window = (NSWindow *)hb_parnll(1);
  [window setCollectionBehavior:NSWindowCollectionBehaviorFullScreenPrimary];
#endif
}

HB_FUNC(WNDSETRESIZABLE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  BOOL bResizable = hb_parl(2);
  NSUInteger style = [window styleMask];

  if (bResizable)
    style |= NSWindowStyleMaskResizable;
  else
    style &= ~NSWindowStyleMaskResizable;

  [window setStyleMask:style];
}

HB_FUNC(WNDSETMINSIZE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  [window setMinSize:NSMakeSize(hb_parnl(2), hb_parnl(3))];
}

HB_FUNC(WNDSETMAXSIZE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  [window setMaxSize:NSMakeSize(hb_parnl(2), hb_parnl(3))];
}

HB_FUNC(WNDSETSPLASH) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  [window setOpaque:NO];
  [window setBackgroundColor:[NSColor colorWithDeviceWhite:1.0 alpha:0.0]];
  [window setHasShadow:NO];

  // [window setLevel:NSFloatingWindowLevel];
}

HB_FUNC(WNDSETTRANS) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  [window setAlphaValue:hb_parnd(2)];
  [window center];
}

HB_FUNC(WNDSETBRUSH) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);
  NSColor *color = [NSColor
      colorWithPatternImage:[[NSImage alloc] initWithContentsOfFile:string]];

  if (window) {
    [window setBackgroundColor:color];
    [[window contentView] setWantsLayer:YES];
    [[window contentView] layer].backgroundColor = [color CGColor];
  }
}

HB_FUNC(WNDSETGLASS) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  if (window && [window isKindOfClass:[NSWindow class]]) {
    [window setOpaque:NO];
    [window setBackgroundColor:[NSColor clearColor]];

    if ([window respondsToSelector:@selector(setTitlebarAppearsTransparent:)]) {
      [window setTitlebarAppearsTransparent:YES];
    }

    // NSWindowStyleMaskFullSizeContentView = 1 << 15 (32768)
    [window setStyleMask:[window styleMask] | 32768];
    [window setHasShadow:YES];

    NSView *contentView = [window contentView];
    if (contentView) {
      NSVisualEffectView *vView =
          [[NSVisualEffectView alloc] initWithFrame:contentView.bounds];
      vView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
      vView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
      vView.state = NSVisualEffectStateActive;

      if (@available(macOS 10.14, *)) {
        vView.material = NSVisualEffectMaterialUnderWindowBackground;
      } else {
        vView.material = NSVisualEffectMaterialWindowBackground;
      }

      [contentView addSubview:vView positioned:NSWindowBelow relativeTo:nil];
      [vView release];
    }
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(WNDSETBKGCOLOR) // hWnd, r, g, b, alpha
{
  NSWindow *window = (NSWindow *)hb_parnll(1);

  if (window && [window isKindOfClass:[NSWindow class]]) {
    // 1. Usamos sRGB para colores más fieles en monitores modernos
    // 2. Dividimos alpha por 100.0 si en Harbour pasas 0-100 (típico en
    // Harbour)
    //    o por 255.0 si pasas 0-255. Aquí mantengo 255.0 según tu código.
    NSColor *color = [NSColor colorWithSRGBRed:(CGFloat)hb_parnd(2) / 255.0
                                         green:(CGFloat)hb_parnd(3) / 255.0
                                          blue:(CGFloat)hb_parnd(4) / 255.0
                                         alpha:(CGFloat)hb_parnd(5) / 255.0];

    // Aplicar al contenedor de la ventana
    [window setBackgroundColor:color];

    // Forzar que el contentView use capas para que el fondo sea sólido y nítido
    NSView *contentView = [window contentView];
    [contentView setWantsLayer:YES];
    [contentView layer].backgroundColor = [color CGColor];

    // 3. Forzamos el redibujado inmediato
    [window display];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(WNDSETGRADIENTCOLOR) // hWnd, r1, g1, b1, r2, g2, b2, angle
{
  NSWindow *window = (NSWindow *)hb_parnll(1);
  if (!window || ![window isKindOfClass:[NSWindow class]])
    return;

  // 1. Colores (son autorelease, no necesitan release manual)
  NSColor *color1 = [NSColor colorWithSRGBRed:hb_parnd(2) / 255.0
                                        green:hb_parnd(3) / 255.0
                                         blue:hb_parnd(4) / 255.0
                                        alpha:1.0];
  NSColor *color2 = [NSColor colorWithSRGBRed:hb_parnd(5) / 255.0
                                        green:hb_parnd(6) / 255.0
                                         blue:hb_parnd(7) / 255.0
                                        alpha:1.0];

  // 2. Gradiente con alloc (REQUIERE RELEASE)
  NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:color1
                                                       endingColor:color2];

  NSRect frame = [[window contentView] bounds];
  // 3. Imagen con alloc (REQUIERE RELEASE)
  NSImage *image = [[NSImage alloc] initWithSize:frame.size];

  [image lockFocus];
  [gradient drawInRect:frame angle:(CGFloat)hb_parnd(8)];
  [image unlockFocus];

  // 4. Color de patrón (es autorelease)
  NSColor *patternColor = [NSColor colorWithPatternImage:image];

  [window setBackgroundColor:patternColor];

  NSView *cv = [window contentView];
  [cv setWantsLayer:YES];
  [cv layer].backgroundColor = [patternColor CGColor];

  // 5. LIMPIEZA OBLIGATORIA PARA NO ARC
  [gradient release];
  [image release];

  [window display];
}

//--------------------------------------------------------------------------------//

HB_FUNC(WNDSETSHADOW) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  if (window && [window isKindOfClass:[NSWindow class]]) {
    // Usamos la sintaxis de setter clásica para máxima compatibilidad
    [window setHasShadow:hb_parl(2)];

    // Opcional: Forzar el refresco de la sombra
    [window invalidateShadow];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(WNDDESTROY) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  if (window && [window isKindOfClass:[NSWindow class]]) {
    // 1. Quitamos los delegados para evitar callbacks a objetos que ya no
    // existen
    [window setDelegate:nil];

    // 2. Cerramos la ventana.
    // Si 'releasedWhenClosed' es YES (por defecto), se liberará sola de la RAM.
    [window close];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(WNDFADEOUT) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  float alpha = 1.0;
  int x;
  [window setAlphaValue:alpha];
  [window makeKeyAndOrderFront:window];
  for (x = 0; x < 10; x++) {
    alpha -= 0.1;
    [window setAlphaValue:alpha];
    [NSThread sleepForTimeInterval:0.020];
  }
}

HB_FUNC(WNDFADEIN) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  float alpha = 0.0;
  int x;
  [window setAlphaValue:alpha];
  [window makeKeyAndOrderFront:window];
  for (x = 0; x < 10; x++) {
    alpha += 0.1;
    [window setAlphaValue:alpha];
    [NSThread sleepForTimeInterval:0.020];
  }
}

HB_FUNC(WNDFORCEHIDE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  if (window) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [window setAlphaValue:0.0]; // 100% invisible
      [window orderOut:nil];      // Sacar del flujo visual
    });
  }
}

HB_FUNC(WNDFORCESHOW) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  if (window) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [window setAlphaValue:1.0];        // Recuperar opacidad
      [window makeKeyAndOrderFront:nil]; // Traer al frente
    });
  }
}

HB_FUNC(WNDHIDE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  [window orderOut:window];
}

HB_FUNC(WNDSHOW) // hWnd
{
  NSWindow *window = (NSWindow *)hb_parnll(1);

  [window makeKeyAndOrderFront:window];
  [NSApp activateIgnoringOtherApps:YES];
}

HB_FUNC(WNDENABLE) // hWnd [, lOnOff ] --> lOnOff
{
  /*
  NSWindow * window = ( NSWindow * ) hb_parnl( 1 );

  if( ISLOG( 2 ) )
     [ window setEnabled : hb_parl( 2 ) ];

  hb_retl( [ window enabled ] );
  */
}

HB_FUNC(WNDSETMSGBAR) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  [window setAutorecalculatesContentBorderThickness:YES forEdge:NSMinYEdge];
  [window setContentBorderThickness:(hb_parnl(2) / 1.0) forEdge:NSMinYEdge];
}

NSView *GetTopView(NSWindow *window) {
  NSView *view = [window contentView];

  while ([window contentView] != nil)
    view = [window contentView];

  return view;
}

NSView *GetView(NSWindow *window) {
  if ([[window className] isEqual:@"ToolBar"]) {
    return ((View *)window);
  }

  if ([[window className] isEqual:@"NSBox"]) {
    return [window contentView];
  }

  else if ([window isKindOfClass:[NSView class]]) {
    return (NSView *)window;
  }

  else if ([[window className] isEqual:@"PrnView"]) {
    return ((PrnView *)window);
  }

  else if ([window isKindOfClass:[NSWindow class]]) {
    return [window contentView];
  }

  else
    return [((NSTabViewItem *)window) view];
}

HB_FUNC(FLDCREATE) {
  NSTabView *folder =
      [[NSTabView alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                  hb_parnl(3), hb_parnl(4))];
  NSWindow *window = (NSWindow *)hb_parnll(5);

  [GetView(window) addSubview:folder];

  hb_retnll((HB_LONGLONG)folder);
}

HB_FUNC(FLDADDITEM) {
  NSTabView *folder = (NSTabView *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);
  NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:string];
  View *view = [[View alloc] initWithFrame:[folder contentRect]];

  [item setLabel:string];
  [folder addTabViewItem:item];
  [item setView:view];

  hb_retnll((HB_LONGLONG)item);
}

HB_FUNC(CTLSETNEXTKEYVIEW) // hControl1, hControl2
{
  NSControl *control1 = (NSControl *)hb_parnll(1);
  NSControl *control2 = (NSControl *)hb_parnll(2);

  [control1 setNextKeyView:control2];
}

HB_FUNC(WINSIZECHANGE) // HControl ,nHeight,nWidth
{
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSRect frame = [window frame];

  CGFloat sizeyChange = hb_parnl(2);
  CGFloat sizexChange = hb_parnl(3);
  frame.size.height += sizeyChange;
  // Move the origin.
  frame.origin.y -= sizeyChange;
  frame.size.width += sizexChange;

  [window setFrame:frame display:YES animate:YES];
}

HB_FUNC(WNDSETPOS) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSRect frame = [window frame];

  if ([window respondsToSelector:@selector(enclosingScrollView)]) {
    NSScrollView *sv = [(NSView *)window enclosingScrollView];
    if (sv)
      window = (NSWindow *)sv;
    frame = [window frame];
  }

  frame.origin.y = hb_parnl(2);
  frame.origin.x = hb_parnl(3);

  if ([[window class] isSubclassOfClass:[NSControl class]] ||
      [[window class] isSubclassOfClass:[NSView class]] ||
      [[window class] isSubclassOfClass:[NSScrollView class]]) {
    NSControl *ctrl = (NSControl *)window;

    [ctrl setFrame:frame];
    [[ctrl window] display];
  } else
    [window setFrame:frame display:YES];
}

HB_FUNC(WINSETSIZE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  if ([window respondsToSelector:@selector(enclosingScrollView)]) {
    NSScrollView *sv = [(NSView *)window enclosingScrollView];
    if (sv)
      window = (NSWindow *)sv;
  }

  NSRect frame = [window frame];
  CGFloat nWidth = hb_parnl(2);
  CGFloat nHeight = hb_parnl(3);

  frame.origin.y -= nHeight - frame.size.height;
  frame.size.height = nHeight;
  frame.size.width = nWidth;

  [window setFrame:frame display:YES animate:YES];
}

//--------------------------------------------------------------------------------//

HB_FUNC(WINSETSIZECHANGE) // HControl, nHeight, nWidth
{
  // 1. Usamos 'id' para manejar tanto Window como View de forma dinámica
  id target = (id)hb_parnll(1);
  if (!target)
    return;

  // 2. Si es una vista (como un Browse), buscamos su ScrollView contenedor
  if ([target isKindOfClass:[NSView class]]) {
    NSScrollView *sv = [target enclosingScrollView];
    if (sv) {
      target = sv;
    }
  }

  // 3. Obtenemos el frame actual (funciona tanto para NSWindow como NSView)
  NSRect frame = [target frame];
  CGFloat newHeight = (CGFloat)hb_parnd(2);
  CGFloat newWidth = (CGFloat)hb_parnd(3);

  // 4. Lógica de coordenadas para que la ventana crezca hacia abajo (estilo
  // Clipper) Ajustamos el origen Y restando la diferencia de altura
  frame.origin.y -= (newHeight - frame.size.height);

  frame.size.height = newHeight;
  frame.size.width = newWidth;

  // 5. Aplicamos el cambio según el tipo de objeto
  if ([target isKindOfClass:[NSWindow class]]) {
    [target setFrame:frame display:YES animate:YES];
  } else {
    [target setFrame:frame];
    [[target superview] setNeedsDisplay:YES];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(WINHEIGHTCHANGE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  if (window && [window isKindOfClass:[NSWindow class]]) {
    NSRect frame = [window frame];

    // Usamos CGFloat para precisión en pantallas Retina
    CGFloat sizeChange = (CGFloat)hb_parnd(2);

    // 1. Aumentamos la altura
    frame.size.height += sizeChange;

    // 2. Bajamos el origen Y para que el "techo" de la ventana no se mueva
    frame.origin.y -= sizeChange;

    // 3. Aplicamos el cambio con animación nativa
    [window setFrame:frame display:YES animate:YES];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(WINWIDTHCHANGE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  if (window && [window isKindOfClass:[NSWindow class]]) {
    NSRect frame = [window frame];

    // Usamos CGFloat para precisión en pantallas Retina
    CGFloat sizeChange = (CGFloat)hb_parnd(2);

    // Aplicamos el cambio al ancho
    frame.size.width += sizeChange;

    // Si descomentas la siguiente línea, la ventana se expande hacia la
    // IZQUIERDA frame.origin.x -= sizeChange;

    // animate:YES hace que el cambio sea suave visualmente
    [window setFrame:frame display:YES animate:YES];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(CONTROLSETFOCUS) {
  NSView *control = (NSView *)hb_parnll(1);

  if (control && [control isKindOfClass:[NSView class]]) {
    NSWindow *window = [control window];

    if (window) {
      // 1. Traemos la aplicación al frente (si estaba en segundo plano)
      [NSApp activateIgnoringOtherApps:YES];

      // 2. Aseguramos que la ventana sea la principal
      [window makeKeyAndOrderFront:nil];

      // 3. Asignamos el foco al control específico
      [window makeFirstResponder:control];
    }
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(GOTONEXTCONTROL) {
  NSView *control = (NSView *)hb_parnll(1);

  if (control && [control isKindOfClass:[NSView class]]) {
    NSWindow *window = [control window];

    if (window) {
      // 1. Intentamos mover el foco al siguiente control en la cadena (Tab
      // Order)
      [window selectNextKeyView:nil];

      // 2. Opcional: Si quieres forzar que sea el siguiente relativo A UN
      // control:
      [window selectNextKeyView:control];
    }
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(SETAUTORESIZESSUBVIEWS) {
  NSView *view = (NSView *)hb_parnll(1);

  // Validamos que sea una vista antes de actuar
  if (view && [view isKindOfClass:[NSView class]]) {
    [view setAutoresizesSubviews:hb_parl(2)];
  }
}

//--------------------------------------------------------------------------------//

/*
HB_FUNC(WNDSETSUBVIEW) {
  NSWindow *window = (NSWindow *)hb_parnll(5);
  NSView *view =
      [[NSView alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                               hb_parnl(3), hb_parnl(4))];

  [GetView(window) addSubview:view];

  hb_retnll((HB_LONGLONG)view);
}
*/

HB_FUNC(WNDSETSUBVIEW) {
  NSWindow *window = (NSWindow *)hb_parnll(5);

  // 1. Creamos la vista con alloc (Ref Count = 1)
  NSView *view = [[NSView alloc]
      initWithFrame:NSMakeRect((CGFloat)hb_parnd(2), (CGFloat)hb_parnd(1),
                               (CGFloat)hb_parnd(3), (CGFloat)hb_parnd(4))];

  if (window && view) {
    // 2. Obtenemos el contenedor (suponiendo que GetView es tu macro/función
    // auxiliar)
    NSView *parentView = GetView(window);

    if (parentView) {
      // 3. addSubview incrementa el Ref Count a 2
      [parentView addSubview:view];

      // 4. LIBERACIÓN CRUCIAL: Bajamos el Ref Count a 1.
      // Ahora la ventana es la única "dueña". Cuando la ventana muera,
      // la vista morirá con ella.
      [view release];
    }
  }

  // 5. Devolvemos el puntero a Harbour (sigue siendo válido porque parentView
  // lo retiene)
  hb_retnll((HB_LONGLONG)view);
}

//--------------------------------------------------------------------------------//

HB_FUNC(WINDOWISFLIPPED) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  // 1. Verificamos que el objeto sea una ventana válida
  if (window && [window isKindOfClass:[NSWindow class]]) {

    // 2. Obtenemos la vista de contenido
    NSView *contentView = [window contentView];

    if (contentView) {
      // 3. Retornamos si la vista tiene las coordenadas invertidas (Y=0 arriba)
      hb_retl([contentView isFlipped]);
      return;
    }
  }

  // Si algo falla, devolvemos falso por defecto
  hb_retl(NO);
}

//--------------------------------------------------------------------------------//

HB_FUNC(WINDOWPRINT) {
  NSWindow *window = (NSWindow *)hb_parnll(1);

  // 1. Validamos que el objeto sea una ventana
  if (window && [window isKindOfClass:[NSWindow class]]) {
    NSView *contentView = [window contentView];

    if (contentView) {
      // 2. Ejecuta el diálogo de impresión estándar de macOS
      // En No ARC, Cocoa gestiona internamente la memoria del panel de
      // impresión
      [contentView print:nil];
    }
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(WM_GETTITLEHEIGHT) {
  NSWindow *window = (NSWindow *)hb_parnl(1);
  NSRect frame = [window frame];
  NSRect content = [window contentRectForFrameRect:frame];

  hb_retnl((long)(frame.size.height - content.size.height));
}

HB_FUNC(WNDGETGLASS) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  if (window && [window isKindOfClass:[NSWindow class]]) {
    if ([window respondsToSelector:@selector(titlebarAppearsTransparent)]) {
      if ([window titlebarAppearsTransparent]) {
        // Also check for NSWindowStyleMaskFullSizeContentView (1 << 15 = 32768)
        if ([window styleMask] & 32768) {
          hb_retl(YES);
          return;
        }
      }
    }
  }
  hb_retl(NO);
}

HB_FUNC(WNDALLOWVIBRANCY) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  if (window) {
    NSView *content = [window contentView];
    if ([content isKindOfClass:[View class]]) {
      ((View *)content)->bVibrancy = hb_parl(2);
      [content setNeedsDisplay:YES];
    }
  }
}
