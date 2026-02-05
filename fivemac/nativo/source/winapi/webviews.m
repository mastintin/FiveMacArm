#import <WebKit/WebKit.h>
#include <fivemac.h>
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbvm.h>
#import <objc/runtime.h>

@interface FMVScriptHandler : NSObject <WKScriptMessageHandler>
@property(nonatomic, assign) PHB_ITEM phbWebview;
@end

@interface FMVNavigationHandler : NSObject <WKNavigationDelegate>
@end

extern PHB_ITEM hb_itemNew(PHB_ITEM pNull);

@implementation FMVNavigationHandler
- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:
                        (void (^)(WKNavigationActionPolicy))decisionHandler {
  decisionHandler(WKNavigationActionPolicyAllow);
}
@end

@implementation FMVScriptHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {

  static PHB_SYMB pSym = NULL;

  NSLog(@"Bridge: Message Received: %@", message.name);

  if (self.phbWebview) {

    if (!pSym) {
      NSLog(@"Bridge: looking up symbol...");
      pSym = hb_dynsymSymbol(hb_dynsymFindName("WEBVIEWONMESSAGE"));
    }

    if (!pSym) {
      NSLog(@"Bridge Error: WEBVIEWONMESSAGE symbol not found!");
      return;
    }

    hb_vmPushSymbol(pSym);
    hb_vmPushNil();

    hb_vmPush(self.phbWebview);

    NSString *sBody = [NSString stringWithFormat:@"%@", message.body];
    const char *cBody = [sBody UTF8String];
    if (!cBody)
      cBody = "";
    unsigned long nLenBody = (unsigned long)strlen(cBody);
    hb_vmPushString(cBody, nLenBody);

    const char *cName = [message.name UTF8String];
    if (!cName)
      cName = "";
    unsigned long nLenName = (unsigned long)strlen(cName);
    hb_vmPushString(cName, nLenName);

    hb_vmDo(3);
  } else {
    NSLog(@"Bridge Error: self.phbWebview is NULL");
  }
}
@end

HB_FUNC(WEBVIEWCREATE) {
  NSScrollView *sv =
      [[NSScrollView alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                     hb_parnl(3), hb_parnl(4))];

  WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
  WKUserContentController *userContentController =
      [[WKUserContentController alloc] init];

  // Store Harbour Object (Self)
  PHB_ITEM pSelf = hb_itemNew(hb_param(5, HB_IT_OBJECT));

  FMVScriptHandler *scriptHandler = [[FMVScriptHandler alloc] init];
  scriptHandler.phbWebview = pSelf;

  [userContentController addScriptMessageHandler:scriptHandler name:@"fivemac"];
  config.userContentController = userContentController;

  WKWebView *Wview;
  NSWindow *window = (NSWindow *)hb_parnll(6); // Now param 6 is Window

  [sv setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [sv setHasVerticalScroller:YES];
  [sv setHasHorizontalScroller:YES];
  [sv setBorderType:NSBezelBorder];

  Wview = [[WKWebView alloc] initWithFrame:[[sv contentView] frame]
                             configuration:config];
  [Wview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

  // Create and set Navigation Delegate to allow all requests
  FMVNavigationHandler *navHandler = [[FMVNavigationHandler alloc] init];
  [Wview setNavigationDelegate:navHandler];
  objc_setAssociatedObject(Wview, "navHandler", navHandler,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [sv setDocumentView:Wview];
  [[window contentView] addSubview:sv]; // Keep fix

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

HB_FUNC(WEBVIEWLOADHTML) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];

  NSString *string = hb_NSSTRING_par(2);
  NSString *base = hb_NSSTRING_par(3);
  NSURL *baseUrl = nil;

  if (base) {
    if ([base hasPrefix:@"http"] || [base hasPrefix:@"file://"]) {
      baseUrl = [NSURL URLWithString:base];
    } else {
      baseUrl = [NSURL fileURLWithPath:base];
    }
  }

  [Wview loadHTMLString:string baseURL:baseUrl];
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

HB_FUNC(WEBVIEWSTARTSPEAKING) {
  // Not supported directly in WKWebView
}

HB_FUNC(WEBVIEWSAVETOPDF) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];
  NSString *path = hb_NSSTRING_par(2);

  if (@available(macOS 11.0, *)) {
    // Use NSPrintOperation to respect CSS Pagination
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];

    // Configure for PDF Output
    [printInfo setJobDisposition:NSPrintSaveJob];
    [printInfo.dictionary setObject:[NSURL fileURLWithPath:path]
                             forKey:NSPrintJobSavingURL];

    // Explicitly set A4 Paper (595x842 pts) and Zero Margins
    [printInfo setPaperSize:NSMakeSize(595, 842)];
    [printInfo setTopMargin:0.0];
    [printInfo setBottomMargin:0.0];
    [printInfo setLeftMargin:0.0];
    [printInfo setRightMargin:0.0];
    [printInfo setHorizontallyCentered:NO];
    [printInfo setVerticallyCentered:NO];
    [printInfo setScalingFactor:1.0];

    // Retrieve Print Operation from WKWebView
    NSPrintOperation *printOp = [Wview printOperationWithPrintInfo:printInfo];

    [printOp setShowsPrintPanel:NO];
    [printOp setShowsProgressPanel:NO];

    // Run Modally for Window (Async/Sheet) to avoid blocking main thread
    // completely We use the window of the webview
    NSWindow *win = [Wview window];
    if (win) {
      [printOp runOperationModalForWindow:win
                                 delegate:nil
                           didRunSelector:nil
                              contextInfo:nil];
      NSLog(@"WebView PDF: Print Operation started (Sheet)");
    } else {
      // Fallback if no window (headless logic might fail here if not attached?)
      if ([printOp runOperation]) {
        NSLog(@"WebView PDF: Saved (Blocking) to: %@", path);
      }
    }

  } else {
    // Fallback? Or just log.
    NSLog(@"WebView PDF requires macOS 11.0+");
  }
}

HB_FUNC(WEBVIEWSTOPSPEAKING) {
  // Not supported directly in WKWebView
}