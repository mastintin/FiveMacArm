import SwiftUI
import WebKit
import Observation

// MARK: - WebView State (Pure Sw Island Architecture)
@Observable
public class WebViewState: SwApplyable {
    public let id: String
    public var url: URL? = nil
    public var html: String? = nil
    public var title: String = ""
    public var isLoading: Bool = false
    public var progress: Double = 0
    
    // Commands for orchestration
    public enum Action {
        case none
        case goBack
        case goForward
        case reload
    }
    public var pendingAction: Action = .none
    
    public init(id: String) {
        self.id = id
    }
    
    @MainActor
    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "url":
            if let sVal = value as? String, let newUrl = URL(string: sVal) {
                self.url = newUrl
            }
        case "html":
            if let sVal = value as? String {
                self.html = sVal
            }
        case "goback":
            self.pendingAction = .goBack
        case "goforward":
            self.pendingAction = .goForward
        case "reload":
            self.pendingAction = .reload
        default:
            break
        }
    }
}

// MARK: - WebView Initialization (Codable)
public struct WebViewInit: Codable {
    public let url: String?
    public let html: String?
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
    public let resizemask: Int?
}

// MARK: - Native Bridge
@_cdecl("HB_FUN_SW_WEBVIEW_CREATE")
public func sw_webview_create_hb(_ p: UnsafeMutableRawPointer?) {
    let id = hb_parc(1).map { String(cString: $0) } ?? UUID().uuidString
    let jsonStr = hb_parc(2).map { String(cString: $0) } ?? "{}"
    
    let decoder = JSONDecoder()
    let initial = (try? decoder.decode(WebViewInit.self, from: jsonStr.data(using: .utf8) ?? Data()))
                ?? WebViewInit(url: nil, html: nil, width: 400, height: 300, top: 0, left: 0)
    
    if ViewRegistry.getState(for: id) == nil {
        let state = WebViewState(id: id)
        if let urlStr = initial.url { state.url = URL(string: urlStr) }
        state.html = initial.html
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .webview, id: id)
        item.itemWidth = initial.width ?? 400
        item.itemHeight = initial.height ?? 300
        item.x = initial.left ?? 0
        item.y = initial.top ?? 0
        item.resizemask = initial.resizemask ?? 0
        ViewRegistry.register(item, for: id)
    }
}

// MARK: - SwiftUI Representable
public struct SwiftWebView: View {
    @Bindable var state: WebViewState
    
    public var body: some View {
        WKWebViewRepresentable(state: state)
    }
}

struct WKWebViewRepresentable: NSViewRepresentable {
    @Bindable var state: WebViewState
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        // Observe progress and title
        context.coordinator.setupObservers(for: webView)
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Handle URL change
        if let url = state.url {
            nsView.load(URLRequest(url: url))
            DispatchQueue.main.async { state.url = nil }
        }
        
        // Handle HTML change
        if let html = state.html {
            nsView.loadHTMLString(html, baseURL: nil)
            DispatchQueue.main.async { state.html = nil }
        }
        
        // Handle Actions
        switch state.pendingAction {
        case .goBack:
            if nsView.canGoBack { nsView.goBack() }
        case .goForward:
            if nsView.canGoForward { nsView.goForward() }
        case .reload:
            nsView.reload()
        case .none:
            break
        }
        
        if state.pendingAction != .none {
            DispatchQueue.main.async { state.pendingAction = .none }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(state: state)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var state: WebViewState
        var observers: [NSKeyValueObservation] = []
        
        init(state: WebViewState) {
            self.state = state
        }
        
        func setupObservers(for webView: WKWebView) {
            observers.append(webView.observe(\.isLoading, options: .new) { [weak self] view, _ in
                DispatchQueue.main.async { self?.state.isLoading = view.isLoading }
            })
            observers.append(webView.observe(\.estimatedProgress, options: .new) { [weak self] view, _ in
                DispatchQueue.main.async { self?.state.progress = view.estimatedProgress }
            })
            observers.append(webView.observe(\.title, options: .new) { [weak self] view, _ in
                DispatchQueue.main.async { self?.state.title = view.title ?? "" }
            })
        }
    }
}
