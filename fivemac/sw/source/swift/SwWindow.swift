import SwiftUI

class SwWindowDelegate: NSObject, NSWindowDelegate {
    let windowId: String
    
    init(windowId: String) {
        self.windowId = windowId
    }

    func windowWillClose(_ notification: Notification) {
        print("SwiftWindow: Ventana \(windowId) cerrándose...")
        
        let closeJson = "{\"\(windowId)\":{\"event\":\"close\"}}"
        Harbour.call("SW_PIPELINE_SYNC", closeJson)
        
        let deadIds = ViewRegistry.recursiveClean(id: windowId)
        
        let idsJson = deadIds.map { "\"\($0)\"" }.joined(separator: ", ")
        let json = "{\"_system\":{\"unregister\":[\(idsJson)]}}"
        
        Harbour.call("SW_PIPELINE_SYNC", json)
    }
}

class SwAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        print("SwiftApp: Última ventana cerrada. Terminando proceso...")
        return true
    }
}

private let appDelegate = SwAppDelegate()

// --- MOTOR UNIFICADO DE CREACIÓN ---
@MainActor
private func createPhysicalWindow(title: String, width: Double, height: Double, id: String) {
    // 1. Registro del Estado (Ancla para la Mensajería)
    let windowState = SwiftWindowState(id: id)
    ViewRegistry.register(windowState, for: id)
    windowState.apply(property: "title", value: title)
    
    // 2. Operaciones de UI en Hilo Principal
    DispatchQueue.main.async {
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
        
        // --- INYECCIÓN DE CONTENIDO (Lo que faltaba) ---
        let hostingView = NSHostingView(rootView: windowView)
        hostingView.wantsLayer = true
        window.contentView = hostingView
        
        // --- DELEGADO PARA EVENTOS ---
        let delegate = SwWindowDelegate(windowId: id)
        window.delegate = delegate
        ViewRegistry.register(delegate, for: "Delegate_\(id)")
        
        // --- EXPOSICIÓN FINAL ---
        window.makeKeyAndOrderFront(nil)
        ViewRegistry.register(window, for: "NSWindow_\(id)")
        
        print("SwiftWindow: Ventana \(id) ['\(title)'] creada físicamente con éxito.")
    }
}

// Wrapper para llamadas desde el Dispatcher (SD/SDS:Create)
@MainActor
public func sw_createwindow_hb_internal(title: String, width: Double, height: Double, id: String) {
    createPhysicalWindow(title: title, width: width, height: height, id: id)
}

@_cdecl("HB_FUN_SW_APPISRUNNING")
public func sw_appisrunning_hb(_ p: UnsafeMutableRawPointer?) {
    Harbour.ret(NSApp.isRunning)
}

@_cdecl("HB_FUN_SW_APPRUN")
public func sw_apprun_hb(_ p: UnsafeMutableRawPointer?) {
    if NSApp.isRunning {
        print("SwiftApp: La aplicación ya está en marcha. Ignorando llamada duplicada a run().")
        return
    }
    
    print("SwiftApp: Iniciando NSApp.run()...")
    NSApp.setActivationPolicy(.regular)
    NSApp.delegate = appDelegate
    NSApp.activate(ignoringOtherApps: true)
    NSApp.run()
}
