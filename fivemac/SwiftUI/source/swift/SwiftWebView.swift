import SwiftUI
import WebKit
import Observation
import HarbourMacro

@Observable
public class SwiftWebViewState {
    public var id: String = ""
    public var phbWebview: PHB_ITEM? = nil
    
    public var url: URL? = nil
    public var html: String? = nil
    public var baseURL: URL? = nil
    public var isLoading: Bool = false
    public var estimatedProgress: Double = 0
    public var title: String = ""
    public var canGoBack: Bool = false
    public var canGoForward: Bool = false
    public var magnification: Double = 1.0
    
    // Internal trigger for actions
    enum Action {
        case none
        case goBack
        case goForward
        case reload
        case stopLoading
        case evaluateJavaScript(String, ((Any?, Error?) -> Void)?)
        case setMagnification(Double)
        case savePDF(URL)
    }
    
    var pendingAction: Action = .none
    
    public init(id: String) {
        self.id = id
    }
}

public struct SwiftWebView: View {
    @Bindable var state: SwiftWebViewState

    public init(state: SwiftWebViewState) {
        self.state = state
    }

    public var body: some View {
        WebViewRepresentable(state: state)
    }
}

struct WebViewRepresentable: NSViewRepresentable {
    @Bindable var state: SwiftWebViewState

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // Add script handler
        userContentController.add(context.coordinator, name: "fivemac")
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        // Observe properties
        context.coordinator.setupObservers(for: webView)
        
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        if let url = state.url {
            nsView.load(URLRequest(url: url))
            DispatchQueue.main.async { state.url = nil }
        }
        
        if let html = state.html {
            nsView.loadHTMLString(html, baseURL: state.baseURL)
            DispatchQueue.main.async {
                state.html = nil
                state.baseURL = nil
            }
        }
        
        // Handle pending actions
        switch state.pendingAction {
        case .goBack:
            if nsView.canGoBack { nsView.goBack() }
        case .goForward:
            if nsView.canGoForward { nsView.goForward() }
        case .reload:
            nsView.reload()
        case .stopLoading:
            nsView.stopLoading()
        case .evaluateJavaScript(let script, let completion):
            nsView.evaluateJavaScript(script, completionHandler: completion)
        case .setMagnification(let value):
            nsView.setMagnification(CGFloat(value), centeredAt: NSPoint(x: nsView.bounds.midX, y: nsView.bounds.midY))
        case .savePDF(let url):
            if #available(macOS 11.0, *) {
                nsView.createPDF { result in
                    switch result {
                    case .success(let data):
                        try? data.write(to: url)
                        print("[SwiftWebView] PDF saved to: \(url.path)")
                    case .failure(let error):
                        print("[SwiftWebView] PDF error: \(error.localizedDescription)")
                    }
                }
            }
        case .none:
            break
        }
        
        if case .none = state.pendingAction {} else {
            DispatchQueue.main.async { state.pendingAction = .none }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(state: state)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var state: SwiftWebViewState
        var observers: [NSKeyValueObservation] = []
        static var pSymOnMessage: UnsafeMutableRawPointer? = nil

        init(state: SwiftWebViewState) {
            self.state = state
        }
        
        func setupObservers(for webView: WKWebView) {
            observers.append(webView.observe(\.isLoading, options: .new) { [weak self] view, _ in
                DispatchQueue.main.async { self?.state.isLoading = view.isLoading }
            })
            observers.append(webView.observe(\.estimatedProgress, options: .new) { [weak self] view, _ in
                DispatchQueue.main.async { self?.state.estimatedProgress = view.estimatedProgress }
            })
            observers.append(webView.observe(\.title, options: .new) { [weak self] view, _ in
                DispatchQueue.main.async { self?.state.title = view.title ?? "" }
            })
            observers.append(webView.observe(\.canGoBack, options: .new) { [weak self] view, _ in
                DispatchQueue.main.async { self?.state.canGoBack = view.canGoBack }
            })
            observers.append(webView.observe(\.canGoForward, options: .new) { [weak self] view, _ in
                DispatchQueue.main.async { self?.state.canGoForward = view.canGoForward }
            })
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "fivemac" {
                SwiftBridge.onAction(state.id, "\(message.body)", message.name)
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
    }
}

// MARK: - Harbour Loader

@objc(SwiftWebViewLoader)
public class SwiftWebViewLoader: NSObject {
    static var states: [String: SwiftWebViewState] = [:]

    @objc(makeWebViewWithId:)
    public static func makeWebView(id: String?) -> NSView {
        let finalId = (id == nil || id!.isEmpty) ? UUID().uuidString : id!
        let state = SwiftWebViewState(id: finalId)
        states[finalId] = state
        
        let view = SwiftWebView(state: state)
        ViewRegistry.register(view, for: finalId)
        
        let hostingView = NSHostingView(rootView: view)
        hostingView.sizingOptions = []
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the native NSView identifier
        hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
        
        // Register the hostingView as a generic NSView object for operations like capturing PDF
        ViewRegistry.registerObject(hostingView, for: finalId)
        
        return hostingView
    }
}

// MARK: - Harbour Direct Functions

/*
// MARK: - Harbour Manual Bridge (Creation) (Commented for testing improved @HarbourDirect)
@_cdecl("HB_FUN_SD_SW_WEBVIEW_CREATE")
public func sw_webview_create_manual(_ p: UnsafeMutableRawPointer?) {
    let top = hb_parnd(1)
    let left = hb_parnd(2)
    let w = hb_parnd(3)
    let h = hb_parnd(4)
    let parentPtr = hb_parnll(5)
    let hbObject = hb_param(6, HB_IT_ANY)
    let id = hb_parc(7).map { String(cString: $0) } ?? ""
    
    let view = SwiftWebViewLoader.makeWebView(id: id)
    
    if let state = SwiftWebViewLoader.states[id] {
        state.phbWebview = hb_itemNew(hbObject)
    }
    
    if parentPtr != 0 {
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            applySwiftViewLayout(swiftView: view, parent: parentObj, top: top, left: left, w: w, h: h)
        }
    }
    
    let viewAddr = Int64(Int(bitPattern: Unmanaged.passUnretained(view).toOpaque()))
    hb_retnll(viewAddr)
}
*/

// MARK: - Harbour Direct Functions

@HarbourDirect
public func sw_webview_create(top: Double, left: Double, w: Double, h: Double, parent: Int64, hbObject: PHB_ITEM?, id: String) -> Int64 {
    let view = SwiftWebViewLoader.makeWebView(id: id)
    let finalId = view.identifier?.rawValue ?? id 
    
    if let state = SwiftWebViewLoader.states[finalId] {
        state.phbWebview = hb_itemNew(hbObject)
    }
    
    if parent != 0 {
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parent)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            applySwiftViewLayout(swiftView: view, parent: parentObj, top: top, left: left, w: w, h: h)
        }
    }
    
    return Int64(Int(bitPattern: Unmanaged.passUnretained(view).toOpaque()))
}

