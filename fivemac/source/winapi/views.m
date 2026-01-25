#include <QuartzCore/QuartzCore.h>
#include <fivemac.h>
#include <hbapiitm.h>

HB_FUNC(VIEWSETAUTORESIZE) {
  NSView *view = (NSView *)hb_parnll(1);

  if ([[view class] isSubclassOfClass:[NSTableView class]])
    view = [view enclosingScrollView];

  [view setAutoresizingMask:hb_parnl(2)];
}

HB_FUNC(VIEWAUTORESIZE) {
  NSView *view = (NSView *)hb_parnll(1);

  if ([[view class] isSubclassOfClass:[NSTableView class]])
    view = [view enclosingScrollView];

  hb_retnl([view autoresizingMask]);
}

HB_FUNC(VIEWSETBACKCOLOR) {
  NSView *view = (NSView *)hb_parnll(1);
  NSColor *color = (NSColor *)hb_parnll(2);
  view.layer.backgroundColor = color.CGColor;
  //   [  view setBackgroundColor: color ];
}

HB_FUNC(VIEWSETSIZE) {
  NSView *view = (NSView *)hb_parnll(1);

  [view setFrameSize:NSMakeSize(hb_parnl(2), hb_parnl(3))];
}

HB_FUNC(VIEWHIDE) {
  NSView *window = (NSView *)hb_parnll(1);

  [window setHidden:YES];
}

HB_FUNC(VIEWSHOW) {
  NSView *window = (NSView *)hb_parnll(1);

  [window setHidden:NO];
}

HB_FUNC(VIEWSETTOOLTIP) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);

  [(NSView *)window setToolTip:string];
}

HB_FUNC(VIEWEND) {
  NSView *view = (NSView *)hb_parnll(1);

  if ([[view class] isSubclassOfClass:[NSTableView class]])
    view = [view enclosingScrollView];

  [view removeFromSuperview];
}

HB_FUNC(OSCONTROLGETSIZE) {
  NSView *object = (NSView *)hb_parnll(1);
  CGFloat width = 0.0, height = 0.0;

  if (object) {
    NSSize size = [object frame].size;
    width = size.width;
    height = size.height;
  }

  hb_reta(2);
  hb_itemPutND(hb_arrayGetItemPtr(hb_param(-1, HB_IT_ANY), 1), (double)width);
  hb_itemPutND(hb_arrayGetItemPtr(hb_param(-1, HB_IT_ANY), 2), (double)height);
}

// --- New Functions from Main.prg ---

HB_FUNC(VIEWCLEAN) {
  NSView *view = (NSView *)hb_parnll(1);
  NSArray *subviews = [[view subviews] copy];
  [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [subviews release];
}

HB_FUNC(VIEWSETCORNERRADIUS) {
  NSView *view = (NSView *)hb_parnll(1);
  CGFloat radius = (CGFloat)hb_parnd(2);

  [view setWantsLayer:YES];
  view.layer.cornerRadius = radius;
  view.layer.masksToBounds = YES;
}

HB_FUNC(VIEWSETGRADIENTCOLOR) {
  NSView *view = (NSView *)hb_parnll(1);
  // Color 1: Dark Blue
  /*
   CGFloat r1 = 0.0;
   CGFloat g1 = 50.0 / 255.0;
   CGFloat b1 = 150.0 / 255.0;
   CGFloat a1 = 0.9;

   // Color 2: Regular Blue
   CGFloat r2 = 0.0;
   CGFloat g2 = 0.0;
   CGFloat b2 = 1.0;
   CGFloat a2 = 0.6;
 */

  CGFloat r1 = hb_parnd(2) / 255.0;
  CGFloat g1 = hb_parnd(3) / 255.0;
  CGFloat b1 = hb_parnd(4) / 255.0;
  CGFloat a1 = hb_parnd(5);

  // Color 2: Regular Blue
  CGFloat r2 = hb_parnd(6) / 255.0;
  CGFloat g2 = hb_parnd(7) / 255.0;
  CGFloat b2 = hb_parnd(8) / 255.0;
  CGFloat a2 = hb_parnd(9);

  [view setWantsLayer:YES];

  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = view.layer.bounds;

  [gradient setNeedsDisplayOnBoundsChange:YES];

  gradient.startPoint = CGPointMake(0.0, 0.5);
  gradient.endPoint = CGPointMake(1.0, 0.5);

  NSColor *c1 = [NSColor colorWithCalibratedRed:r1 green:g1 blue:b1 alpha:a1];
  NSColor *c2 = [NSColor colorWithCalibratedRed:r2 green:g2 blue:b2 alpha:a2];

  gradient.colors =
      [NSArray arrayWithObjects:(id)[c1 CGColor], (id)[c2 CGColor], nil];

  gradient.autoresizingMask =
      2 | 16; // kCALayerWidthSizable | kCALayerHeightSizable

  view.layer.backgroundColor = [c1 CGColor];

  view.layer.sublayers = nil;
  [view.layer addSublayer:gradient];
}
