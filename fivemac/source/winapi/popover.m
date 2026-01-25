#include <fivemac.h>

@interface NSString (Size)
- (NSSize)sizeWithWidth:(float)width andFont:(NSFont *)font;
@end

@implementation NSString (Size)
- (NSSize)sizeWithWidth:(float)width andFont:(NSFont *)font {
  NSSize size = NSMakeSize(width, FLT_MAX);
  NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self];
  NSTextContainer *textContainer =
      [[NSTextContainer alloc] initWithContainerSize:size];
  NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
  [layoutManager addTextContainer:textContainer];
  [textStorage addLayoutManager:layoutManager];
  [textStorage addAttribute:NSFontAttributeName
                      value:font
                      range:NSMakeRange(0, [textStorage length])];
  [textContainer setLineFragmentPadding:0.0];
  [layoutManager glyphRangeForTextContainer:textContainer];

  NSRect usedRect = [layoutManager usedRectForTextContainer:textContainer];
  size.height = usedRect.size.height;
  size.width = usedRect.size.width;

  if (size.width < width)
    size.width += 5; // Extra buffer

  return size;
}

@end

#if __MAC_OS_X_VERSION_MAX_ALLOWED < 1070
#define NSPopoverBehaviorTransient 1
@interface NSPopover : NSObject
#else
@interface NSPopover (Message)
#endif

- (void)showRelativeToRect:(NSRect)rect
                    ofView:(NSView *)view
             preferredEdge:(NSRectEdge)edge
                    string:(NSString *)string
                  maxWidth:(float)width;

- (void)showWinRelativeToRect:(NSRect)rect
                       ofView:(NSView *)view
                preferredEdge:(NSRectEdge)edge
                       window:(NSWindow *)window
                     maxWidth:(float)width;

#if __MAC_OS_X_VERSION_MAX_ALLOWED < 1070

- (void)setContentSize:(NSSize)size;

- (void)setContentViewController:(NSViewController *)controller;

- (void)setAnimates:(BOOL)bYesNo;

- (void)setBehavior:(int)iBehavior;

#endif

@end

//----------------------------------------------------------//

#if __MAC_OS_X_VERSION_MAX_ALLOWED < 1070
@implementation NSPopover
#else
@implementation NSPopover (Message)
#endif

- (void)showRelativeToRect:(NSRect)rect
                    ofView:(NSView *)view
             preferredEdge:(NSRectEdge)edge
                    string:(NSString *)string
                  maxWidth:(float)width {
  float padding = 5;

  NSSize size = [string
      sizeWithWidth:250.0
            andFont:[NSFont
                        systemFontOfSize:[NSFont systemFontSizeForControlSize:
                                                     NSControlSizeRegular]]];

  // Sanity check
  if (size.width < 20)
    size.width = 20;
  if (size.height < 10)
    size.height = 10;

  NSSize popoverSize =
      NSMakeSize(size.width + (padding * 2), size.height + (padding * 2));
  NSRect popoverRect = NSMakeRect(0, 0, popoverSize.width, popoverSize.height);

  NSTextField *label = [[NSTextField alloc]
      initWithFrame:NSMakeRect(padding, padding, size.width, size.height)];

  [label setBezeled:NO];
  [label setDrawsBackground:NO];
  [label setEditable:NO];
  [label setSelectable:NO];
  [label setStringValue:string];
  [[label cell] setLineBreakMode:NSLineBreakByWordWrapping];

  NSView *container = [[NSView alloc] initWithFrame:popoverRect];
  [container addSubview:label];
  // Ensure explicit frame
  [label setFrame:NSMakeRect(padding, padding, size.width, size.height)];

  NSViewController *controller = [[NSViewController alloc] init];
  [controller setView:container];

  [self setContentSize:popoverSize];
  [self setContentViewController:controller];
  [self setAnimates:YES];
  [self setBehavior:NSPopoverBehaviorTransient]; // Auto-close

  // Convert coordinates to Window Content View (Robust Anchor)
  NSWindow *win = [view window];
  if (win) {
    NSView *contentView = [win contentView];
    // 1. Convert view bounds to Window Coordinate Space
    NSRect rectInWin = [view convertRect:rect toView:nil];
    // 2. Convert Window Coords to Content View Coordinate Space
    NSRect rectInContent = [contentView convertRect:rectInWin fromView:nil];

    [self showRelativeToRect:rectInContent
                      ofView:contentView
               preferredEdge:edge];
  } else {
    [self showRelativeToRect:rect ofView:view preferredEdge:edge];
  }
}