@HarbourDirect
public func sw_webview_load(id: String, url: String) {
    if let state = SwiftWebViewLoader.states[id] {
        state.url = URL(string: url)
    }
}

@HarbourDirect
public func sw_webview_load_html(id: String, html: String, baseUrl: String?) {
    if let state = SwiftWebViewLoader.states[id] {
        state.html = html
        if let base = baseUrl {
            state.baseURL = base.hasPrefix("http") ? URL(string: base) : URL(fileURLWithPath: base)
        }
    }
}

@HarbourDirect
public func sw_webview_load_file(id: String, path: String) {
    if let state = SwiftWebViewLoader.states[id] {
        let fileURL = URL(fileURLWithPath: path)
        state.url = fileURL
    }
}

@HarbourDirect
public func sw_webview_go_back(id: String) {
    SwiftWebViewLoader.states[id]?.pendingAction = .goBack
}

@HarbourDirect
public func sw_webview_go_forward(id: String) {
    SwiftWebViewLoader.states[id]?.pendingAction = .goForward
}

@HarbourDirect
public func sw_webview_reload(id: String) {
    SwiftWebViewLoader.states[id]?.pendingAction = .reload
}

@HarbourDirect
public func sw_webview_stop(id: String) {
    SwiftWebViewLoader.states[id]?.pendingAction = .stopLoading
}

@HarbourDirect
public func sw_webview_is_loading(id: String) -> Bool {
    return SwiftWebViewLoader.states[id]?.isLoading ?? false
}

@HarbourDirect
public func sw_webview_progress(id: String) -> Int {
    let progress = SwiftWebViewLoader.states[id]?.estimatedProgress ?? 0
    return Int(progress * 100)
}

@HarbourDirect
public func sw_webview_eval(id: String, script: String) {
    SwiftWebViewLoader.states[id]?.pendingAction = .evaluateJavaScript(script, nil)
}

@HarbourDirect
public func sw_webview_eval_arg(id: String, method: String, arg: String) {
     let safeArg = arg.replacingOccurrences(of: "'", with: "\\'")
     let js = "\(method)('\(safeArg)')"
     SwiftWebViewLoader.states[id]?.pendingAction = .evaluateJavaScript(js, nil)
}

@HarbourDirect
public func sw_webview_set_zoom(id: String, zoom: Double) {
    SwiftWebViewLoader.states[id]?.pendingAction = .setMagnification(zoom)
}

@HarbourDirect
public func sw_webview_save_pdf(id: String, path: String) {
    if let state = SwiftWebViewLoader.states[id] {
        state.pendingAction = .savePDF(URL(fileURLWithPath: path))
    }
}
