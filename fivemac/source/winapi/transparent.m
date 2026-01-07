#include <fivemac.h>

HB_FUNC(SETTRANS) // hWnd
{
  NSView *view = [[NSView alloc] init];
  NSWindow *window = (NSWindow *)hb_parnll(1);
  [window setAlphaValue:hb_parnd(2)];

  hb_retnll((HB_LONGLONG)view);
}

HB_FUNC(SPLASHCREATE) // nTop, nLeft, nWidth, nHeight
{
  float x = hb_parnd(2);
  float y = hb_parnd(1);
  float width = hb_parnd(3);
  float height = hb_parnd(4);

  NSScreen *screen = [NSScreen mainScreen];
  NSRect screenFrame = [screen frame];

  NSRect content =
      NSMakeRect(x, screenFrame.size.height - y - height, width, height);

  NSWindow *w =
      [[NSWindow alloc] initWithContentRect:content
                                  styleMask:NSWindowStyleMaskBorderless
                                    backing:NSBackingStoreBuffered
                                      defer:NO];

  hb_retnll((HB_LONGLONG)w);
}

HB_FUNC(SPLASHSETFILE) // hWnd
{
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);

  [window setBackgroundColor:[NSColor colorWithPatternImage:
                                          [[NSImage alloc]
                                              initByReferencingFile:string]]];
  [window setOpaque:NO];
}

HB_FUNC(SPLASHRUN) // hWnd
{
  NSWindow *window = (NSWindow *)hb_parnll(1);

  [window makeKeyAndOrderFront:nil];
  [window display];

  // Process events to ensure repaint
  [[NSRunLoop currentRunLoop]
      runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

  usleep(5 * 1000000);
  [window close];
}

/*
id) initWithContentRect: (NSRect) contentRect
styleMask: (unsigned int) aStyle
backing: (NSBackingStoreType) bufferingType
defer: (BOOL) flag
{
    if (![super initWithContentRect: contentRect
                          styleMask: NSBorderlessWindowMask
                            backing: bufferingType
                              defer: flag]) return nil;
    [self setBackgroundColor: [NSColor clearColor]];
    [self setOpaque:NO];

    return self;*/
