#include <fivemac.h>

HB_FUNC(BTNCREATE) {
  NSButton *button =
      [[NSButton alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                 hb_parnl(3), hb_parnl(4))];
  NSString *string = hb_NSSTRING_par(5);
  NSWindow *window = (NSWindow *)hb_parnll(6);

  [button setBezelStyle:NSBezelStylePush];
  [button setTitle:string];

  [GetView(window) addSubview:button];

  [button setAction:@selector(BtnClick:)];

  hb_retnll((HB_LONGLONG)button);
}

HB_FUNC(RADCREATE) {
  NSButton *radio =
      [[NSButton alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                 hb_parnl(3), hb_parnl(4))];
  NSString *string = hb_NSSTRING_par(5);
  NSWindow *window = (NSWindow *)hb_parnll(6);

  [radio setButtonType:NSButtonTypeRadio];
  [radio setTitle:string];
  [GetView(window) addSubview:radio];
  [radio setAction:@selector(BtnClick:)];

  hb_retnll((HB_LONGLONG)radio);
}

HB_FUNC(BTNSETENABLED) {
  NSButton *button = (NSButton *)hb_parnll(1);

  [button setEnabled:hb_parl(2)];
}

HB_FUNC(BTNSETBORDERED) {
  NSButton *button = (NSButton *)hb_parnll(1);
  button.bordered = hb_parl(2);
}

HB_FUNC(BTNSETTRANSPARENT) {
  NSButton *button = (NSButton *)hb_parnll(1);
  button.transparent = hb_parl(2);
}

HB_FUNC(BTNSETHIGHLIGHT) {
  NSButton *button = (NSButton *)hb_parnll(1);
  [button highlight:hb_parl(2)];
}

HB_FUNC(BTNSETFOCUS) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSButton *button = (NSButton *)hb_parnll(2);
  [window makeFirstResponder:button];
}

HB_FUNC(BTNSETDEFAULT) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSButton *button = (NSButton *)hb_parnll(2);
  [window setDefaultButtonCell:[button cell]];
}

HB_FUNC(BTNRESCREATE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSButton *button = (NSButton *)[GetView(window) viewWithTag:hb_parnl(2)];

  [GetView(window) addSubview:button];
  [button setAction:@selector(BtnClick:)];

  hb_retnll((HB_LONGLONG)button);
}

HB_FUNC(BTNBMPCREATE) {
  NSButton *button =
      [[NSButton alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                 hb_parnl(3), hb_parnl(4))];
  NSWindow *window = (NSWindow *)hb_parnll(5);

  [button setBezelStyle:NSBezelStyleFlexiblePush];
  [button setTitle:@""];

  [GetView(window) addSubview:button];
  [button setAction:@selector(BtnClick:)];

  hb_retnll((HB_LONGLONG)button);
}

HB_FUNC(BTNSETTEXT) {
  NSButton *button = (NSButton *)hb_parnll(1);

  [button setTitle:hb_NSSTRING_par(2)];
}

