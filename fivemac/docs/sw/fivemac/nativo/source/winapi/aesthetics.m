#import "fivemac.h"
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

// Identifier to trace the glass background sibling
#define GLASS_ID @"LiquidGlassSibling"

static char const *const BaseFrameKey = "FTBaseFrame";

@interface NSView (LiquidGlass)
- (void)applyTahoeGlassWithRadius:(CGFloat)radius;
- (void)animateTahoeClick:(BOOL)pressed;
@end

// ---------------------------------------------------------------------------
// FTTahoeButton: A proxy class to handle events without full subclassing
// We will use this to intercept events in a clean way
// ---------------------------------------------------------------------------

@interface FTTahoeButton : NSButton
@end

@implementation FTTahoeButton

- (void)mouseDown:(NSEvent *)event {
  [self animateTahoeClick:YES];
  [super mouseDown:event];
  [self animateTahoeClick:NO];
}

@end

@implementation NSView (LiquidGlass)

- (void)animateTahoeClick:(BOOL)pressed {
  NSValue *val = objc_getAssociatedObject(self, BaseFrameKey);
  if (!val)
    return;
  CGRect originalFrame = [val rectValue];

  CGFloat scale = pressed ? 0.94 : 1.0;
  CGFloat duration = pressed ? 0.05 : 0.2;

  CGFloat offsetX = (originalFrame.size.width * (1.0 - scale)) * 0.5;
  CGFloat offsetY = (originalFrame.size.height * (1.0 - scale)) * 0.5;

  CGRect targetFrame = CGRectMake(
      originalFrame.origin.x + offsetX, originalFrame.origin.y + offsetY,
      originalFrame.size.width * scale, originalFrame.size.height * scale);

  [NSAnimationContext
      runAnimationGroup:^(NSAnimationContext *_Nonnull context) {
        context.duration = duration;
        context.timingFunction = [CAMediaTimingFunction
            functionWithName:kCAMediaTimingFunctionEaseOut];
        [[self animator] setFrame:targetFrame];
      }
      completionHandler:nil];

  NSView *parent = [self superview];
  for (NSView *sub in parent.subviews) {
    if ([sub.identifier isEqualToString:GLASS_ID]) {
      CGPoint controlCenter = CGPointMake(CGRectGetMidX(originalFrame),
                                          CGRectGetMidY(originalFrame));
      if (CGRectContainsPoint(sub.frame, controlCenter)) {
        [NSAnimationContext
            runAnimationGroup:^(NSAnimationContext *_Nonnull context) {
              context.duration = duration;
              context.timingFunction = [CAMediaTimingFunction
                  functionWithName:kCAMediaTimingFunctionEaseOut];
              [[sub animator] setFrame:targetFrame];
            }
            completionHandler:nil];
      }
    }
  }
}

- (void)applyTahoeGlassWithRadius:(CGFloat)radius {
  NSView *parent = [self superview];
  if (!parent)
    return;

  if (radius <= 0)
    radius = 12.0;

  [parent setWantsLayer:YES];
  [self setWantsLayer:YES];

  // Store the BASE frame if not already stored
  NSValue *storedFrame = objc_getAssociatedObject(self, BaseFrameKey);
  if (!storedFrame) {
    objc_setAssociatedObject(self, BaseFrameKey,
                             [NSValue valueWithRect:self.frame],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }

  // Cleanup old siblings
  for (NSView *sub in [[parent subviews] copy]) {
    if ([sub.identifier isEqualToString:GLASS_ID]) {
      CGPoint controlCenter =
          CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
      if (CGRectContainsPoint(sub.frame, controlCenter)) {
        if (sub != self)
          [sub removeFromSuperview];
      }
    }
  }

  if ([self isKindOfClass:[NSButton class]]) {
    NSButton *btn = (NSButton *)self;
    [btn setBordered:NO];
    [btn setBezelStyle:NSBezelStyleShadowlessSquare];
    if ([btn cell]) {
      [(NSButtonCell *)[btn cell] setBackgroundColor:[NSColor clearColor]];
    }

    // Switch to our Tahoe class to intercept events
    object_setClass(btn, [FTTahoeButton class]);

  } else if ([self isKindOfClass:[NSTextField class]]) {
    NSTextField *txt = (NSTextField *)self;
    [txt setBordered:NO];
    [txt setDrawsBackground:NO];
    [txt setBezeled:NO];
  } else if ([self isKindOfClass:[NSBox class]]) {
    NSBox *box = (NSBox *)self;
    [box setBoxType:NSBoxCustom];
    [box setTransparent:YES];
    [box setFillColor:[NSColor clearColor]];
  }

  // Sibling Container
  NSView *container = [[NSView alloc] initWithFrame:self.frame];
  container.identifier = GLASS_ID;
  container.autoresizingMask = self.autoresizingMask;
  container.wantsLayer = YES;
  container.layer.masksToBounds = NO;

  container.layer.shadowColor = [[NSColor blackColor] CGColor];
  container.layer.shadowOpacity = 0.35;
  container.layer.shadowRadius = 10.0;
  container.layer.shadowOffset = CGSizeMake(0, -6);

  // Glass Layer
  NSVisualEffectView *vew =
      [[NSVisualEffectView alloc] initWithFrame:container.bounds];
  vew.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  vew.blendingMode = NSVisualEffectBlendingModeWithinWindow;
  vew.state = NSVisualEffectStateActive;
  vew.material = NSVisualEffectMaterialHUDWindow;

  vew.wantsLayer = YES;
  vew.layer.cornerRadius = radius;
  vew.layer.masksToBounds = YES;

  // Gloss
  CAGradientLayer *glossLayer = [CAGradientLayer layer];
  glossLayer.frame = vew.bounds;
  glossLayer.cornerRadius = radius;
  glossLayer.masksToBounds = YES;
  glossLayer.colors = @[
    (id)[[NSColor colorWithWhite:1.0 alpha:0.18] CGColor],
    (id)[[NSColor colorWithWhite:1.0 alpha:0.0] CGColor]
  ];
  glossLayer.startPoint = CGPointMake(0.5, 0.0);
  glossLayer.endPoint = CGPointMake(0.5, 0.5);
  [vew.layer addSublayer:glossLayer];

  // BORDER (Rim Light)
  vew.layer.borderWidth = 1.5;
  vew.layer.borderColor = [[NSColor colorWithWhite:1.0 alpha:0.65] CGColor];

  [container addSubview:vew];
  [parent addSubview:container positioned:NSWindowBelow relativeTo:self];

  [vew release];
  [container release];
}

@end

HB_FUNC(VIEWSETLIQUIDGLASS) {
  NSView *view = (NSView *)hb_parnll(1);
  CGFloat nRadius = (CGFloat)hb_parnd(2);

  if (view) {
    [view applyTahoeGlassWithRadius:nRadius];
  }
}

HB_FUNC(VIEWSETSHADOW) {
  NSView *view = (NSView *)hb_parnll(1);
  if (view) {
    [view setWantsLayer:YES];
    view.layer.shadowColor = [[NSColor blackColor] CGColor];
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowRadius = 10.0;
    view.layer.shadowOffset = CGSizeMake(0, -5);
  }
}

HB_FUNC(VIEWSETBORDER) {
  NSView *view = (NSView *)hb_parnll(1);
  if (view) {
    [view setWantsLayer:YES];
    view.layer.borderWidth = 1.0;
    view.layer.borderColor = [[NSColor colorWithCalibratedWhite:1.0
                                                          alpha:0.4] CGColor];
  }
}
