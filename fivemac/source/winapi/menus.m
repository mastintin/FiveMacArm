#include <fivemac.h>

// to avoid the non Method found warning
@interface NSApplication (SDL_Missing_Methods)
- (void)setAppleMenu:(NSMenu *)menu;
@end

HB_FUNC(MNUCREATE) // cPrompt --> hMenu
{
  NSString *prompt = hb_NSSTRING_par(1);
  NSMenu *menu = [[[NSMenu alloc] initWithTitle:prompt] autorelease];

  hb_retnll((HB_LONGLONG)menu);
}

HB_FUNC(MNUADDITEM) // hMenu, cPrompt, cKey --> hMenuItem
{
  NSMenu *menu = (NSMenu *)hb_parnll(1);
  NSString *prompt = hb_NSSTRING_par(2);
  NSString *key = hb_NSSTRING_par(3);

  hb_retnll((HB_LONGLONG)[menu addItemWithTitle:prompt
                                         action:@selector(MenuItem:)
                                  keyEquivalent:key]);
}

HB_FUNC(MNUADDSEPARATOR) // hMenu
{
  NSMenu *menu = (NSMenu *)hb_parnll(1);

  [menu addItem:[NSMenuItem separatorItem]];
}

HB_FUNC(MNUADDSUBMENU) // hMenu, hSubMenu, nIndex
{
  NSMenu *menu = (NSMenu *)hb_parnll(1);
  NSMenu *submenu = (NSMenu *)hb_parnll(2);
  NSMenuItem *item = [menu itemAtIndex:hb_parnl(3) - 1];

  [menu setSubmenu:submenu forItem:item];
}

#if __MAC_OS_X_VERSION_MAX_ALLOWED > 1050

HB_FUNC(MNUACTIVATE) // hMenu
{
  NSMenu *menu = (NSMenu *)hb_parnll(1);

  [NSApp setMainMenu:menu];
}

#else

HB_FUNC(MNUACTIVATE) // hMenu
{
  NSMenu *menu = (NSMenu *)hb_parnll(1);
  NSMenu *appleMenu = [[menu itemAtIndex:0] submenu];

  [NSApp setMainMenu:menu];
  [NSApp setAppleMenu:appleMenu]; // El menu vertical just al lado de la manzana
}

#endif

HB_FUNC(GETAPPMENU) // hMenu, hSubMenu, nIndex
{
  hb_retnll((HB_LONGLONG)NSApp.mainMenu);
}

HB_FUNC(MNUITEMTEXT) {
  NSMenuItem *item = (NSMenuItem *)hb_parnll(1);
  hb_retc([[item title] cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(MNUGETITEMINDEX) {
  NSMenu *menu = (NSMenu *)hb_parnll(1);
  hb_retnll((HB_LONGLONG)[menu itemAtIndex:hb_parni(2)]);
}

HB_FUNC(MNUITEMSETIMAGE) {
  NSMenuItem *item = (NSMenuItem *)hb_parnll(1);
  NSImage *image = nil;

  if (HB_ISNUM(2)) {
    image = (NSImage *)hb_parnll(2);
  } else {
    NSString *string = hb_NSSTRING_par(2);
    NSFileManager *filemgr = [NSFileManager defaultManager];

    if ([filemgr fileExistsAtPath:string])
      image = [[[NSImage alloc] initWithContentsOfFile:string] autorelease];
    else
      image = ImgTemplate(string);
  }

  if (image) {
    if (hb_parnl(3) > 0)
      ImgResize(image, hb_parnl(3), hb_parnl(4));

    [item setImage:image];
  }
}

HB_FUNC(MNUITEMSETONIMAGE) {
  NSMenuItem *item = (NSMenuItem *)hb_parnll(1);
  NSImage *image = nil;

  if (HB_ISNUM(2)) {
    image = (NSImage *)hb_parnll(2);
  } else {
    NSString *string = hb_NSSTRING_par(2);
    NSFileManager *filemgr = [NSFileManager defaultManager];

    if ([filemgr fileExistsAtPath:string])
      image = [[[NSImage alloc] initWithContentsOfFile:string] autorelease];
    else
      image = ImgTemplate(string);
  }

  if (image)
    [item setOnStateImage:image];
}

HB_FUNC(MNUITEMSETOFFIMAGE) {
  NSMenuItem *item = (NSMenuItem *)hb_parnll(1);
  NSImage *image = nil;

  if (HB_ISNUM(2)) {
    image = (NSImage *)hb_parnll(2);
  } else {
    NSString *string = hb_NSSTRING_par(2);
    NSFileManager *filemgr = [NSFileManager defaultManager];

    if ([filemgr fileExistsAtPath:string])
      image = [[[NSImage alloc] initWithContentsOfFile:string] autorelease];
    else
      image = ImgTemplate(string);
  }

  if (image)
    [item setOffStateImage:image];
}

HB_FUNC(MNUITEMSETTOOLTIP) {
  NSMenuItem *item = (NSMenuItem *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);

  [item setToolTip:string];
}

HB_FUNC(MNUITEMSETON) {
  NSMenuItem *item = (NSMenuItem *)hb_parnll(1);

  [item setState:NSControlStateValueOn];
}

HB_FUNC(MNUITEMSETOFF) {
  NSMenuItem *item = (NSMenuItem *)hb_parnll(1);

  [item setState:NSControlStateValueOff];
}

HB_FUNC(MNUITEMSETMIXED) {
  NSMenuItem *item = (NSMenuItem *)hb_parnll(1);

  [item setState:NSControlStateValueMixed];
}

HB_FUNC(POPMNUCONTEXT) {
  NSMenu *menu = (NSMenu *)hb_parnll(1);
  NSView *view = (NSView *)hb_parnll(2);
  NSRect frame = [view frame];
  NSPoint menuOrigin = [[view superview]
      convertPoint:NSMakePoint(frame.origin.x,
                               frame.origin.y + frame.size.height + 40)
            toView:nil];
  int windowNumber = [[view window] windowNumber];
  NSEvent *event = [NSEvent mouseEventWithType:NSEventTypeLeftMouseDown
                                      location:menuOrigin
                                 modifierFlags:0 // NSLeftMouseDownMask // 0x100
                                     timestamp:0
                                  windowNumber:windowNumber
                                       context:[[view window] graphicsContext]
                                   eventNumber:0
                                    clickCount:1
                                      pressure:1];

  [NSMenu popUpContextMenu:menu withEvent:event forView:view];
}

HB_FUNC(POPMNUSHOW) {
  NSMenu *menu = (NSMenu *)hb_parnll(1);
  NSWindow *window = (NSWindow *)hb_parnll(2);
  NSPoint menuOrigin =
      [[window contentView] convertPoint:NSMakePoint(hb_parnl(4), hb_parnl(3))
                                  toView:nil];
  NSEvent *event = [NSEvent mouseEventWithType:NSEventTypeLeftMouseDown
                                      location:menuOrigin
                                 modifierFlags:0 // NSLeftMouseDownMask // 0x100
                                     timestamp:0
                                  windowNumber:[window windowNumber]
                                       context:[window graphicsContext]
                                   eventNumber:0
                                    clickCount:1
                                      pressure:1];

  [NSMenu popUpContextMenu:menu withEvent:event forView:[window contentView]];
}
