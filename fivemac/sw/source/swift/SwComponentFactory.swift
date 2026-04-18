import Foundation
import SwiftUI

// MARK: - Hierarchical Universal Component Factory
// SW_COMPONENT_CREATE( id, typeId, jsonStr, parentId )
@_cdecl("HB_FUN_SW_COMPONENT_CREATE")
public func sw_component_create_hb(_ p: UnsafeMutableRawPointer?) {
    let id = hb_parc(1).map { String(cString: $0) } ?? UUID().uuidString
    let typeId = Int(hb_parni(2))
    let jsonStr = hb_parc(3).map { String(cString: $0) } ?? "{}"
    let parentId = hb_parc(4).map { String(cString: $0) } ?? ""
    
    Task { @MainActor in
        sw_component_create_internal(id: id, typeId: typeId, jsonStr: jsonStr, parentId: parentId)
    }
}

@MainActor
public func sw_component_create_internal(id: String, typeId: Int, jsonStr: String, parentId: String) {
    let jsonData = jsonStr.data(using: .utf8) ?? Data()
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    // Safety check: Don't recreate if it already exists
    if ViewRegistry.getState(for: id) != nil { return }
    
    var newItem: StackItem? = nil
    
    switch typeId {
    case 0: // Label
        if let initial = try? decoder.decode(LabelInit.self, from: jsonData) {
            let state = LabelState(id: id, text: initial.text ?? "")
            ViewRegistry.register(state, for: id)
            newItem = StackItem(type: .text, id: id)
            setupGeometry(item: newItem!, from: initial)
        }

    case 1: // VStack (Container)
        let state = SwiftVStackState()
        ViewRegistry.register(state, for: id)
        newItem = StackItem(type: .vstack, id: id)
        if let initial = try? decoder.decode(GenericInit.self, from: jsonData) {
            setupGeometry(item: newItem!, from: initial)
        }

    case 2: // HStack (Container)
        let state = SwiftVStackState() 
        ViewRegistry.register(state, for: id)
        newItem = StackItem(type: .hstack, id: id)
        if let initial = try? decoder.decode(GenericInit.self, from: jsonData) {
            setupGeometry(item: newItem!, from: initial)
        }

    case 4: // Image
        if let initial = try? decoder.decode(ImageInit.self, from: jsonData) {
            let state = ImageState(id: id, 
                                   systemName: initial.symbol ?? "",
                                   filePath: initial.file ?? "",
                                   url: initial.url ?? "")
            ViewRegistry.register(state, for: id)
            newItem = StackItem(type: .image, id: id)
            setupGeometry(item: newItem!, from: initial)
        }

    case 8: // List
        if let initial = try? decoder.decode(ListInit.self, from: jsonData) {
            let state = ListState(id: id)
            ViewRegistry.register(state, for: id)
            newItem = StackItem(type: .list, id: id)
            setupGeometry(item: newItem!, from: initial)
        }

    case 9: // Button
        if let initial = try? decoder.decode(ButtonInit.self, from: jsonData) {
            let state = ButtonState(id: id, caption: initial.caption ?? "")
            ViewRegistry.register(state, for: id)
            newItem = StackItem(type: .button, id: id)
            setupGeometry(item: newItem!, from: initial)
        }
        
    case 10: // Toggle
        if let initial = try? decoder.decode(ToggleInit.self, from: jsonData) {
            let state = ToggleState(id: id, isOn: initial.value ?? false, prompt: initial.prompt ?? "")
            state.isSwitch = initial.isSwitch ?? false
            ViewRegistry.register(state, for: id)
            newItem = StackItem(type: .toggle, id: id)
            setupGeometry(item: newItem!, from: initial)
        }

    case 11: // Slider
        if let initial = try? decoder.decode(SliderInit.self, from: jsonData) {
            let state = SliderState(id: id, 
                                 value: initial.value ?? 0, 
                                 min: initial.min ?? 0, 
                                 max: initial.max ?? 100, 
                                 showValue: initial.showValue ?? true)
            ViewRegistry.register(state, for: id)
            newItem = StackItem(type: .slider, id: id)
            setupGeometry(item: newItem!, from: initial)
        }

    case 12: // WebView
        if let initial = try? decoder.decode(WebViewInit.self, from: jsonData) {
            let state = WebViewState(id: id)
            if let urlStr = initial.url { state.url = URL(string: urlStr) }
            state.html = initial.html
            ViewRegistry.register(state, for: id)
            newItem = StackItem(type: .webview, id: id)
            setupGeometry(item: newItem!, from: initial)
        }

    case 14: // Get (TextField with Pictures)
        if let initial = try? decoder.decode(GetInit.self, from: jsonData) {
            let state = GetState(id: id, 
                               text: initial.text ?? "", 
                               picture: initial.picture ?? "", 
                               placeholder: initial.placeholder ?? "", 
                               issecure: initial.issecure ?? false)
            ViewRegistry.register(state, for: id)
            newItem = StackItem(type: .get, id: id)
            setupGeometry(item: newItem!, from: initial)
        }

    case 100: // Window (Special Root Component)
        if let initial = try? decoder.decode(GenericInit.self, from: jsonData) {
            // Llamamos a la lógica física de creación de ventana que ya tenemos
            sw_createwindow_hb_internal(title: initial.title ?? "", 
                                        width: initial.width ?? 500, 
                                        height: initial.height ?? 400, 
                                        id: id)
            // No creamos StackItem porque la ventana es el contenedor raíz nativo
        }
        
    default:
        print("SwComponentFactory: Tipo \(typeId) no implementado aún en el factory unificado.")
        return
    }
    
    // --- Jerarquía: Registramos el hijo en el padre ---
    if let item = newItem {
        ViewRegistry.register(item, for: id)
        
        if !parentId.isEmpty {
            print("SwFactory: Intentando añadir hijo \(id) al padre \(parentId)")
            ViewRegistry.registerParent(id: id, parentId: parentId)
            if let parentState = ViewRegistry.getState(for: parentId) as? StackStateProtocol {
                parentState.items.append(item)
                parentState.lastItem = item
                print("SwFactory: Hijo \(id) añadido con éxito a la lista de items del padre.")
            } else {
                print("SwFactory: Error - El padre con ID \(parentId) NO encontrado o no soporta hijos en el registro.")
            }
        }
    }
}

