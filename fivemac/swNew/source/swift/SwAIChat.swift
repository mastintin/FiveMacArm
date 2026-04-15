import SwiftUI
import AppKit
import HarbourMacro

// MARK: - Message Model (ISOLATED)
struct AIChatMessage: Identifiable {
    let id = UUID()
    let role: String // "user" or "assistant"
    let content: String
    let timestamp = Date()
}

// MARK: - State Manager (ISOLATED)
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
        
        self.messages.append(AIChatMessage(role: "assistant", content: "¡Hola! Estoy listo para ayudarte (Isla SW)."))
    }
    
    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let userMsg = AIChatMessage(role: "user", content: trimmed)
        messages.append(userMsg)
        
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
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isTyping = false
                
                if let error = error {
                    self.messages.append(AIChatMessage(role: "assistant", content: "Error: \(error.localizedDescription)"))
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        self.messages.append(AIChatMessage(role: "assistant", content: content))
                    } else {
                         // Manejo de error de respuesta de API (vía JSON)
                         if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let error = json["error"] as? [String: Any],
                            let message = error["message"] as? String {
                             self.messages.append(AIChatMessage(role: "assistant", content: "API Error: \(message)"))
                         } else {
                             self.messages.append(AIChatMessage(role: "assistant", content: "Error: No se pudo procesar la respuesta."))
                         }
                    }
                } catch {
                    self.messages.append(AIChatMessage(role: "assistant", content: "Error al decodificar JSON."))
                }
            }
        }.resume()
    }
}

// MARK: - View Component (ISOLATED)
struct SwiftAIChatView: View {
    var state: SwiftAIChatState
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(state.messages) { msg in
                            MessageBubble(msg: msg)
                                .id(msg.id)
                        }
                        
                        if state.isTyping {
                            HStack {
                                Text("La IA está escribiendo...")
                                    .font(.caption)
                                    .italic()
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 20)
                                Spacer()
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: state.messages.count) {
                    if let lastId = state.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Input Area
            HStack {
                TextField("Escribe un mensaje...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit { send() }
                
                Button(action: send) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || state.isTyping)
            }
            .padding()
            .background(Color.primary.opacity(0.02))
        }
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
                .clipShape(RoundedRectangle(cornerRadius: 15))
            if !isUser { Spacer() }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - HARBOUR BRIDGE (Isolated for 'sw' branch)

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
    
    let finalId = id.isEmpty ? "AIC_" + UUID().uuidString.prefix(6) : id
    
    func executeCreation() -> Int64 {
        let state = SwiftAIChatState(
            apiKey: params?.apikey ?? "", 
            model: params?.model ?? "llama-3.3-70b-versatile",
            apiUrl: params?.apiurl ?? "",
            systemPrompt: params?.system ?? ""
        )
        
        // Registro en la isla 'sw'
        SwRegistry.register(state, for: finalId)
        
        let view = SwiftAIChatView(state: state)
        let hostingView = NSHostingView(rootView: view)
        hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            applySwiftViewLayout(swiftView: hostingView, parent: parentObj, top: top, left: left, w: width, h: height)
            
            let viewPtr = Unmanaged.passRetained(hostingView).toOpaque()
            return Int64(Int(bitPattern: viewPtr))
        }
        return 0
    }

    if Thread.isMainThread { return executeCreation() } else { return DispatchQueue.main.sync { executeCreation() } }
}
