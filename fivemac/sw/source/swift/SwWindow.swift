import SwiftUI

class SwWindowDelegate: NSObject, NSWindowDelegate {
    let windowId: String
    
    init(windowId: String) {
        self.windowId = windowId
    }

    func windowWillClose(_ notification: Notification) {
        print("SwiftWindow: Ventana \(windowId) cerrándose...")
        
        // 1. Notificar primero el evento de cierre para que Harbour pueda reaccionar
        let closeJson = "{\"\(windowId)\":{\"event\":\"close\"}}"
        Harbour.call("SW_PIPELINE_SYNC", closeJson)
        
        // 2. Limpieza recursiva de memoria nativa y recolección de IDs
        let deadIds = ViewRegistry.recursiveClean(id: windowId)
        
        // 3. Notificar a Harbour para desregistro masivo definitivo
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

@_cdecl("HB_FUN_SW_CREATEWINDOW")
public func sw_createwindow_hb(_ p: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    let title = hb_parc(1).map { String(cString: $0) } ?? "FiveMac SwiftUI"
    let width = hb_parni(2)
    let height = hb_parni(3)
    let windowId = hb_parc(4).map { String(cString: $0) } ?? UUID().uuidString
    
    print("SwiftWindow: Creando ventana \(windowId) - \(title) (\(width)x\(height))")
    
    let state = SwiftWindowState(id: windowId)
    ViewRegistry.register(state, for: windowId)
    
    DispatchQueue.main.async {
        let windowView = SwWindowView(state: state, id: windowId)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.center()
        window.backgroundColor = .windowBackgroundColor
        
        // Creamos la hosting view y forzamos la persistencia de su capa
        let hostingView = NSHostingView(rootView: windowView)
        hostingView.wantsLayer = true
        if let layer = hostingView.layer {
            layer.backgroundColor = NSColor.windowBackgroundColor.cgColor
            // Política de redibujado manual: no limpies la capa automáticamente
            hostingView.layerContentsRedrawPolicy = .onSetNeedsDisplay
        }
        
        window.contentView = hostingView
        
        let delegate = SwWindowDelegate(windowId: windowId)
        window.delegate = delegate
        // Persist the delegate too
        ViewRegistry.register(delegate, for: "Delegate_\(windowId)")
        
        window.makeKeyAndOrderFront(nil)
        
        // Save the window object in the registry so it doesn't get deallocated
        ViewRegistry.register(window, for: "NSWindow_\(windowId)")
    }
    
    return UnsafeMutableRawPointer(bitPattern: 1)
}

// HB_FUN_SW_ADD_WINDOW_ITEM eliminada: delegamos en SwComponentFactory para evitar duplicados

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
