import Foundation
import AppKit
import SwiftUI

// --- EL DELEGADO DE LA APP ---
class HswAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🏝️ [HSW] Swift: App lista y Hilo 0 bajo control.")
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

private let appDelegate = HswAppDelegate()

// --- PUNTO DE ENTRADA DESDE C ---
@_cdecl("hsw_swift_start")
public func hsw_swift_start() {
    let app = NSApplication.shared
    app.setActivationPolicy(.regular)
    app.delegate = appDelegate
    
    print("🏝️ [HSW] Swift: Motor de UI iniciado.")
    
    // Lanzamos el bucle infinito de macOS
    app.activate(ignoringOtherApps: true)
    app.run()
}

// --- COMUNICACIÓN ENTRE HILOS ---
@_cdecl("HSW_SEND_COMMAND")
public func hsw_send_command_hb(_ p: UnsafePointer<Int8>?) {
    // 1. Recibimos el puntero directo de Harbour
    guard let p = p else { return }
    let jsonStr = String(cString: p)
    
    // 2. Despachamos al hilo principal
    DispatchQueue.main.async {
        HswDispatcher.shared.execute(json: jsonStr)
    }
}

// --- ESTRUCTURA DE COMANDO ---
struct HswCommand: Decodable {
    let cmd: String
    let title: String?
    let width: Double?
    let height: Double?
}

// --- EL DESPACHADOR (DISPATCHER) ---
@MainActor
class HswDispatcher {
    static let shared = HswDispatcher()
    
    // Almacén para que las ventanas no sean recolectadas por el sistema
    private var windows: [NSWindow] = []
    
    func execute(json: String) {
        print("🏝️ [HSW] Dispatcher: Recibido -> \(json)")
        
        guard let data = json.data(using: .utf8),
              let command = try? JSONDecoder().decode(HswCommand.self, from: data) else {
            print("🏝️ [HSW] Error: JSON inválido")
            return
        }
        
        switch command.cmd {
        case "create_window":
            createWindow(title: command.title ?? "HSW", width: command.width ?? 400, height: command.height ?? 300)
        default:
            print("🏝️ [HSW] Comando desconocido: \(command.cmd)")
        }
    }
    
    private func createWindow(title: String, width: Double, height: Double) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.center()
        
        let contentView = NSHostingView(rootView: HswPoCView())
        window.contentView = contentView
        
        // Guardamos la referencia para que viva
        windows.append(window)
        
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        print("🏝️ [HSW] Swift: Ventana '\(title)' creada y mostrada.")
    }
}

// --- VISTA SwiftUI DEL POC ---
struct HswPoCView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Un círculo girando para demostrar fluidez (60 fps)
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(AngularGradient(gradient: .init(colors: [.blue, .purple, .blue]), center: .center), lineWidth: 8)
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            
            Text("¡Arquitectura HSW Activa!")
                .font(.headline)
            
            Button("Click (Hilo UI)") {
                print("🏝️ [HSW] SwiftUI: Click instantáneo detectado.")
            }
            .buttonStyle(.borderedProminent)
            
            Button("Cerrar App") {
                print("🏝️ [HSW] SwiftUI: Cerrando aplicación...")
                NSApp.terminate(nil)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            
            Text("Harbour está procesando en el otro hilo...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 400, height: 300)
    }
}
