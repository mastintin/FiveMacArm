#import <WebKit/WebKit.h>
#include <hbapi.h>

// --- Interfaz de la Ventana de Chat ---
@interface AIChatWindow : NSWindow <WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *apiUrl;
@end

@implementation AIChatWindow

- (instancetype)initWithContentRect:(NSRect)contentRect 
                        styleMask:(NSWindowStyleMask)style 
                          backing:(NSBackingStoreType)bufferingType 
                            defer:(BOOL)flag {
    
    self = [super initWithContentRect:contentRect styleMask:style backing:bufferingType defer:flag];
    if (self) {
        [self setTitle:@"FiveMac Universal AI"];
        [self setBackgroundColor:[NSColor windowBackgroundColor]];
        
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        [userContentController addScriptMessageHandler:self name:@"fivemac"];
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = userContentController;
        
        self.webView = [[WKWebView alloc] initWithFrame:self.contentView.bounds configuration:configuration];
        self.webView.navigationDelegate = self;
        self.webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [self.webView setValue:@YES forKey:@"drawsBackground"];
        
        [self.contentView addSubview:self.webView];
        [self loadChatInterface];
    }
    return self;
}

- (void)loadChatInterface {
    NSString *html = @""
    "<!DOCTYPE html>"
    "<html>"
    "<head>"
    "    <meta charset='UTF-8'>"
    "    <style>"
    "        :root { --bg-color: #1a1a1a; --chat-bg: #242424; --text-color: #e0e0e0; --accent-color: #007aff; --user-bubble: #2b3a4a; --ai-bubble: #333333; }"
    "        body { background-color: var(--bg-color); color: var(--text-color); font-family: -apple-system; margin: 0; display: flex; flex-direction: column; height: 100vh; overflow: hidden; }"
    "        #chat-container { flex: 1; overflow-y: auto; padding: 20px; display: flex; flex-direction: column; gap: 15px; }"
    "        .bubble { max-width: 85%; padding: 12px 16px; border-radius: 18px; font-size: 14px; line-height: 1.5; animation: fadeIn 0.3s ease; }"
    "        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }"
    "        .user { align-self: flex-end; background-color: var(--user-bubble); color: white; border-bottom-right-radius: 4px; }"
    "        .ai { align-self: flex-start; background-color: var(--ai-bubble); border-bottom-left-radius: 4px; border: 1px solid #444; }"
    "        #input-area { background-color: var(--chat-bg); padding: 15px; display: flex; gap: 10px; border-top: 1px solid #333; }"
    "        input { flex: 1; background: #111; border: 1px solid #444; color: white; padding: 10px 15px; border-radius: 20px; outline: none; }"
    "        button { background: var(--accent-color); color: white; border: none; padding: 8px 15px; border-radius: 15px; cursor: pointer; font-weight: bold; }"
    "    </style>"
    "</head>"
    "<body>"
    "    <div id='chat-container'><div class='bubble ai'>Conexión establecida. ¿Qué quieres consultar hoy?</div></div>"
    "    <div id='input-area'>"
    "        <input type='text' id='user-input' placeholder='Escribe tu mensaje...' onkeypress='if(event.key===\"Enter\") sendMessage()'>"
    "        <button onclick='sendMessage()'>Enviar</button>"
    "    </div>"
    "    <script>"
    "        function sendMessage() {"
    "            const input = document.getElementById('user-input');"
    "            const text = input.value.trim();"
    "            if (!text) return;"
    "            addBubble(text, 'user');"
    "            input.value = '';"
    "            window.webkit.messageHandlers.fivemac.postMessage(text);"
    "        }"
    "        function addBubble(content, type) {"
    "            const container = document.getElementById('chat-container');"
    "            const div = document.createElement('div');"
    "            div.className = 'bubble ' + type;"
    "            div.innerHTML = content;"
    "            container.appendChild(div);"
    "            container.scrollTop = container.scrollHeight;"
    "        }"
    "        function addAIResponse(content) { addBubble(content, 'ai'); }"
    "    </script>"
    "</body>"
    "</html>";

    [self.webView loadHTMLString:html baseURL:nil];
}

- (void)userContentController:(WKUserContentController *)userContentController 
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"fivemac"]) {
        [self askAI:message.body];
    }
}

- (void)askAI:(NSString *)query {
    NSURL *url = [NSURL URLWithString:self.apiUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.apiKey] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *payload = @{
        @"model": self.model,
        @"messages": @[
            @{@"role": @"system", @"content": @"Eres un asistente de programación experto en Harbour y FiveMac."},
            @{@"role": @"user", @"content": query}
        ],
        @"temperature": @(0.7)
    };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    [request setHTTPBody:jsonData];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request 
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (json[@"choices"]) {
                NSString *aiText = json[@"choices"][0][@"message"][@"content"];
                NSString *safeText = [[aiText stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] 
                                             stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"addAIResponse(\"%@\")", safeText] completionHandler:nil];
                });
            }
        }
    }] resume];
}

@end

// --- Bridge Harbour ---
// AICreateChat( cApiKey, cModel, [cUrl] )
HB_FUNC( AICREATECHAT ) {
    NSString *apiKey = hb_pcount() > 0 ? [NSString stringWithUTF8String:hb_parc(1)] : @"";
    NSString *model  = hb_pcount() > 1 ? [NSString stringWithUTF8String:hb_parc(2)] : @"llama-3.3-70b-versatile";
    NSString *apiUrl = hb_pcount() > 2 ? [NSString stringWithUTF8String:hb_parc(3)] : @"https://api.groq.com/openai/v1/chat/completions";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AIChatWindow *chatWnd = [[AIChatWindow alloc] initWithContentRect:NSMakeRect(0,0,450,650) 
                                                               styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable 
                                                                 backing:NSBackingStoreBuffered defer:NO];
        chatWnd.apiKey = apiKey;
        chatWnd.model  = model;
        chatWnd.apiUrl = apiUrl;
        [chatWnd makeKeyAndOrderFront:nil];
        [chatWnd center];
    });
}
