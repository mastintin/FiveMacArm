#include <fivemac.h>

HB_FUNC(BRUSHCREATESOLID) // nRed, nGreen, nBlue, nAlpha
{
  NSColor *color = [NSColor colorWithCalibratedRed:hb_parnd(1) / 255.0
                                             green:hb_parnd(2) / 255.0
                                              blue:hb_parnd(3) / 255.0
                                             alpha:hb_parnd(4) / 255.0];
  [color retain];
  hb_retnll((HB_LONGLONG)color);
}

HB_FUNC(BRUSHCREATEPATTERN) // cImageFile
{
  NSString *string = hb_NSSTRING_par(1);
  NSImage *image = [[NSImage alloc] initWithContentsOfFile:string];

  if (image) {
    NSColor *color = [NSColor colorWithPatternImage:image];
    [color retain];
    [image release];
    hb_retnll((HB_LONGLONG)color);
  } else
    hb_retnll(0);
}

HB_FUNC(BRUSHCREATEGRADIENT) // nR1, nG1, nB1, nR2, nG2, nB2, nAngle, nWidth,
                             // nHeight
{
  NSColor *color1 = [NSColor colorWithCalibratedRed:hb_parnd(1) / 255.0
                                              green:hb_parnd(2) / 255.0
                                               blue:hb_parnd(3) / 255.0
                                              alpha:1.0];
  NSColor *color2 = [NSColor colorWithCalibratedRed:hb_parnd(4) / 255.0
                                              green:hb_parnd(5) / 255.0
                                               blue:hb_parnd(6) / 255.0
                                              alpha:1.0];
  NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:color1
                                                       endingColor:color2];

  NSSize size = NSMakeSize(hb_parni(8), hb_parni(9));
  if (size.width == 0)
    size.width = 100;
  if (size.height == 0)
    size.height = 100;

  NSImage *image = [[NSImage alloc] initWithSize:size];

  [image lockFocus];
  [gradient drawInRect:NSMakeRect(0, 0, size.width, size.height)
                 angle:hb_parni(7)];
  [image unlockFocus];

  NSColor *color = [NSColor colorWithPatternImage:image];
  [color retain];

  [image release];
  [gradient release];

  hb_retnll((HB_LONGLONG)color);
}

HB_FUNC(BRUSHRELEASE) {
  id obj = (id)hb_parnll(1);
  if (obj)
    [obj release];
}

HB_FUNC(WNDSETCOLOR) // hWnd, hColor
{
  id obj = (id)hb_parnll(1);
  NSColor *color = (NSColor *)hb_parnll(2);

  if (obj && color) {
    if ([obj respondsToSelector:@selector(setBackgroundColor:)])
      [obj setBackgroundColor:color];

    if ([obj isKindOfClass:[NSWindow class]]) {
      NSView *view = [(NSWindow *)obj contentView];
      [view setWantsLayer:YES];
      [view layer].backgroundColor = [color CGColor];
    }
  }
}
