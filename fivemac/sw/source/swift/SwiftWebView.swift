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
    public let interactive: Bool?
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
    public let resizemask: Int?
    public let hasScroll: Bool?
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
