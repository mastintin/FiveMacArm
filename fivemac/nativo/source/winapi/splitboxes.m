#include <fivemac.h>

@interface FMSplitView : NSSplitView <NSSplitViewDelegate>
@end

@implementation FMSplitView

- (BOOL)isFlipped {
  return YES;
}

- (CGFloat)splitView:(NSSplitView *)splitView
    constrainMinCoordinate:(CGFloat)proposedMinimumPosition
          ofDividerAtIndex:(NSInteger)dividerIndex {
  return proposedMinimumPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView
    constrainMaxCoordinate:(CGFloat)proposedMaximumPosition
          ofDividerAtIndex:(NSInteger)dividerIndex {
  return proposedMaximumPosition;
}

@end

HB_FUNC(SPLITBOXCREATE) {
  NSRect frame = NSMakeRect(hb_parnl(2), hb_parnl(1), hb_parnl(3), hb_parnl(4));
  FMSplitView *splitView = [[FMSplitView alloc] initWithFrame:frame];
  NSWindow *window = (NSWindow *)hb_parnll(5);

  [splitView setVertical:hb_parl(6)];
  [splitView setDividerStyle:NSSplitViewDividerStyleThin];
  [splitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [splitView setDelegate:splitView];

  [GetView(window) addSubview:splitView];

  hb_retnll((HB_LONGLONG)splitView);
}

HB_FUNC(SPLITBOXADDVIEW) {
  NSSplitView *splitView = (NSSplitView *)hb_parnll(1);
  View *subview = [[View alloc] initWithFrame:[splitView bounds]];

  [subview setWantsLayer:YES];
  [subview setAutoresizesSubviews:YES];
  [splitView addSubview:subview];
  [splitView adjustSubviews];

  hb_retnll((HB_LONGLONG)subview);
}

HB_FUNC(SPLITBOXSETVERTICAL) {
  NSSplitView *splitView = (NSSplitView *)hb_parnll(1);
  [splitView setVertical:hb_parl(2)];
  [splitView adjustSubviews];
}

HB_FUNC(SPLITBOXSETSTYLE) {
  NSSplitView *splitView = (NSSplitView *)hb_parnll(1);
  [splitView setDividerStyle:hb_parnl(2)];
}

HB_FUNC(SPLITBOXSETPOSITION) {
  NSSplitView *splitView = (NSSplitView *)hb_parnll(1);
  [splitView setPosition:(CGFloat)hb_parnd(3) ofDividerAtIndex:hb_parni(2)];
}
