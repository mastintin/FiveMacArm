#import <Cocoa/Cocoa.h>
#include <fivemac.h>

@interface ViewStackBar : NSView
@property(strong) NSStackView *stackView;
@property(strong) NSVisualEffectView *effectView;
@property(strong) NSLayoutConstraint *stackHeightConstraint;
@property(assign) CGFloat btnWidth;
@property(assign) CGFloat btnHeight;
@end

@implementation ViewStackBar

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    // Defaults
    _btnWidth = 90.0;
    _btnHeight = 40.0; // Matches default stack height
    [self setupToolbar];
  }
  return self;
}

- (BOOL)isFlipped {
  return YES;
}

- (void)setupToolbar {
  // 1. Efecto de fondo (The Capsule)
  self.effectView = [[NSVisualEffectView alloc] init];

  if (@available(macOS 10.14, *)) {
    self.effectView.material = NSVisualEffectMaterialHeaderView;
  } else {
    self.effectView.material = 1;
  }

  self.effectView.blendingMode =
      NSVisualEffectBlendingModeWithinWindow; // Vibrancy enabled
  self.effectView.state = NSVisualEffectStateActive;
  self.effectView.translatesAutoresizingMaskIntoConstraints = NO;

  // Rounded Corners for Capsule Look
  self.effectView.wantsLayer = YES;
  self.effectView.layer.cornerRadius = 16.0;
  self.effectView.layer.masksToBounds = YES;
  self.effectView.layer.borderWidth = 1.0;
  self.effectView.layer.borderColor =
      [NSColor colorWithWhite:1.0 alpha:0.1].CGColor;

  [self addSubview:self.effectView];

  // 2. Configurar StackView
  self.stackView = [[NSStackView alloc] init];
  self.stackView.orientation = NSUserInterfaceLayoutOrientationHorizontal;
  self.stackView.alignment = NSLayoutAttributeCenterY;
  self.stackView.spacing = 10.0;
  self.stackView.edgeInsets = NSEdgeInsetsMake(0, 0, 0, 0);
  self.stackView.translatesAutoresizingMaskIntoConstraints = NO;

  // Add stackView INSIDE effectView (Hierarchy Refactor)
  [self.effectView addSubview:self.stackView];

  // Store constraint for future updates (Height)
  self.stackHeightConstraint =
      [self.stackView.heightAnchor constraintEqualToConstant:_btnHeight];

  // 7. Auto Layout Constraints
  [NSLayoutConstraint activateConstraints:@[

    // --- EffectView (Capsule) Constraints ---
    // Full width/height of the control with 4px padding
    [self.effectView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                  constant:4],
    [self.effectView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor
                                                   constant:-4],
    [self.effectView.topAnchor constraintEqualToAnchor:self.topAnchor
                                              constant:4],
    [self.effectView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor
                                                 constant:-4],

    // --- StackView (Content) Constraints ---
    // Center inside the EffectView
    [self.stackView.centerXAnchor
        constraintEqualToAnchor:self.effectView.centerXAnchor],
    [self.stackView.bottomAnchor
        constraintEqualToAnchor:self.effectView.bottomAnchor],

    // Allow stack to be as wide as needed (or constrained if we want scrolling
    // later)
    [self.stackView.leadingAnchor
        constraintGreaterThanOrEqualToAnchor:self.effectView.leadingAnchor
                                    constant:10],
    [self.stackView.trailingAnchor
        constraintLessThanOrEqualToAnchor:self.effectView.trailingAnchor
                                 constant:-10],

    // Height
    self.stackHeightConstraint,
  ]];
}

@end

//----------------------------------------------------------------------------//

HB_FUNC(VIEWSTACKBARCREATE) {
  NSRect frame = NSMakeRect(hb_parnl(2), hb_parnl(1), hb_parnl(3), hb_parnl(4));
  NSWindow *window = (NSWindow *)hb_parnll(5);

  ViewStackBar *bar = [[ViewStackBar alloc] initWithFrame:frame];

  // Autoresize: Width Sizable + Bottom Margin fixed (so it sticks to top) or
  // just Fixed Top/Left/Width Standard FiveMac usually handles resizing via
  // autoresizingMask passed from Prg defaults to:
  [bar setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];

  [GetView(window) addSubview:bar];

  hb_retnll((HB_LONGLONG)bar);
}

