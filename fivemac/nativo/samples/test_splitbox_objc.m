#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property(strong) NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  NSLog(@"Application finished launching");
  NSRect frame = NSMakeRect(100, 100, 600, 400);
  self.window = [[NSWindow alloc]
      initWithContentRect:frame
                styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                           NSWindowStyleMaskResizable)
                  backing:NSBackingStoreBuffered
                    defer:NO];
  [self.window setTitle:@"SplitBox ObjC Test"];
  [self.window setBackgroundColor:[NSColor whiteColor]];

  // Create NSSplitView
  NSSplitView *splitView =
      [[NSSplitView alloc] initWithFrame:[[self.window contentView] bounds]];
  [splitView setVertical:YES];
  [splitView setDividerStyle:NSSplitViewDividerStyleThin];
  [splitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

  // Create Subview 1
  NSView *view1 = [[NSView alloc] init];
  [view1 setWantsLayer:YES];
  view1.layer.backgroundColor = [[NSColor redColor] CGColor];
  [splitView addSubview:view1];

  // Create Subview 2
  NSView *view2 = [[NSView alloc] init];
  [view2 setWantsLayer:YES];
  view2.layer.backgroundColor = [[NSColor blueColor] CGColor];
  [splitView addSubview:view2];

  [[self.window contentView] addSubview:splitView];
  [splitView adjustSubviews];

  [self.window makeKeyAndOrderFront:nil];
  [self.window setIsVisible:YES];
  NSLog(@"Window should be visible now");
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:
    (NSApplication *)theApplication {
  return YES;
}

@end

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSApplication *app = [NSApplication sharedApplication];
    [app setActivationPolicy:NSApplicationActivationPolicyRegular];
    AppDelegate *delegate = [[AppDelegate alloc] init];
    [app setDelegate:delegate];
    [app activateIgnoringOtherApps:YES];
    [app run];
  }
  return 0;
}
