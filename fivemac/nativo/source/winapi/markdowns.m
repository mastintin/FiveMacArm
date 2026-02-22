#import <Cocoa/Cocoa.h>
#include <fivemac.h>

NSView *GetView(NSWindow *window);

@interface MarkdownView : NSTextView
@end

@implementation MarkdownView
@end

HB_FUNC(MARKDOWNCREATE) {
  NSScrollView *sv =
      [[NSScrollView alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                     hb_parnl(3), hb_parnl(4))];
  MarkdownView *view = [[MarkdownView alloc] initWithFrame:[sv bounds]];
  NSWindow *window = (NSWindow *)hb_parnll(5);

  [sv setHasVerticalScroller:YES];
  [sv setHasHorizontalScroller:NO];
  [sv setAutoresizesSubviews:YES];

  [view setEditable:NO];
  [view setSelectable:YES];
  [view setVerticallyResizable:YES];
  [view setHorizontallyResizable:NO];
  [view setAutoresizingMask:NSViewWidthSizable];

  [sv setDocumentView:view];
  [GetView(window) addSubview:sv];

  hb_retnll((HB_LONGLONG)sv);
}

HB_FUNC(MARKDOWNSETTEXT) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  MarkdownView *view = (MarkdownView *)[sv documentView];
  NSString *cMarkdown = hb_NSSTRING_par(2);

  if (cMarkdown) {
    NSError *error = nil;
    // Available since macOS 12.0
    if (@available(macOS 12.0, *)) {
      NSAttributedString *as =
          [[NSAttributedString alloc] initWithMarkdownString:cMarkdown
                                                     options:nil
                                                     baseURL:nil
                                                       error:&error];
      if (as) {
        [[view textStorage] setAttributedString:as];
      } else if (error) {
        NSLog(@"Markdown error: %@", [error localizedDescription]);
        [view setString:cMarkdown];
      }
    } else {
      // Fallback for older systems
      [view setString:cMarkdown];
    }
  }
}
