import SwiftUI
import AppKit

class SwWindowDelegate: NSObject, NSWindowDelegate {
    let windowId: String
    
    init(windowId: String) {
        self.windowId = windowId
    }

    func windowWillClose(_ notification: Notification) {
        print("SwiftWindow: Ventana \(windowId) cerrándose...")
        
        let deadIds = ViewRegistry.recursiveClean(id: windowId)
        let idsJson = deadIds.map { "\"\($0)\"" }.joined(separator: ", ")
        let json = "{\"_system\":{\"unregister\":[\(idsJson)]}}"
        
        DispatchQueue.global().async {
            Harbour.call("SW_PIPELINE_SYNC", json)
        }
        
    }
}


@_cdecl("HB_FUN_SW_PROCESSEVENTS")
public func sw_processevents_hb(_ p: UnsafeMutableRawPointer?) {
    // 1. En HSW, el Hilo 0 ya bombea NSApp.run().
    // Aquí solo permitimos que el RunLoop del hilo secundario respire.
    let next = Date(timeIntervalSinceNow: 0.001)
    RunLoop.current.run(mode: .default, before: next)
}


// --- MOTOR UNIFICADO DE CREACIÓN ---
@MainActor
public func sw_createwindow_hb_internal(title: String, width: Double, height: Double, id: String) {
    // 1. Registro del Estado
    let windowState = SwiftWindowState(id: id)
    ViewRegistry.register(windowState, for: id)
    
    // 2. Creación de la Ventana
    let windowView = SwWindowView(state: windowState, id: id)
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)),
        styleMask: [.titled, .closable, .miniaturizable, .resizable],
        backing: .buffered,
        defer: false
    )
    window.title = title
    window.center()
    window.backgroundColor = .windowBackgroundColor
    
    // --- INYECCIÓN DE CONTENIDO ---
    let hostingView = NSHostingView(rootView: windowView)
    hostingView.frame = NSRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
    hostingView.autoresizingMask = [.width, .height]
    window.contentView = hostingView
    
    // --- REGISTRO ---
    ViewRegistry.register(window, for: "NSWindow_\(id)")
    
    let delegate = SwWindowDelegate(windowId: id)
    window.delegate = delegate
    ViewRegistry.register(delegate, for: "Delegate_\(id)")
    
    print("SwiftWindow: Ventana \(id) ['\(title)'] creada y registrada físicamente.")
}

// --- MOTOR DE ARRANQUE OBSOLETO (Eliminado en favor de SwMain.m) ---