HB_FUNC(VIEWSTACKBARADDBUTTON) {
  ViewStackBar *bar = (ViewStackBar *)hb_parnll(1);
  NSString *title = hb_NSSTRING_par(2);
  NSString *imgName = hb_NSSTRING_par(3);

  NSButton *button = [[NSButton alloc] init];

  // Use a flexible style that supports custom height/layout
  [button setBezelStyle:NSBezelStyleRegularSquare];
  [button setButtonType:NSButtonTypeToggle];
  [button
      setBordered:NO]; // Textual/Icon only, or handle highlighting differently

  // If we want a background effect on hover/selection, we might need a custom
  // subclass or rely on standard behavior. RegularSquare with Bordered=NO is
  // plain. Let's add a visual cue? Or just trust the image/text. Actually,
  // standard Toolbar buttons are often Bordered=NO until hover.

  [button setTitle:title];

  if (imgName && [imgName length] > 0) {
    NSImage *img = nil;

    // Try SFSymbol first if available (macOS 11+)
    if (@available(macOS 11.0, *)) {
      img = [NSImage imageWithSystemSymbolName:imgName
                      accessibilityDescription:nil];
    }
    if (!img) {
      img = [NSImage imageNamed:imgName];
    }
    if (!img) {
      img = [[NSImage alloc] initWithContentsOfFile:imgName];
    }

    if (img) {
      [button setImage:img];
      [button setImagePosition:NSImageAbove];
      [button setImageScaling:NSImageScaleProportionallyDown];
    }
  }

  [button setAction:@selector(BtnClick:)];

  // Constraints for Size (Dynamic)
  [button.widthAnchor constraintEqualToConstant:bar.btnWidth].active = YES;
  [button.heightAnchor constraintEqualToConstant:bar.btnHeight].active = YES;

  [bar.stackView addArrangedSubview:button];

  hb_retnll((HB_LONGLONG)button);
}

HB_FUNC(VIEWSTACKBARSETBUTTONSIZE) {
  ViewStackBar *bar = (ViewStackBar *)hb_parnll(1);
  CGFloat nWidth = hb_parnd(2);
  CGFloat nHeight = hb_parnd(3);

  if (bar) {
    bar.btnWidth = nWidth;
    bar.btnHeight = nHeight;

    // 1. Update Stack Container Height
    // This controls the "strip" height
    if (bar.stackHeightConstraint) {
      bar.stackHeightConstraint.constant = nHeight;
    }

    // 2. Update Existing Buttons
    for (NSView *subview in bar.stackView.arrangedSubviews) {
      // Find and update width/height constraints logic
      for (NSLayoutConstraint *constraint in subview.constraints) {
        if (constraint.firstItem == subview &&
            constraint.firstAttribute == NSLayoutAttributeWidth) {
          constraint.constant = nWidth;
        }
        if (constraint.firstItem == subview &&
            constraint.firstAttribute == NSLayoutAttributeHeight) {
          constraint.constant = nHeight;
        }
      }
    }
  }
}

HB_FUNC(VIEWSTACKBARSETCOLOR) {
  ViewStackBar *bar = (ViewStackBar *)hb_parnll(1);
  int r = hb_parni(2);
  int g = hb_parni(3);
  int b = hb_parni(4);
  int a = hb_parni(5); // Alpha 0-255

  if (bar && bar.effectView) {
    if (a == 0)
      a = 255;
    NSColor *color = [NSColor colorWithCalibratedRed:r / 255.0
                                               green:g / 255.0
                                                blue:b / 255.0
                                               alpha:a / 255.0];
    bar.effectView.layer.backgroundColor = color.CGColor;
  }
}
