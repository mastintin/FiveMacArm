import SwiftUI
import AppKit

class SwWindowDelegate: NSObject, NSWindowDelegate, NSToolbarDelegate {
    let windowId: String
    var customButtons: [ToolbarItemConfig] = []
    
    init(windowId: String) {
        self.windowId = windowId
    }

    // --- Métodos del Toolbar (Protocolo NSToolbarDelegate) ---
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return customButtons.map { NSToolbarItem.Identifier($0.id ?? "") } + [.flexibleSpace, .space]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return customButtons.map { NSToolbarItem.Identifier($0.id ?? "") }
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        // Buscamos la configuración que coincida con el ID del botón
        guard let config = customButtons.first(where: { ($0.id ?? "") == itemIdentifier.rawValue }) else { return nil }
        
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = config.label ?? ""
        item.paletteLabel = config.label ?? ""
        
        // Cargamos el icono de SFSymbols o un interrogante si falla el nombre
        item.image = NSImage(systemSymbolName: config.icon ?? "questionmark", accessibilityDescription: nil)
        
        item.target = self
        item.action = #selector(toolbarAction(_:))
        
        return item
    }
    
    @objc func toolbarAction(_ sender: NSToolbarItem) {
        // Notifica a Harbour qué botón se pulsó mediante el sistema SW_UPDATE_HB
        // Formato para que lo reciba la ventana: {"WINDOW_ID": {"event": "toolbar", "item": "ITEM_ID"}}
        let itemId = sender.itemIdentifier.rawValue
        let json = "{\"\(windowId)\": {\"event\": \"toolbar\", \"item\": \"\(itemId)\"}}"
        print("🏝️ [Swift-Toolbar] Click detectado: \(itemId). Enviando: \(json)")
        DispatchQueue.global().async {
            Harbour.call("SW_UPDATE_HB", json)
        }
    }

    // --- Gestión de Cierre ---
    func windowWillClose(_ notification: Notification) {
        print("SwiftWindow: Ventana \(windowId) cerrándose...")
        
        let deadIds = ViewRegistry.recursiveClean(id: windowId)
        let idsJson = deadIds.map { "\"\($0)\"" }.joined(separator: ", ")
        let json = "{\"_system\":{\"unregister\":[\(idsJson)]}}"
        
        DispatchQueue.global().async {
            Harbour.call("SW_UPDATE_HB", json)
        }
    } 
}

@_cdecl("HB_FUN_SW_PROCESSEVENTS")
public func sw_processevents_hb(_ p: UnsafeMutableRawPointer?) {
    // Permite que el RunLoop respire para procesar eventos de la interfaz
    let next = Date(timeIntervalSinceNow: 0.001)
    RunLoop.current.run(mode: .default, before: next)
}

// --- MOTOR UNIFICADO DE CREACIÓN ---
@MainActor
public func sw_createwindow_hb_internal(title: String,
                                        width: Double,
                                        height: Double,
                                        id: String,
                                        hastoolbar: Bool = false,
                                        buttons: [ToolbarItemConfig] = []) {

    // 1. Registro del Estado
    let windowState = SwiftWindowState(id: id)
    ViewRegistry.register(windowState, for: id)
    
    // 2. Creación de la Ventana física (AppKit)
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

    // 3. Configuración del Delegado Único
    let delegate = SwWindowDelegate(windowId: id)
    delegate.customButtons = buttons 

    // 4. Configuración del Toolbar (si se solicita en el JSON)
    if hastoolbar {
        let toolbar = NSToolbar(identifier: "Toolbar_\(id)")
        toolbar.delegate = delegate
        toolbar.displayMode = .iconAndLabel
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = false
        window.toolbar = toolbar
    } 

    // 5. Vincular y Registrar Delegado
    window.delegate = delegate
    ViewRegistry.register(delegate, for: "Delegate_\(id)")

    // 6. Inyección de la vista SwiftUI mediante NSHostingView
    let hostingView = NSHostingView(rootView: windowView)
    hostingView.frame = NSRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
    hostingView.autoresizingMask = [.width, .height]
    hostingView.layer?.backgroundColor = NSColor.clear.cgColor
    window.contentView = hostingView
    
    // 7. Registro de la Ventana para acceso posterior
    ViewRegistry.register(window, for: "NSWindow_\(id)")
    
    print("SwiftWindow: Ventana \(id) ['\(title)'] creada con \(buttons.count) botones.")
}