- (void)showWinRelativeToRect:(NSRect)rect
                       ofView:(NSView *)view
                preferredEdge:(NSRectEdge)edge
                       window:(NSWindow *)window
                     maxWidth:(float)width {
  float padding = 5;

  NSRect frame = [window frame];

  NSSize popoverSize = NSMakeSize(frame.size.width + (padding * 2),
                                  frame.size.height + (padding * 2));
  NSRect popoverRect = NSMakeRect(0, 0, popoverSize.width, popoverSize.height);

  NSView *container = [[NSView alloc] initWithFrame:popoverRect];
  NSView *winView = GetView(window);

  [container addSubview:winView];
  [winView setFrame:NSMakeRect(padding, padding, frame.size.width,
                               frame.size.height)];

  if ([winView respondsToSelector:@selector(setOriginalWindow:)]) {
    [winView performSelector:@selector(setOriginalWindow:) withObject:window];
  }

  NSViewController *controller = [[NSViewController alloc] init];
  [controller setView:container];

  [self setContentSize:popoverSize];
  [self setContentViewController:controller];
  [self setAnimates:YES];
  [self setBehavior:NSPopoverBehaviorTransient];

  [self showRelativeToRect:rect ofView:view preferredEdge:edge];
}

@end

//----------------------------------------------------------//

HB_FUNC(SHOWPOPOVER) {
  NSControl *theInput = (NSControl *)hb_parnll(1);
  NSString *mystring = hb_NSSTRING_par(2);
  NSPopover *popover = [[NSPopover alloc] init];

  // Try to retain to prevent release (MRC style)
  [popover retain];

  // We use [theInput bounds] as base rect, and theInput as view.
  // The method within NSPopover will handle coordinate conversion.
  [popover showRelativeToRect:[theInput bounds]
                       ofView:theInput
                preferredEdge:NSMaxYEdge // Show the popover BELOW the button
                       string:mystring
                     maxWidth:250.0];

  hb_retnll((HB_LONGLONG)popover);
}

HB_FUNC(SHOWWINPOPOVER) {
  NSControl *theInput = (NSControl *)hb_parnll(1);
  NSWindow *window = (NSWindow *)hb_parnll(2);
  NSPopover *popover = [[NSPopover alloc] init];

  [popover
      showWinRelativeToRect:[theInput frame]
                     ofView:[theInput superview]
              preferredEdge:NSMaxXEdge // Show the popover on the right edge
                     window:window
                   maxWidth:250.0];

  hb_retnll((HB_LONGLONG)popover);
}

HB_FUNC(CLOSEPOPOVER) {
  NSPopover *popover = (NSPopover *)hb_parnll(1);

  [popover close];
}

HB_FUNC(SETPOPOVERAPPERANCE) {
  NSPopover *popover = (NSPopover *)hb_parnll(1);
  int nAparence = hb_parni(2);

  switch (nAparence) {
  case 0:
    popover.appearance =
        [[NSAppearance init] appearanceNamed:NSAppearanceNameAqua];
    break;

  case 1:
    popover.appearance =
        [[NSAppearance init] appearanceNamed:NSAppearanceNameVibrantDark];
    break;
  case 2:
    popover.appearance =
        [[NSAppearance init] appearanceNamed:NSAppearanceNameVibrantLight];
    break;
  }
}
