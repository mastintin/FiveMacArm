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
