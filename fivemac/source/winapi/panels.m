#include <fivemac.h>

@interface FiveFlippedView : NSView {
  BOOL _isFlipped;
}
- (id)initWithFrame:(NSRect)frame flipped:(BOOL)flipped;
- (BOOL)isFlipped;
- (NSView *)view;
- (NSView *)contentView;
@end

@implementation FiveFlippedView

- (id)initWithFrame:(NSRect)frame flipped:(BOOL)flipped {
  self = [super initWithFrame:frame];
  if (self) {
    _isFlipped = flipped;
    // if (flipped) {
    //   _isFlipped = YES; // FORCED: Reverted to hardcoded YES as requested
    // } else {
    //   _isFlipped = NO;
    // }
  }
  return self;
}

- (BOOL)isFlipped {
  return _isFlipped;
}
- (NSView *)view {
  return self;
}
- (NSView *)contentView {
  return self;
}
@end

HB_FUNC(PANELCREATE) {
  NSView *parent = GetView((NSWindow *)hb_parnll(5));
  BOOL bFlipped = hb_parl(6);

  FiveFlippedView *view = [[FiveFlippedView alloc]
      initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1), hb_parnl(3),
                               hb_parnl(4))
            flipped:bFlipped];

  [parent addSubview:view];

  hb_retnll((HB_LONGLONG)view);
}

HB_FUNC(PANELSETCOLOR) {
  NSView *view = (NSView *)hb_parnll(1);
  [view setWantsLayer:YES];

  float fRed = hb_parnl(2) / 255.0;
  float fGreen = hb_parnl(3) / 255.0;
  float fBlue = hb_parnl(4) / 255.0;
  float fAlpha = hb_parnl(5) / 100.0;

  if (fAlpha == 0)
    fAlpha = 1.0;

  NSColor *color = [NSColor colorWithCalibratedRed:fRed
                                             green:fGreen
                                              blue:fBlue
                                             alpha:fAlpha];
  [view.layer setBackgroundColor:[color CGColor]];
}

HB_FUNC(PANELSETSHADOW) {
  NSView *view = (NSView *)hb_parnll(1);
  float fOpacity = hb_parnl(2) / 100.0;
  float fRadius = hb_parnl(3);
  float fOffSetW = hb_parnl(4);
  float fOffSetH = hb_parnl(5);

  [view setWantsLayer:YES];
  view.layer.masksToBounds =
      NO; // Critical for shadows to be visible outside bounds
  view.layer.shadowColor = [[NSColor blackColor] CGColor];
  view.layer.shadowOpacity = fOpacity;
  view.layer.shadowRadius = fRadius;
  view.layer.shadowOffset = CGSizeMake(fOffSetW, fOffSetH);
}
