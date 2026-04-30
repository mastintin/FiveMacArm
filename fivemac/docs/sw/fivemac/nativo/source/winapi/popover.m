#include <fivemac.h>

//----------------------------------------------------------//

@interface NSPopover (Message)
- (void)showRelativeToRect:(NSRect)rect
                    ofView:(NSView *)view
             preferredEdge:(NSRectEdge)edge
                    string:(NSString *)string
                  maxWidth:(float)width;
- (void)showWinRelativeToRect:(NSRect)rect
                       ofView:(NSView *)view
                preferredEdge:(NSRectEdge)edge
                       window:(NSWindow *)window
                     maxWidth:(float)width;
@end

@implementation NSPopover (Message)

- (void)showRelativeToRect:(NSRect)rect
                    ofView:(NSView *)view
             preferredEdge:(NSRectEdge)edge
                    string:(NSString *)string
                  maxWidth:(float)width {
  float padding = 5.0;

  // Suponiendo que sizeWithWidth:andFont: es una categoría de NSString que
  // devuelve NSSize
  NSFont *font = [NSFont
      systemFontOfSize:[NSFont
                           systemFontSizeForControlSize:NSControlSizeRegular]];
  NSSize size = GetStringSize(string, width, font);

  if (size.width < 20)
    size.width = 20;
  if (size.height < 10)
    size.height = 10;

  NSSize popoverSize =
      NSMakeSize(size.width + (padding * 2), size.height + (padding * 2));
  NSRect popoverRect = NSMakeRect(0, 0, popoverSize.width, popoverSize.height);

  // MRC: Usamos autorelease para que el label se libere cuando el contenedor se
  // destruya
  NSTextField *label = [[NSTextField alloc]
      initWithFrame:NSMakeRect(padding, padding, size.width, size.height)];

  [label setBezeled:NO];
  [label setDrawsBackground:NO];
  [label setEditable:NO];
  [label setSelectable:NO];
  [label setStringValue:string];
  [[label cell] setLineBreakMode:NSLineBreakByWordWrapping];

  // MRC: Autorelease para el contenedor
  NSView *container = [[NSView alloc] initWithFrame:popoverRect];
  [container addSubview:label];
  [label setFrame:NSMakeRect(padding, padding, size.width, size.height)];
  [label release];

  // MRC: Autorelease para el controlador
  NSViewController *controller = [[NSViewController alloc] init];
  [controller setView:container];
  [container release];

  [self setContentSize:popoverSize];
  [self setContentViewController:controller];
  [self setAnimates:YES];
  [self setBehavior:NSPopoverBehaviorTransient];
  [controller release];

  NSWindow *win = [view window];
  if (win) {
    NSView *contentView = [win contentView];
    NSRect rectInWin = [view convertRect:rect toView:nil];
    NSRect rectInContent = [contentView convertRect:rectInWin fromView:nil];
    [self showRelativeToRect:rectInContent
                      ofView:contentView
               preferredEdge:edge];
  } else {
    [self showRelativeToRect:rect ofView:view preferredEdge:edge];
  }
}

- (void)showWinRelativeToRect:(NSRect)rect
                       ofView:(NSView *)view
                preferredEdge:(NSRectEdge)edge
                       window:(NSWindow *)window
                     maxWidth:(float)width {
  float padding = 5;
  NSRect frame = [window frame];

  NSSize popoverSize = NSMakeSize(frame.size.width + (padding * 2),
                                  frame.size.height + (padding * 2));

  NSRect popoverRect = NSMakeRect(0, 0, popoverSize.width, popoverSize.height);

  // MRC: Autorelease para el contenedor
  NSView *container = [[NSView alloc] initWithFrame:popoverRect];
  NSView *winView = GetView(window);

  [container addSubview:winView];
  [winView setFrame:NSMakeRect(padding, padding, frame.size.width,
                               frame.size.height)];

  if ([winView respondsToSelector:@selector(setOriginalWindow:)]) {
    [winView performSelector:@selector(setOriginalWindow:) withObject:window];
  }

  // MRC: Autorelease para el controlador
  NSViewController *controller = [[NSViewController alloc] init];
  [controller setView:container];
  [container release];

  [self setContentSize:popoverSize];
  [self setContentViewController:controller];
  [self setAnimates:YES];
  [self setBehavior:NSPopoverBehaviorTransient];

  [self showRelativeToRect:rect ofView:view preferredEdge:edge];
  [controller release];
}

@end

//----------------------------------------------------------//
HB_FUNC(SHOWPOPOVER) {
  NSControl *theInput = (NSControl *)hb_parnll(1);
  NSString *mystring = hb_NSSTRING_par(2);

  float width =
      (hb_pcount() >= 3 && hb_parnd(3) > 0) ? (float)hb_parnd(3) : 250.0f;

  // 1. Creamos el objeto. (Retain count = 1)
  NSPopover *popover = [[NSPopover alloc] init];

  if (theInput && popover) {
    // 2. Lo mostramos.
    // Usamos autorelease para que el objeto se libere solo cuando se cierre
    // la piscina de eventos, a menos que Harbour lo retenga.
    [popover autorelease];

    [popover showRelativeToRect:[theInput bounds]
                         ofView:theInput
                  preferredEdge:NSMaxYEdge
                         string:mystring
                       maxWidth:width];
  }

  // 3. Devolvemos el puntero a Harbour.
  hb_retnll((HB_LONGLONG)popover);
}

//----------------------------------------------------------//

HB_FUNC(SHOWWINPOPOVER) {
  NSControl *theInput = (NSControl *)hb_parnll(1);
  NSWindow *window = (NSWindow *)hb_parnll(2);

  float width =
      (hb_pcount() >= 3 && hb_parnd(3) > 0) ? (float)hb_parnd(3) : 250.0f;

  // Usamos autorelease para que la memoria se gestione correctamente
  // El popover se mantendrá vivo mientras esté en pantalla.
  NSPopover *popover = [[[NSPopover alloc] init] autorelease];

  if (theInput && popover) {
    [popover showWinRelativeToRect:[theInput frame]
                            ofView:[theInput superview]
                      preferredEdge:NSMaxYEdge
                             window:window
                           maxWidth:width];
  }

  hb_retnll((HB_LONGLONG)popover);
}

//----------------------------------------------------------//

HB_FUNC(SETPOPOVERAPPEARANCE) {
  NSPopover *popover = (NSPopover *)hb_parnll(1);
  int nAppearance = hb_parni(2);

  if (popover) {
    NSAppearanceName names[] = {NSAppearanceNameAqua,
                                NSAppearanceNameVibrantDark,
                                NSAppearanceNameVibrantLight};
    if (nAppearance >= 0 && nAppearance <= 2) {
      // appearanceNamed NO requiere release (es un factory method)
      popover.appearance = [NSAppearance appearanceNamed:names[nAppearance]];
    }
  }
}

//----------------------------------------------------------//

HB_FUNC(CLOSEPOPOVER) {
  NSPopover *popover = (NSPopover *)hb_parnll(1);
  if (popover) {
    [popover close];
  }
}

//----------------------------------------------------------//

//----------------------------------------------------------//

HB_FUNC(POPOVER_RELEASE) {
  // 1. Obtenemos el puntero del popover desde Harbour
  NSPopover *popover = (NSPopover *)hb_parnll(1);

  if (popover != NULL) {
    // 2. Verificamos que sea un objeto válido antes de liberar
    if ([popover isKindOfClass:[NSPopover class]]) {
      [popover release];
    }
  }
}

//----------------------------------------------------------//
