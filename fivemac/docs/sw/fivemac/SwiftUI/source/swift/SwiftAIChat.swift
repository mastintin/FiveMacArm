import SwiftUI
import AppKit
import HarbourMacro

// MARK: - Message Model
struct AIChatMessage: Identifiable {
    let id = UUID()
    let role: String // "user" or "assistant"
    let content: String
    let timestamp = Date()
}

// MARK: - State Manager
@Observable
class SwiftAIChatState {
    var messages: [AIChatMessage] = []
    var isTyping: Bool = false
    var apiKey: String
    var model: String
    var apiUrl: String
    var systemPrompt: String
    
    init(apiKey: String, model: String, apiUrl: String, systemPrompt: String = "Eres un asistente experto.") {
        self.apiKey = apiKey
        self.model = model
        self.apiUrl = apiUrl.isEmpty ? "https://api.groq.com/openai/v1/chat/completions" : apiUrl
        self.systemPrompt = systemPrompt.isEmpty ? "Eres un asistente experto en Harbour y FiveMac." : systemPrompt
        
        self.messages.append(AIChatMessage(role: "assistant", content: "¡Hola! Estoy listo para ayudarte."))
    }
    
    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let userMsg = AIChatMessage(role: "user", content: trimmed)
        messages.append(userMsg)
        
        // Start AI Query
        isTyping = true
        fetchAIResponse(for: trimmed)
    }
    
    private func fetchAIResponse(for query: String) {
        guard let url = URL(string: apiUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": query]
            ],
            "temperature": 0.7
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isTyping = false
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    self.messages.append(AIChatMessage(role: "assistant", content: content))
                } else {
                    self.messages.append(AIChatMessage(role: "assistant", content: "Error: No se pudo conectar con el servicio de IA."))
                }
            }
        }.resume()
    }
}

// MARK: - UI View
struct SwiftAIChatView: View {
    @State var state: SwiftAIChatState
    @State private var inputText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.blue)
                Text("Assistant")
                    .font(.headline)
                Spacer()
                if state.isTyping {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            // Messages (Smooth Scroll)
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(state.messages) { msg in
                            MessageBubble(msg: msg)
                                .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: state.messages.count) {
                    if let last = state.messages.last {
                        withAnimation(.spring()) { 
                            proxy.scrollTo(last.id, anchor: .bottom) 
                        }
                    }
                }
            }
            
            // Input Area
            HStack(spacing: 12) {
                TextField("Escribe un mensaje...", text: $inputText)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(20)
                    .focused($isFocused)
                    .onSubmit { send() }
                
                Button(action: send) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(inputText.isEmpty ? .secondary : .blue)
                }
                .buttonStyle(.plain)
                .disabled(inputText.isEmpty)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .frame(minWidth: 400, minHeight: 500)
    }
    
    private func send() {
        state.sendMessage(inputText)
        inputText = ""
    }
}

struct MessageBubble: View {
    let msg: AIChatMessage
    
    var isUser: Bool { msg.role == "user" }
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            Text(msg.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isUser ? Color.blue : Color.primary.opacity(0.1))
                .foregroundColor(isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 15)) // Simplificado para macOS
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            if !isUser { Spacer() }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Fivemac Standard Loader
@objc(SwiftAIChatLoader)
public class SwiftAIChatLoader: NSObject {
    
    public static func makeChatView(id: String, apiKey: String, model: String, apiUrl: String = "", systemPrompt: String = "") -> NSView {
        let state = SwiftAIChatState(apiKey: apiKey, model: model, apiUrl: apiUrl, systemPrompt: systemPrompt)
        let view = SwiftAIChatView(state: state)
        
        ViewRegistry.register(state, for: id)
        
        let hostingView = NSHostingView(rootView: view)
        hostingView.identifier = NSUserInterfaceItemIdentifier(id)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        return hostingView
    }
}

// MARK: - STANDALONE WINDOW VERSION (SD_ Prefix)

@_cdecl("HB_FUN_SD_SW_AICHAT_OPEN")
public func sw_aichat_open(_ p: UnsafeMutableRawPointer?) {
    let apiKey = hb_parc(1).map({ String(cString: $0) }) ?? ""
    let model = hb_parc(2).map({ String(cString: $0) }) ?? "llama-3.3-70b-versatile"
    let apiUrl = hb_parc(3).map({ String(cString: $0) }) ?? ""
    let systemPrompt = hb_parc(4).map({ String(cString: $0) }) ?? ""
    
    let state = SwiftAIChatState(apiKey: apiKey, model: model, apiUrl: apiUrl, systemPrompt: systemPrompt)
    let view = SwiftAIChatView(state: state)
    
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 450, height: 600),
        styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
        backing: .buffered,
        defer: false
    )
    
    window.center()
    window.title = "AI Assistant (SwiftUI)"
    window.isReleasedWhenClosed = false
    window.contentView = NSHostingView(rootView: view)
    window.makeKeyAndOrderFront(nil)
}

// MARK: - HARBOUR BRIDGE (Standard Signature for Embedded Control)

@HarbourDirect
public func sw_aichat_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    json: String, 
    parentPtr: Int64,
    id: String
) -> Int64 {
    
    let decoder = JSONDecoder()
    struct ChatParams: Codable { 
        let apikey: String?
        let model: String?
        let apiurl: String? 
        let system: String?
    }
    let params = (try? decoder.decode(ChatParams.self, from: json.data(using: .utf8) ?? Data()))
    
    func executeCreation() -> Int64 {
        let chatView = SwiftAIChatLoader.makeChatView(
            id: id, 
            apiKey: params?.apikey ?? "", 
            model: params?.model ?? "llama-3.3-70b-versatile",
            apiUrl: params?.apiurl ?? "",
            systemPrompt: params?.system ?? ""
        )

        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            applySwiftViewLayout(swiftView: chatView, parent: parentObj, top: top, left: left, w: width, h: height)
            return Int64(Int(bitPattern: Unmanaged.passRetained(chatView).toOpaque()))
        }
        return 0
    }

    if Thread.isMainThread { return executeCreation() } else { return DispatchQueue.main.sync { executeCreation() } }
}
