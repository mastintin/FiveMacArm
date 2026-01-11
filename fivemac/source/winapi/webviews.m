#import <WebKit/WebKit.h>
#include <fivemac.h>

HB_FUNC(WEBVIEWCREATE) {
  NSScrollView *sv =
      [[NSScrollView alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                     hb_parnl(3), hb_parnl(4))];

  WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];

  WKWebView *Wview;
  NSWindow *window = (NSWindow *)hb_parnll(5);

  [sv setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [sv setHasVerticalScroller:YES];
  [sv setHasHorizontalScroller:YES];
  [sv setBorderType:NSBezelBorder];

  Wview = [[WKWebView alloc] initWithFrame:[[sv contentView] frame]
                             configuration:config];
  [Wview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

  [sv setDocumentView:Wview];
  [GetView(window) addSubview:sv];

  hb_retnll((HB_LONGLONG)sv);
}

HB_FUNC(WEBVIEWLOADREQUEST) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];

  NSString *string = hb_NSSTRING_par(2);
  NSURL *url = [NSURL URLWithString:string];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  [Wview loadRequest:request];
}

HB_FUNC(WEBVIEWGOBACK) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];

  [Wview goBack];
}

HB_FUNC(WEBVIEWGOFORWARD) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];

  if ([Wview canGoForward])
    [Wview goForward];
}

HB_FUNC(WEBVIEWRELOAD) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];
  [Wview reload];
}

HB_FUNC(WEBVIEWISLOADING) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];
  hb_retl([Wview isLoading]);
}

HB_FUNC(WEBVIEWPROGRESS) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];
  hb_retnl((HB_LONG)([Wview estimatedProgress] * 100));
}

HB_FUNC(WEBVIEWSTOPLOADING) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];
  [Wview stopLoading];
}

HB_FUNC(WEBVIEWSETTEXTSIZEMULTIPLIER) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];

  double multiplier = hb_parnl(2) / 100.0;
  NSString *js =
      [NSString stringWithFormat:@"document.getElementsByTagName('body')[0]."
                                 @"style.webkitTextSizeAdjust= '%d%%'",
                                 (int)(multiplier * 100)];
  [Wview evaluateJavaScript:js completionHandler:nil];
}

HB_FUNC(JUMPTOANCHOR) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];

  NSString *anchor = hb_NSSTRING_par(2);
  NSString *js = [NSString
      stringWithFormat:@"var anchor = document.anchors[\"%@\"]; if(anchor) "
                       @"window.scrollTo(anchor.offsetLeft, anchor.offsetTop);",
                       anchor];
  [Wview evaluateJavaScript:js completionHandler:nil];
}

HB_FUNC(WEBSCRIPCALLMETHOD) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];

  NSString *string = hb_NSSTRING_par(2);
  [Wview evaluateJavaScript:string completionHandler:nil];
}

HB_FUNC(WEBSCRIPCALLMETHODARG) {
  // Simpler version: assumes string is a function name and arg is a string
  // argument
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];

  NSString *func = hb_NSSTRING_par(2);
  NSString *arg = hb_NSSTRING_par(3);
  // Basic escaping (imperfect but functional for simple cases)
  NSString *js = [NSString stringWithFormat:@"%@('%@')", func, arg];
  [Wview evaluateJavaScript:js completionHandler:nil];
}

// startSpeaking/stopSpeaking are not direct methods of WKWebView.
// They were likely part of legacy WebHelpers or NSSpeechSynthesizer bound to
// selection. Removing or leaving empty for now to avoid crashes.
HB_FUNC(WEBVIEWSTARTSPEAKING) {
  // Not supported directly in WKWebView
}

HB_FUNC(WEBVIEWSTOPSPEAKING) {
  // Not supported directly in WKWebView
}