HB_FUNC(BTNGETTEXT) // hButton --> cText
{
  NSButton *button = (NSButton *)hb_parnll(1);
  NSString *string = [button title];

  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(BTNBMPFILE) {
  NSButton *button = (NSButton *)hb_parnll(1);

  if (HB_ISNUM(2)) {
    [button setImage:(NSImage *)hb_parnll(2)];
  } else {
    NSString *string = hb_NSSTRING_par(2);
    NSFileManager *filemgr = [NSFileManager defaultManager];

    if ([filemgr fileExistsAtPath:string])
      [button setImage:[[[NSImage alloc] initWithContentsOfFile:string]
                           autorelease]];
    else
      [button setImage:ImgTemplate(string)];
  }
}

HB_FUNC(BTNSETIMAGE) {
  NSButton *button = (NSButton *)hb_parnll(1);
  NSImage *image = (NSImage *)hb_parnll(2);

  [button setImage:image];
}

HB_FUNC(BTNSETIMAGENPOSITION) {
  NSButton *button = (NSButton *)hb_parnll(1);
  button.imagePosition = hb_parnl(2);
}

HB_FUNC(BTNSETBEZEL) {
  NSButton *button = (NSButton *)hb_parnll(1);

  [button setBezelStyle:hb_parnl(2)];
}

HB_FUNC(BTNSETSOUND) {
  NSButton *button = (NSButton *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);
  NSSound *sound = [[[NSSound alloc] initWithContentsOfFile:string
                                                byReference:NO] autorelease];

  [button setSound:sound];
}

HB_FUNC(BTNSETTYPE) {
  NSButton *button = (NSButton *)hb_parnll(1);

  [button setButtonType:hb_parnl(2)];
}

HB_FUNC(BTNGETSTATE) {
  NSButton *button = (NSButton *)hb_parnll(1);

  hb_retnl([button state]);
}

HB_FUNC(BTNSETSTATE) {
  NSButton *button = (NSButton *)hb_parnll(1);

  [button setState:hb_parnl(2)];
}

HB_FUNC(BTNALIGNTEXT) {
  NSButton *button = (NSButton *)hb_parnll(1);

  [button setAlignment:hb_parnl(2)];
}

HB_FUNC(BTNAUTOAJUST) {
  NSButton *button = (NSButton *)hb_parnll(1);

  [button setAutoresizingMask:hb_parnl(2)];
}

HB_FUNC(BTNSETTOOLTIP) {
  NSButton *button = (NSButton *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);

  [button setToolTip:string];
}

HB_FUNC(BTNSETGLASS) {
  NSButton *button = (NSButton *)hb_parnll(1);
  if (button) {

    button.bezelStyle = NSBezelStyleGlass;
    button.bezelColor = [NSColor systemBlueColor];

    [button setBordered:NO];

    NSVisualEffectView *vView =
        [[NSVisualEffectView alloc] initWithFrame:[button bounds]];

    [vView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [vView setBlendingMode:NSVisualEffectBlendingModeWithinWindow];

    if (@available(macOS 10.14, *)) {
      [vView setMaterial:NSVisualEffectMaterialHUDWindow];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
      [vView setMaterial:NSVisualEffectMaterialLight];
#pragma clang diagnostic pop
    }

    [vView setState:NSVisualEffectStateActive];
    [vView setBlendingMode:NSVisualEffectBlendingModeWithinWindow];

    [vView setWantsLayer:YES];
    vView.layer.cornerRadius = 5.0; // Standard rounded corner
    vView.layer.masksToBounds = YES;

    // Border for Glass
    vView.layer.borderColor =
        [[NSColor whiteColor] colorWithAlphaComponent:0.6].CGColor;
    vView.layer.borderWidth = 1.0;

    [button addSubview:vView positioned:NSWindowBelow relativeTo:nil];
  }
}

HB_FUNC(BTNSETBEZELCOLOR) {
  NSButton *button = (NSButton *)hb_parnll(1);
  if (button) {
    if (@available(macOS 10.12.2, *)) {
      NSColor *color = [NSColor colorWithCalibratedRed:hb_parnd(2) / 255.0
                                                 green:hb_parnd(3) / 255.0
                                                  blue:hb_parnd(4) / 255.0
                                                 alpha:hb_parnd(5)];
      [button setBezelColor:color];
    }
  }
}
HB_FUNC(BTNSETCAPSULE) {
  NSButton *button = (NSButton *)hb_parnll(1);
  long nColor = hb_parnl(2);

  if (button) {
    [button setWantsLayer:YES];
    [button setBordered:NO];
    button.layer.masksToBounds = NO;

    // Color (Tint)
    int r = nColor & 0xFF;
    int g = (nColor >> 8) & 0xFF;
    int b = (nColor >> 16) & 0xFF;
    float alpha = 1.0;

    NSColor *col = [NSColor colorWithCalibratedRed:r / 255.0
                                             green:g / 255.0
                                              blue:b / 255.0
                                             alpha:alpha];

    button.layer.backgroundColor = col.CGColor;
    button.layer.cornerRadius = button.frame.size.height / 2.0;

    // Border
    button.layer.borderColor =
        [[NSColor whiteColor] colorWithAlphaComponent:0.6].CGColor;
    button.layer.borderWidth = 1.5;

    // Shadow
    button.layer.shadowColor = [NSColor blackColor].CGColor;
    button.layer.shadowOpacity = 0.3;
    button.layer.shadowOffset = CGSizeMake(0, -2);
    button.layer.shadowRadius = 4;

    // Text Color White
    if ([button title]) {
      NSMutableAttributedString *attrTitle =
          [[NSMutableAttributedString alloc] initWithString:[button title]];
      [attrTitle addAttribute:NSForegroundColorAttributeName
                        value:[NSColor whiteColor]
                        range:NSMakeRange(0, [attrTitle length])];
      // Center alignment
      NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
      [style setAlignment:NSTextAlignmentCenter];
      [attrTitle addAttribute:NSParagraphStyleAttributeName
                        value:style
                        range:NSMakeRange(0, [attrTitle length])];

      [button setAttributedTitle:attrTitle];
      [attrTitle release];
      [style release];
    }
  }
}
