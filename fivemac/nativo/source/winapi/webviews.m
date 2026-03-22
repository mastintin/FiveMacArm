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

//-------------------------------------------------------------------------------//

HB_FUNC(WEBVIEWCREATE) {
  // 1. ScrollView (lo devolvemos a Harbour, así que NO lo liberamos aquí)
  NSScrollView *sv =
      [[NSScrollView alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                     hb_parnl(3), hb_parnl(4))];

  // 2. Configuración y Controller
  WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
  WKUserContentController *userContentController =
      [[WKUserContentController alloc] init];

  // 3. Script Handler y Harbour Item
  PHB_ITEM pSelf = hb_itemNew(hb_param(5, HB_IT_OBJECT));
  FMVScriptHandler *scriptHandler = [[FMVScriptHandler alloc] init];
  scriptHandler.phbWebview = pSelf;

  [userContentController addScriptMessageHandler:scriptHandler name:@"fivemac"];
  config.userContentController = userContentController;

  // 4. WebView
  NSWindow *window = (NSWindow *)hb_parnll(6);
  [sv setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [sv setHasVerticalScroller:YES];
  [sv setHasHorizontalScroller:YES];
  [sv setBorderType:NSBezelBorder];

  WKWebView *Wview = [[WKWebView alloc] initWithFrame:[[sv contentView] frame]
                                        configuration:config];
  [Wview setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

  // 5. Navigation Delegate
  FMVNavigationHandler *navHandler = [[FMVNavigationHandler alloc] init];
  [Wview setNavigationDelegate:navHandler];
  objc_setAssociatedObject(Wview, "navHandler", navHandler,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  // --- LIBERACIONES NECESARIAS (Memory Management) ---
  [navHandler release];            // El AssociatedObject ya hizo retain
  [scriptHandler release];         // El userContentController ya hizo retain
  [userContentController release]; // El config ya hizo retain
  [config release];                // El Wview ya hizo retain
  [Wview release]; // El ScrollView (documentView) ya hizo retain

  [sv setDocumentView:Wview];
  [[window contentView] addSubview:sv];

  hb_retnll((HB_LONGLONG)sv);
}

//-------------------------------------------------------------------------------//

HB_FUNC(WEBVIEWLOADREQUEST) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);

  if (sv) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    WKWebView *Wview = (WKWebView *)[sv documentView];
    NSString *string = hb_NSSTRING_par(2);

    if (string && [Wview isKindOfClass:[WKWebView class]]) {
      NSURL *url = [NSURL URLWithString:string];
      if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [Wview loadRequest:request];
      }
    }

    [pool drain]; // Libera el string, la url y la request de inmediato
  }
}

//-------------------------------------------------------------------------------//

HB_FUNC(WEBVIEWLOADHTML) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);

  if (sv) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    WKWebView *Wview = (WKWebView *)[sv documentView];
    NSString *string = hb_NSSTRING_par(2); // El HTML puede ser pesado
    NSString *base = hb_NSSTRING_par(3);
    NSURL *baseUrl = nil;

    if (base && [base length] > 0) {
      if ([base hasPrefix:@"http"] || [base hasPrefix:@"file://"]) {
        baseUrl = [NSURL URLWithString:base];
      } else {
        baseUrl = [NSURL fileURLWithPath:base];
      }
    }

    if (Wview && string) {
      [Wview loadHTMLString:string baseURL:baseUrl];
    }

    [pool drain]; // Libera el string HTML y la URL base de inmediato
  }
}

HB_FUNC(WEBVIEWGOBACK) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);

  if (sv) {
    // Obtenemos el documentView
    id view = [sv documentView];

    // Verificamos que realmente sea un WKWebView antes de llamar a goBack
    if ([view isKindOfClass:[WKWebView class]]) {
      WKWebView *Wview = (WKWebView *)view;
      if ([Wview canGoBack]) { // Opcional: solo si quieres evitar llamadas
                               // innecesarias
        [Wview goBack];
      }
    }
  }
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

//-------------------------------------------------------------------------------//

HB_FUNC(WEBSCRIPCALLMETHOD) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);

  if (sv) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    id view = [sv documentView];
    NSString *script = hb_NSSTRING_par(2);

    if ([view isKindOfClass:[WKWebView class]] && script) {
      // evaluateJavaScript es asíncrono, pero el string se puede liberar
      // después de llamar al método porque el WebView hace su propia copia
      // interna.
      [(WKWebView *)view evaluateJavaScript:script completionHandler:nil];
    }

    [pool drain];
  }
}

