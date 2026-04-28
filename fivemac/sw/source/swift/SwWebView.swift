import SwiftUI
import WebKit
import Observation

// MARK: - WebView State
@Observable
public class WebViewState: SwApplyable {
    public let id: String
    public var url: URL? = nil
    public var html: String? = nil
    public var localFile: URL? = nil
    public var pdfExportPath: URL? = nil
    
    public var title: String = ""
    public var isLoading: Bool = false
    public var progress: Double = 0
    public var zoomLevel: Double = 1.0
    public var textSizeMultiplier: Double = 1.0
    public var pendingScript: String? = nil
    public var isVisible: Bool = true
    
    public enum Action {
        case none, goBack, goForward, reload, stop
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
            if let sVal = value as? String { self.html = sVal }
        case "loadfile":
            if let sVal = value as? String { self.localFile = URL(fileURLWithPath: sVal) }
        case "savetopdf":
            if let sVal = value as? String { self.pdfExportPath = URL(fileURLWithPath: sVal) }
        case "goback":
            self.pendingAction = .goBack
        case "goforward":
            self.pendingAction = .goForward
        case "reload":
            self.pendingAction = .reload
        case "stop":
            self.pendingAction = .stop
        case "eval":
            if let sVal = value as? String { self.pendingScript = sVal }
        case "zoom":
            if let dVal = (value as? NSNumber)?.doubleValue { self.zoomLevel = dVal }
        case "textsize":
            if let dVal = (value as? NSNumber)?.doubleValue { self.textSizeMultiplier = dVal / 100.0 }
        case "visible":
            if let bVal = value as? Bool { self.isVisible = bVal }
            else if let iVal = value as? Int { self.isVisible = (iVal != 0) }
        default:
            break
        }
    }
}

// MARK: - SwiftUI Representable
public struct SwiftWebView: View {
    @Bindable var state: WebViewState
    
    public var body: some View {
        if state.isVisible {
            ZStack(alignment: .top) {
                WKWebViewRepresentable(state: state)
                
                if state.isLoading {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * CGFloat(state.progress), height: 3)
                            .animation(.linear, value: state.progress)
                    }
                    .frame(height: 3)
                }
            }
        }
    }
}

struct WKWebViewRepresentable: NSViewRepresentable {
    @Bindable var state: WebViewState
    
    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "harbour")
        config.userContentController = controller
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        
        context.coordinator.setupObservers(for: webView)
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // Load URL
        if let url = state.url {
            nsView.load(URLRequest(url: url))
            DispatchQueue.main.async { state.url = nil }
        }
        
        // Load HTML
        if let html = state.html {
            nsView.loadHTMLString(html, baseURL: nil)
            DispatchQueue.main.async { state.html = nil }
        }
        
        // Load Local File
        if let fileUrl = state.localFile {
            let directory = fileUrl.deletingLastPathComponent()
            nsView.loadFileURL(fileUrl, allowingReadAccessTo: directory)
            DispatchQueue.main.async { state.localFile = nil }
        }
        
        // Export to PDF
        if let pdfUrl = state.pdfExportPath {
            let config = WKPDFConfiguration()
            nsView.createPDF(configuration: config) { result in
                switch result {
                case .success(let data):
                    do {
                        try data.write(to: pdfUrl)
                        SwDispatcher.shared.enqueueEvent(id: state.id, type: "pdfExported", data: ["path": pdfUrl.path])
                    } catch {
                        print("🏝️ [WebView] PDF Write Error: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("🏝️ [WebView] PDF Generation Error: \(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async { state.pdfExportPath = nil }
        }
        
        // Zoom Level
        if nsView.magnification != CGFloat(state.zoomLevel) {
            nsView.setMagnification(CGFloat(state.zoomLevel), centeredAt: .zero)
        }
        
        // Text Size Multiplier via JS injection
        if state.textSizeMultiplier != 1.0 {
            let script = "document.body.style.webkitTextSizeAdjust = '\(Int(state.textSizeMultiplier * 100))%'"
            nsView.evaluateJavaScript(script)
        }
        
        // Execute Script
        if let script = state.pendingScript {
            nsView.evaluateJavaScript(script)
            DispatchQueue.main.async { state.pendingScript = nil }
        }
        
        // Actions
        switch state.pendingAction {
        case .goBack: if nsView.canGoBack { nsView.goBack() }
        case .goForward: if nsView.canGoForward { nsView.goForward() }
        case .reload: nsView.reload()
        case .stop: nsView.stopLoading()
        case .none: break
        }
        
        if state.pendingAction != .none {
            DispatchQueue.main.async { state.pendingAction = .none }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(state: state)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var state: WebViewState
        var observers: [NSKeyValueObservation] = []
        
        init(state: WebViewState) {
            self.state = state
        }
        
        func setupObservers(for webView: WKWebView) {
            observers.append(webView.observe(\.isLoading, options: .new) { [weak self] view, _ in
                let loading = view.isLoading
                DispatchQueue.main.async { 
                    self?.state.isLoading = loading 
                    SwDispatcher.shared.recordChange(id: self?.state.id ?? "", property: "isloading", value: loading)
                }
            })
            observers.append(webView.observe(\.estimatedProgress, options: .new) { [weak self] view, _ in
                let progress = view.estimatedProgress
                DispatchQueue.main.async { 
                    self?.state.progress = progress 
                    SwDispatcher.shared.recordChange(id: self?.state.id ?? "", property: "progress", value: progress)
                }
            })
            observers.append(webView.observe(\.title, options: .new) { [weak self] view, _ in
                let title = view.title ?? ""
                DispatchQueue.main.async { 
                    self?.state.title = title
                    SwDispatcher.shared.recordChange(id: self?.state.id ?? "", property: "title", value: title)
                }
            })
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "harbour" {
                SwDispatcher.shared.enqueueEvent(id: state.id, type: "jsMessage", data: ["body": message.body])
            }
        }
    }
}

// MARK: - Factory Logic
extension SwiftWebView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(WebViewInit.self, from: jsonData)
        let state = WebViewState(id: id)
        if let urlStr = initial.url { state.apply(property: "url", value: urlStr) }
        if let htmlStr = initial.html { state.apply(property: "html", value: htmlStr) }
        ViewRegistry.register(state, for: id)
        let item = StackItem(type: .webview, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

// MARK: - Data Structures
public struct WebViewInit: Codable, GeometryProtocol {
    public let url, html: String?
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let parentwidth, parentheight: Double?
}
