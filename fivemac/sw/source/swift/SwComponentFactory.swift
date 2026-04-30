import Foundation
import SwiftUI

// MARK: - Hierarchical Universal Component Factory

@MainActor
public func sw_component_create_internal(id: String, typeId: Int, jsonStr: String, parentid: String) {
    let jsonData = jsonStr.data(using: .utf8) ?? Data()
    let decoder = JSONDecoder()
    let cleanid = id.lowercased()
    let cleanParentId = parentid.lowercased()
    
    print("🏝️ Swift: Received Create Component - ID: \(cleanid), Type: \(typeId), Parent: \(cleanParentId)")
    
    // Safety check: Don't recreate if it already exists
    if ViewRegistry.get(cleanid) != nil && typeId != 100 { 
        print("SwFactory: [SKIP] El ID \(cleanid) ya existe. Ignorando recreación.")
        return 
    }
    
    var newItem: StackItem? = nil
    
    do {
        switch typeId {
        case 0: // Label
            newItem = try SwiftLabelView.create(id: cleanid, from: jsonData)

        case 1, 2, 3, 24: // Stacks
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            newItem = createStack(id: cleanid, typeId: typeId, initial: initial)

        case 7: // Image
            let initial = try decoder.decode(ImageInit.self, from: jsonData)
            newItem = createImage(id: cleanid, initial: initial)

        case 8: // List
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            newItem = SwiftListView.create(id: cleanid, initial: initial)

        case 9: // Button
            newItem = try SwiftButtonView.create(id: cleanid, from: jsonData)
            
        case 10: // Toggle
            newItem = try SwiftToggleView.create(id: cleanid, from: jsonData)

        case 11: // Slider
            newItem = try SwiftSliderView.create(id: cleanid, from: jsonData)

        case 12: // WebView
            newItem = try SwiftWebView.create(id: cleanid, from: jsonData)

        case 13: // Progress
            newItem = try SwiftProgressView.create(id: cleanid, from: jsonData)

        case 100: // Window
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            sw_createwindow_hb_internal(title: initial.title ?? "", 
                                         width: initial.width ?? 500, 
                                         height: initial.height ?? 400, 
                                         id: cleanid)

        case 14: // Get
            newItem = try SwiftGetView.create(id: cleanid, from: jsonData)

        case 15: // DatePicker
            newItem = try SwiftDatePickerView.create(id: cleanid, from: jsonData)

        case 16: // Grid
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            newItem = SwiftGridView.create(id: cleanid, initial: initial)

        case 18: // Picker
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            newItem = SwiftPickerView.create(id: cleanid, initial: initial)

        case 20: // Panel
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            newItem = SwiftPanelView.create(id: cleanid, initial: initial)

        case 21: // Sidebar
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            newItem = SwSidebarView.create(id: cleanid, initial: initial)

        case 22: // SidebarItem
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            newItem = SwSidebarItemView.create(id: cleanid, initial: initial)

            
        case 23: // TabView
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            newItem = SwiftTabView.create(id: cleanid, initial: initial)
            
        case 25: // Menu
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            newItem = SwiftMenuView.create(id: cleanid, initial: initial)

        case 26: // MenuItem
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            newItem = SwiftMenuItemView.create(id: cleanid, initial: initial)
            
        case 110: // AppMenu
            SwAppMenu.setup(from: jsonData)
            
        default:
            print("SwFactory: [AVISO] Tipo de componente \(typeId) no implementado.")
        }
    } catch {
        print("SwFactory: [ERROR] ❌ Error decodificando component \(typeId): \(error)")
        print("SwFactory: [DEBUG] JSON recibido: \(jsonStr)")
    }
    
    // Procesamiento de Jerarquía
    if let item = newItem {
        ViewRegistry.register(item, for: cleanid)
        if !cleanParentId.isEmpty {
            if let parentState = ViewRegistry.getState(for: cleanParentId) as? StackStateProtocol {
                ViewRegistry.registerParent(id: cleanid, parentId: cleanParentId)
                parentState.items.append(item)
                parentState.lastItem = item
                print("SwFactory: [JERARQUÍA] ✅ Añadido \(cleanid) al padre [\(cleanParentId)]. Total items en padre: \(parentState.items.count)")
            } else {
                print("SwFactory: [ERROR] ❌ No se encontró el padre o no es un contenedor válido: \(cleanParentId)")
                // Si no se encuentra el padre, por seguridad lo añadimos a la última ventana activa?
                // No, mejor dejarlo huérfano para ver el error en el log.
            }
        } else {
            print("SwFactory: [AVISO] ⚠️ Componente \(cleanid) creado sin parentid.")
        }
    }
}

// MARK: - Component Specific Creators (Desacoplados para ayudar al compilador)


@MainActor private func createStack(id: String, typeId: Int, initial: GenericInit) -> StackItem {
    let state = SwiftVStackState()
    ViewRegistry.register(state, for: id)
    let stackType: StackItem.ItemType = (typeId == 1) ? .vstack : (typeId == 2 ? .hstack : .zstack)
    let item = StackItem(type: stackType, id: id)
    setupGeometry(item: item, from: initial)
    return item
}

@MainActor private func createImage(id: String, initial: ImageInit) -> StackItem {
    let state = ImageState(id: id, 
                           systemName: initial.systemname ?? "", 
                           filePath: initial.file ?? "",
                           url: initial.url ?? "")
    ViewRegistry.register(state, for: id)
    let item = StackItem(type: .image, id: id)
    setupGeometry(item: item, from: initial)
    return item
}

// MARK: - Geometry & Protocols

func setupGeometry(item: StackItem, from config: GeometryProtocol) {
    item.itemWidth = config.width ?? 100
    item.itemHeight = config.height ?? 30
    item.x = config.left ?? 0
    item.y = config.top ?? 0
    item.resizemask = config.resizemask ?? 0
    
    // El initialParentSize debe venir del padre real enviado desde Harbour
    if let pw = config.parentwidth, let ph = config.parentheight {
        item.initialParentSize = CGSize(width: pw, height: ph)
    } else {
        // Fallback: Si no hay padre, usamos un tamaño razonable para evitar saltos
        item.initialParentSize = CGSize(width: config.width ?? 800, height: config.height ?? 600)
    }
}

public protocol GeometryProtocol {
    var width: Double? { get }
    var height: Double? { get }
    var top: Double? { get }
    var left: Double? { get }
    var resizemask: Int? { get }
    var parentwidth: Double? { get }
    var parentheight: Double? { get }
    var interactive: Int? { get }
    var style: Int? { get }
}

extension GeometryProtocol {
    public var interactive: Int? { return nil }
    public var style: Int? { return nil }
}

public struct GenericInit: Codable, GeometryProtocol {
    public let title: String?
    public let caption: String?
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
    public let resizemask: Int?
    public let parentwidth: Double?
    public let parentheight: Double?
    public let interactive: Int?
    public let style: Int?
}

