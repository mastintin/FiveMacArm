import SwiftUI
import AppKit
import Observation
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
public class SwiftAIChatState {
    var messages: [AIChatMessage] = []
    var isTyping: Bool = false
    var apiKey: String
    var model: String
    var apiUrl: String
    var systemPrompt: String
    
    public init(apiKey: String, model: String, apiUrl: String, systemPrompt: String = "Eres un asistente experto.") {
        self.apiKey = apiKey
        self.model = model
        self.apiUrl = apiUrl.isEmpty ? "https://api.groq.com/openai/v1/chat/completions" : apiUrl
        self.systemPrompt = systemPrompt.isEmpty ? "Eres un asistente experto en Harbour y FiveMac." : systemPrompt
        self.messages.append(AIChatMessage(role: "assistant", content: "¡Hola! ¿En qué puedo ayudarte hoy?"))
    }
    
    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let userMsg = AIChatMessage(role: "user", content: trimmed)
        messages.append(userMsg)
        isTyping = true
        fetchAIResponse(for: trimmed)
    }

    func clear() {
        messages.removeAll()
        messages.append(AIChatMessage(role: "assistant", content: "Chat limpiado. ¿En qué más puedo ayudarte?"))
    }
    
    private func fetchAIResponse(for query: String) {
        print("AIChat: Conectando a \(apiUrl)...")
        guard let url = URL(string: apiUrl) else { 
            print("AIChat: Error - URL inválida")
            return 
        }
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
                    print("AIChat: Error de red - \(error.localizedDescription)")
                    self.messages.append(AIChatMessage(role: "assistant", content: "Error de red: \(error.localizedDescription)"))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("AIChat: Código respuesta HTTP - \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        let errorMsg = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Sin detalles"
                        print("AIChat: Respuesta error del servidor - \(errorMsg)")
                        self.messages.append(AIChatMessage(role: "assistant", content: "Error \(httpResponse.statusCode): \(errorMsg.prefix(100))..."))
                        return
                    }
                }

                guard let data = data else { 
                    print("AIChat: Error - No se recibieron datos")
                    self.messages.append(AIChatMessage(role: "assistant", content: "Error: No se recibieron datos del servidor."))
                    return 
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        self.messages.append(AIChatMessage(role: "assistant", content: content))
                    } else {
                        let raw = String(data: data, encoding: .utf8) ?? "BInario"
                        print("AIChat: Error - JSON inesperado: \(raw)")
                        self.messages.append(AIChatMessage(role: "assistant", content: "Error: Formato JSON inesperado. Raw: \(raw.prefix(50))..."))
                    }
                } catch {
                    print("AIChat: Error al procesar JSON - \(error.localizedDescription)")
                    self.messages.append(AIChatMessage(role: "assistant", content: "Error JSON: \(error.localizedDescription)"))
                }
            }
        }.resume()
    }
}

// MARK: - View Component
public struct SwiftAIChatView: View {
    var state: SwiftAIChatState
    @State private var inputText: String = ""
    
    public var body: some View {
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
                                ProgressView().scaleEffect(0.5)
                                Text("La IA está escribiendo...").font(.caption).italic().foregroundColor(.secondary)
                                Spacer()
                            }.padding(.leading)
                        }
                    }
                    .padding()
                }
                .onChange(of: state.messages.count) {
                    if let lastId = state.messages.last?.id {
                        withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                    }
                }
            }
            Divider()
            HStack {
                TextField("Pregunta algo...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit { send() }
                Button(action: send) {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(inputText.isEmpty || state.isTyping)
            }
            .padding()
        }
        .background(Color(NSColor.controlBackgroundColor))
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
                .padding(10)
                .background(isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isUser ? .white : .primary)
                .cornerRadius(10)
            if !isUser { Spacer() }
        }
    }
}

// MARK: - AIChat Initialization (Codable)
public struct AIChatInit: Codable {
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
}

// MARK: - Bridge
@_cdecl("HB_FUN_SW_AICHAT_CREATE_STATE")
public func sw_aichat_create_state_hb(_ p: UnsafeMutableRawPointer?) {
    let id = hb_parc(1).map { String(cString: $0) } ?? ""
    let jsonStr = hb_parc(2).map { String(cString: $0) } ?? "{}"
    let apiKey = hb_parc(3).map { String(cString: $0) } ?? ""
    let model = hb_parc(4).map { String(cString: $0) } ?? ""
    let apiurl = hb_parc(5).map { String(cString: $0) } ?? ""
    
    let decoder = JSONDecoder()
    let initial = (try? decoder.decode(AIChatInit.self, from: jsonStr.data(using: .utf8) ?? Data()))
                ?? AIChatInit(width: 400, height: 300, top: 0, left: 0)
    
    print("AIChat: Inicializando estado para el control \(id)")
    let state = SwiftAIChatState(apiKey: apiKey, model: model, apiUrl: apiurl)
    ViewRegistry.register(state, for: id)
    
    // Autoregistro del Layout Item (con coordenadas del hState)
    let item = StackItem(type: .aichat, id: id)
    item.itemWidth = initial.width ?? 400
    item.itemHeight = initial.height ?? 300
    item.x = initial.left ?? 0
    item.y = initial.top ?? 0
    ViewRegistry.register(item, for: id)
}

@_cdecl("HB_FUN_SW_AICHAT_CLEAR")
public func sw_aichat_clear_hb(_ p: UnsafeMutableRawPointer?) {
    let id = hb_parc(1).map { String(cString: $0) } ?? ""
    print("AIChat: Solicitud de limpieza para \(id)")
    
    DispatchQueue.main.async {
        if let state = ViewRegistry.get(id) as? SwiftAIChatState {
            state.clear()
        } else {
            print("AIChat: Error al limpiar - Control \(id) no encontrado en el registro")
        }
    }
}