// MARK: - Geometry Helpers
private func setupGeometry(item: StackItem, from initial: Any) {
    if let initObj = initial as? GeometryProtocol {
        item.itemWidth = initObj.width ?? 100
        item.itemHeight = initObj.height ?? 30
        item.x = initObj.left ?? 0
        item.y = initObj.top ?? 0
        item.resizemask = initObj.resizemask ?? 0
        item.hasscroll = initObj.hasscroll ?? false
    }
}

protocol GeometryProtocol {
    var title: String? { get }
    var width: Double? { get }
    var height: Double? { get }
    var top: Double? { get }
    var left: Double? { get }
    var resizemask: Int? { get }
    var hasscroll: Bool? { get }
}

extension GeometryProtocol {
    public var title: String? { return nil }
    public var width: Double? { return nil }
    public var height: Double? { return nil }
    public var top: Double? { return nil }
    public var left: Double? { return nil }
    public var resizemask: Int? { return nil }
    public var hasscroll: Bool? { return nil }
}

extension LabelInit: GeometryProtocol {}
extension ListInit: GeometryProtocol {}
extension ButtonInit: GeometryProtocol {}
extension ToggleInit: GeometryProtocol {}
extension SliderInit: GeometryProtocol {}
extension WebViewInit: GeometryProtocol {}

struct GenericInit: Codable, GeometryProtocol {
    let title: String?
    let width: Double?
    let height: Double?
    let top: Double?
    let left: Double?
    let resizemask: Int?
    let hasscroll: Bool?
}

struct GetInit: Codable, GeometryProtocol {
    let text: String?
    let picture: String?
    let placeholder: String?
    let issecure: Bool?
    let width: Double?
    let height: Double?
    let top: Double?
    let left: Double?
    let resizemask: Int?
    let hasscroll: Bool?
}

struct ImageInit: Codable, GeometryProtocol {
    let symbol: String?
    let file: String?
    let url: String?
    let width: Double?
    let height: Double?
    let top: Double?
    let left: Double?
    let resizemask: Int?
    let hasscroll: Bool?
}