//-------------------------------------------------------------------------------//

HB_FUNC(WEBSCRIPCALLMETHODARG) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);

  if (sv) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    id view = [sv documentView];
    NSString *func = hb_NSSTRING_par(2);
    NSString *arg = hb_NSSTRING_par(3);

    if ([view isKindOfClass:[WKWebView class]] && func && arg) {
      // Escapamos comillas simples en el argumento para evitar que el JS rompa
      NSString *safeArg = [arg stringByReplacingOccurrencesOfString:@"'"
                                                         withString:@"\\'"];

      // Creamos el comando JS (esto genera un nuevo objeto autoreleased)
      NSString *js = [NSString stringWithFormat:@"%@('%@')", func, safeArg];

      [(WKWebView *)view evaluateJavaScript:js completionHandler:nil];
    }

    [pool drain]; // Limpia func, arg, safeArg y js de un plumazo
  }
}

//-------------------------------------------------------------------------------//

HB_FUNC(WEBVIEWSTARTSPEAKING) {
  // Not supported directly in WKWebView
}

//-------------------------------------------------------------------------------//

HB_FUNC(WEBVIEWSAVETOPDF) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];
  NSString *path = hb_NSSTRING_par(2);

  if (Wview && path) {
    // Usamos un pool local para los objetos temporales (URL, diccionarios,
    // etc.)
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // sharedPrintInfo devuelve un objeto que no debemos liberar,
    // pero vamos a crear una copia para no alterar la configuración global de
    // impresión
    NSPrintInfo *printInfo = [[[NSPrintInfo sharedPrintInfo] copy] autorelease];

    [printInfo setJobDisposition:NSPrintSaveJob];

    // Creamos la URL del archivo
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    [printInfo.dictionary setObject:fileURL forKey:NSPrintJobSavingURL];

    [printInfo setPaperSize:NSMakeSize(595, 842)];
    [printInfo setTopMargin:0.0];
    [printInfo setBottomMargin:0.0];
    [printInfo setLeftMargin:0.0];
    [printInfo setRightMargin:0.0];
    [printInfo setHorizontallyCentered:NO];
    [printInfo setVerticallyCentered:NO];
    [printInfo setScalingFactor:1.0];

    // WKWebView genera la operación de impresión (objeto autoreleased)
    NSPrintOperation *printOp = [Wview printOperationWithPrintInfo:printInfo];

    [printOp setShowsPrintPanel:NO];
    [printOp setShowsProgressPanel:NO];

    NSWindow *win = [Wview window];
    if (win) {
      [printOp runOperationModalForWindow:win
                                 delegate:nil
                           didRunSelector:nil
                              contextInfo:nil];
    } else {
      [printOp runOperation];
    }

    [pool drain]; // Liberamos la copia de printInfo y la fileURL
  }
}

HB_FUNC(WEBVIEWSTOPSPEAKING) {
  // Not supported directly in WKWebView
}

//-------------------------------------------------------------------------------//

HB_FUNC(WEBVIEWLOADFILE) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  NSString *cPath = hb_NSSTRING_par(2);

  if (sv && cPath && [cPath length] > 0) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    WKWebView *Wview = (WKWebView *)[sv documentView];

    if ([Wview isKindOfClass:[WKWebView class]]) {
      NSURL *fileURL = [NSURL fileURLWithPath:cPath];
      // Permitimos acceso a toda la carpeta que contiene el archivo
      NSURL *folderURL = [fileURL URLByDeletingLastPathComponent];

      [Wview loadFileURL:fileURL allowingReadAccessToURL:folderURL];
    } else {
      NSLog(@"WebView LoadFile Error: DocumentView is %@", [Wview class]);
    }

    [pool drain]; // Libera fileURL y folderURL de inmediato
  }
}

//-------------------------------------------------------------------------------//

HB_FUNC(WEBVIEWSETZOOM) {
  NSScrollView *sv = (NSScrollView *)hb_parnll(1);
  WKWebView *Wview = (WKWebView *)[sv documentView];
  CGFloat nMagnification = (CGFloat)hb_parnd(2);

  if ([Wview isKindOfClass:[WKWebView class]]) {
    [Wview setMagnification:nMagnification
            centeredAtPoint:NSMakePoint(Wview.frame.size.width / 2,
                                        Wview.frame.size.height / 2)];
  }
}
