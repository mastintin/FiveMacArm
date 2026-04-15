import SwiftUI

class SwWindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        print("SwiftWindow: Ventana cerrándose...")
    }
}

class SwAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        print("SwiftApp: Última ventana cerrada. Terminando proceso...")
        return true
    }
}

private let windowDelegate = SwWindowDelegate()
private let appDelegate = SwAppDelegate()

@_cdecl("HB_FUN_SW_CREATEWINDOW")
public func sw_createwindow_hb(_ p: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
    let title = hb_parc(1).map { String(cString: $0) } ?? "FiveMac SwiftUI"
    let width = hb_parni(2)
    let height = hb_parni(3)
    let windowId = hb_parc(4).map { String(cString: $0) } ?? UUID().uuidString
    
    print("SwiftWindow: Creando ventana \(windowId) - \(title) (\(width)x\(height))")
    
    let state = SwiftVStackState()
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
        window.delegate = windowDelegate
        window.makeKeyAndOrderFront(nil)
        
        // Save the window object in the registry so it doesn't get deallocated
        ViewRegistry.register(window, for: "NSWindow_\(windowId)")
    }
    
    return UnsafeMutableRawPointer(bitPattern: 1)
}

@_cdecl("HB_FUN_SW_ADD_WINDOW_ITEM")
public func sw_add_window_item_hb(_ p: UnsafeMutableRawPointer?) {
    // 1: windowId (C)
    // 2: itemId (C)
    // 3: top (N)
    // 4: left (N)
    // 5: width (N)
    // 6: height (N)
    // 7: type (N)
    // 8: content (C)
    
    let windowId = hb_parc(1).map { String(cString: $0) } ?? ""
    let itemId = hb_parc(2).map { String(cString: $0) } ?? ""
    let top = Int(hb_parni(3))
    let left = Int(hb_parni(4))
    let width = Int(hb_parni(5))
    let height = Int(hb_parni(6))
    let type = Int(hb_parni(7))
    let content = hb_parc(8).map { String(cString: $0) } ?? ""
    
    print("Bridge: Recibido Item \(itemId) - Tipo: \(type), Pos: (\(left), \(top)), Size: \(width)x\(height), Contenido: \(content)")
    
    let itype = StackItem.ItemType(rawValue: type) ?? .text
    let item = StackItem(type: itype, content: content, id: itemId)
    item.x = Double(left)
    item.y = Double(top)
    item.itemWidth = Double(width)
    item.itemHeight = Double(height)
    
    // Register globally for Action Stacking
    ViewRegistry.register(item, for: itemId)
    
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: windowId) as? SwiftVStackState {
            state.items.append(item)
            print("Bridge: Item \(itemId) añadido al estado de la ventana \(windowId)")
        } else {
            print("Bridge: Error - No se encontró el estado para la ventana \(windowId)")
        }
    }
}

@_cdecl("HB_FUN_SW_APPRUN")
public func sw_apprun_hb(_ p: UnsafeMutableRawPointer?) {
    print("SwiftApp: Iniciando NSApp.run()...")
    NSApp.setActivationPolicy(.regular)
    NSApp.delegate = appDelegate
    NSApp.activate(ignoringOtherApps: true)
    NSApp.run()
}
