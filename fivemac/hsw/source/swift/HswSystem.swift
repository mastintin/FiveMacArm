import SwiftUI

// --- EL ESTADO GLOBAL DE LA APP (Fuente de Verdad) ---
@Observable @MainActor
class HswAppState {
    static let shared = HswAppState()
    
    // Lista de datos de ventanas que SwiftUI debe renderizar
    var windowList: [HswWindowData] = []
    
    func addWindow(id: String, title: String, width: Double, height: Double) {
        let newWindow = HswWindowData(id: id, title: title, width: width, height: height)
        windowList.append(newWindow)
        print("🏝️ [HSW] Estado: Añadida ventana '\(title)' con ID \(id)")
    }
}

// --- DATOS DE UNA VENTANA ---
struct HswWindowData: Identifiable {
    let id: String // ID enviado por Harbour (ej: "W12345")
    var title: String
    var width: Double
    var height: Double
}

// --- LA APLICACIÓN SWIFTUI PURA (El camino de Apple) ---
struct HswApp: App {
    @State private var appState = HswAppState.shared
    
    var body: some Scene {
        WindowGroup {
            HswMainContainerView(state: appState)
        }
        .windowStyle(.hiddenTitleBar)
    }
}

// --- CONTENEDOR PRINCIPAL ---
struct HswMainContainerView: View {
    var state: HswAppState
    
    var body: some View {
        if state.windowList.isEmpty {
            VStack {
                ProgressView()
                Text("Esperando órdenes de Harbour...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 300, height: 200)
        } else {
            // Renderizamos todas las ventanas activas
            ZStack {
                ForEach(state.windowList) { windowData in
                    HswPoCView(data: windowData)
                }
            }
        }
    }
}

// --- PUNTO DE ENTRADA DESDE HARBOUR ---
@_cdecl("hsw_swift_start")
public func hsw_swift_start() {
    print("🏝️ [HSW] Swift: Iniciando App SwiftUI...")
    HswApp.main()
}

// --- COMUNICACIÓN ENTRE HILOS ---
@_cdecl("HSW_SEND_COMMAND")
public func hsw_send_command_hb(_ p: UnsafePointer<Int8>?) {
    guard let p = p else { return }
    let jsonStr = String(cString: p)
    
    DispatchQueue.main.async {
        HswDispatcher.shared.execute(json: jsonStr)
    }
}

// --- ESTRUCTURA DE COMANDO (Flexible) ---
struct HswCommand: Decodable {
    let cmd: String
    let id: String?
    let title: String?
    let width: Double?
    let height: Double?
    let props: [String: HswValue]?
}

enum HswValue: Decodable {
    case string(String)
    case double(Double)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let s = try? container.decode(String.self) { self = .string(s) }
        else if let d = try? container.decode(Double.self) { self = .double(d) }
        else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Tipo no soportado") }
    }
}

// --- EL DESPACHADOR (Actualiza el Estado, no la UI) ---
@MainActor
class HswDispatcher {
    static let shared = HswDispatcher()
    
    func execute(json: String) {
        print("🏝️ [HSW] Dispatcher: Recibido -> \(json)")
        
        guard let data = json.data(using: .utf8),
              let command = try? JSONDecoder().decode(HswCommand.self, from: data) else {
            return
        }
        
        switch command.cmd {
        case "create_window":
            HswAppState.shared.addWindow(
                id: command.id ?? "W\(Date().timeIntervalSince1970)",
                title: command.title ?? "HSW Window",
                width: command.width ?? 400,
                height: command.height ?? 300
            )
            
        case "apply":
            if let id = command.id, let props = command.props {
                applyProperties(id: id, props: props)
            }
            
        default:
            break
        }
    }
    
    private func applyProperties(id: String, props: [String: HswValue]) {
        guard let index = HswAppState.shared.windowList.firstIndex(where: { $0.id == id }) else { return }
        
        for (key, value) in props {
            switch (key, value) {
            case ("title", .string(let s)):
                HswAppState.shared.windowList[index].title = s
            case ("width", .double(let d)):
                HswAppState.shared.windowList[index].width = d
            case ("height", .double(let d)):
                HswAppState.shared.windowList[index].height = d
            default:
                break
            }
        }
        print("🏝️ [HSW] Estado: Actualizadas propiedades de ventana \(id)")
    }
}

// --- VISTA SwiftUI DEL POC ---
struct HswPoCView: View {
    let data: HswWindowData
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.1), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: 0.6)
                    .stroke(LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom), 
                            style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(rotation))
            }
            .frame(width: 100, height: 100)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
            
            VStack(spacing: 5) {
                Text(data.title)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                
                Text("SwiftUI Data-Driven Window")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider().padding(.horizontal)
            
            HStack(spacing: 15) {
                Button(action: {}) {
                    Label("Aceptar", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button(action: { NSApp.terminate(nil) }) {
                    Text("Salir")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(30)
        .frame(width: CGFloat(data.width), height: CGFloat(data.height))
        .background(.ultraThinMaterial)
    }
}
