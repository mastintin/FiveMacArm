import SwiftUI
import AppKit
import HarbourMacro

// MARK: - Window Registry & State
// Usamos el ViewRegistry estándar para los controles, pero las ventanas
// necesitan su propio manejo de NSWindow.

public class WindowRegistry {
    private static var windows: [String: NSWindow] = [:]
    
    public static func register(_ window: NSWindow, for id: String) {
        windows[id] = window
    }
    
    public static func get(_ id: String) -> NSWindow? {
        return windows[id]
    }
    
    public static func unregister(_ id: String) {
        windows.removeValue(forKey: id)
    }
}

// MARK: - SwiftUI Root View for TSwWindow
// Esta vista actuará como contenedor para los controles que añadamos desde Harbour

struct SwWindowRootView: View {
    let id: String
    @State private var childViews: [String: NSView] = [:]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(NSColor.windowBackgroundColor)
                .edgesIgnoringSafeArea(.all)
                
            // Aquí se renderizarán los "hijos" que se añadan dinámicamente
            // Pero como FiveMac usa coordenadas absolutas, lo más sencillo
            // es que la ventana sea un FlippedView de AppKit que decora a SwiftUI
            // o usar un Overlay de NSViewRepresentable.
        }
    }
}

// MARK: - Harbour Bridge

@HarbourDirect
public func sw_wnd_create(title: String, width: Double, height: Double, id: String) -> Int64 {
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)),
        styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
        backing: .buffered,
        defer: false
    )
    
    window.title = title
    window.center()
    window.isReleasedWhenClosed = false
    window.identifier = NSUserInterfaceItemIdentifier(id)
    
    // El contentView será un FlippedView para respetar las coordenadas (0,0) arriba
    let contentView = FlippedView(frame: window.contentRect(forFrameRect: window.frame))
    window.contentView = contentView
    
    WindowRegistry.register(window, for: id)
    
    return Int64(Int(bitPattern: Unmanaged.passRetained(window).toOpaque()))
}

@HarbourDirect
public func sw_wnd_add_child(windowId: String, childId: String) {
    guard let window = WindowRegistry.get(windowId),
          let childView = ViewRegistry.getObject(for: childId) as? NSView else {
        return 
    }
    
    if let contentView = window.contentView {
        contentView.addSubview(childView)
    }
}

@HarbourDirect
public func sw_wnd_show(id: String) {
    WindowRegistry.get(id)?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
}

@HarbourDirect
public func sw_wnd_destroy(id: String) {
    if let window = WindowRegistry.get(id) {
        window.close()
        WindowRegistry.unregister(id)
        ViewRegistry.clean(id: id)
    }
}
