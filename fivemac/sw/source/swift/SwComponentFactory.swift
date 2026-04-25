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
            let initial = try decoder.decode(LabelInit.self, from: jsonData)
            newItem = createLabel(id: cleanid, initial: initial)

        case 1, 2, 3: // Stacks
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            newItem = createStack(id: cleanid, typeId: typeId, initial: initial)

        case 7: // Image
            let initial = try decoder.decode(ImageInit.self, from: jsonData)
            newItem = createImage(id: cleanid, initial: initial)

        case 8: // List
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            newItem = createList(id: cleanid, initial: initial)

        case 9: // Button
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            newItem = createButton(id: cleanid, initial: initial)
            
        case 10: // Toggle
            let initial = try decoder.decode(ToggleInit.self, from: jsonData)
            newItem = createToggle(id: cleanid, initial: initial)

        case 11: // Slider
            let initial = try decoder.decode(SliderInit.self, from: jsonData)
            newItem = createSlider(id: cleanid, initial: initial)

        case 12: // WebView
            let initial = try decoder.decode(WebViewInit.self, from: jsonData)
            newItem = createWebView(id: cleanid, initial: initial)

        case 13: // Progress
            let initial = try decoder.decode(ProgressInit.self, from: jsonData)
            newItem = createProgress(id: cleanid, initial: initial)

        case 100: // Window
            let initial = try decoder.decode(GenericInit.self, from: jsonData)
            sw_createwindow_hb_internal(title: initial.title ?? "", 
                                        width: initial.width ?? 500, 
                                        height: initial.height ?? 400, 
                                        id: cleanid)

        case 14: // Get
            let initial = try decoder.decode(GetInit.self, from: jsonData)
            newItem = createGet(id: cleanid, initial: initial)

        default:
            print("SwFactory: [AVISO] Tipo de componente \(typeId) no implementado.")
        }
    } catch {
        print("SwFactory: [ERROR] Error decodificando component \(typeId): \(error)")
    }
    
    // Procesamiento de Jerarquía
    if let item = newItem {
        ViewRegistry.register(item, for: cleanid)
        if !cleanParentId.isEmpty {
            if let parentState = ViewRegistry.getState(for: cleanParentId) as? StackStateProtocol {
                ViewRegistry.registerParent(id: cleanid, parentId: cleanParentId)
                parentState.items.append(item)
                parentState.lastItem = item
                print("SwFactory: [JERARQUÍA] Añadido \(cleanid) al padre [\(cleanParentId)]. Total: \(parentState.items.count)")
            } else {
                print("SwFactory: [ERROR] No se encontró el padre o no es un contenedor: \(cleanParentId)")
            }
        }
    }
}

// MARK: - Component Specific Creators (Desacoplados para ayudar al compilador)

@MainActor private func createLabel(id: String, initial: LabelInit) -> StackItem {
    let state = LabelState(id: id, text: initial.text ?? "")
    ViewRegistry.register(state, for: id)
    let item = StackItem(type: .text, id: id)
    setupGeometry(item: item, from: initial)
    return item
}

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

@MainActor private func createList(id: String, initial: GenericInit) -> StackItem {
    let state = ListState(id: id)
    ViewRegistry.register(state, for: id)
    let item = StackItem(type: .list, id: id)
    setupGeometry(item: item, from: initial)
    return item
}

@MainActor private func createButton(id: String, initial: GenericInit) -> StackItem {
    let state = ButtonState(id: id, caption: initial.caption ?? initial.title ?? "")
    ViewRegistry.register(state, for: id)
    let item = StackItem(type: .button, id: id)
    setupGeometry(item: item, from: initial)
    return item
}

@MainActor private func createToggle(id: String, initial: ToggleInit) -> StackItem {
    let state = ToggleState(id: id, isOn: initial.value ?? false, prompt: initial.prompt ?? "")
    state.isSwitch = initial.isswitch ?? false
    ViewRegistry.register(state, for: id)
    let item = StackItem(type: .toggle, id: id)
    setupGeometry(item: item, from: initial)
    return item
}

@MainActor private func createSlider(id: String, initial: SliderInit) -> StackItem {
    let state = SliderState(id: id, 
                           value: initial.value ?? 0.0,
                           min: initial.min ?? 0.0,
                           max: initial.max ?? 100.0,
                           showValue: initial.showvalue ?? true)
    ViewRegistry.register(state, for: id)
    let item = StackItem(type: .slider, id: id)
    setupGeometry(item: item, from: initial)
    return item
}

@MainActor private func createProgress(id: String, initial: ProgressInit) -> StackItem {
    let state = ProgressState(id: id, 
                             value: initial.value ?? 0.0,
                             min: initial.min ?? 0.0,
                             max: initial.max ?? 100.0)
    ViewRegistry.register(state, for: id)
    let item = StackItem(type: .progress, id: id)
    setupGeometry(item: item, from: initial)
    return item
}

@MainActor private func createWebView(id: String, initial: WebViewInit) -> StackItem {
    let state = WebViewState(id: id)
    if let urlStr = initial.url { state.apply(property: "url", value: urlStr) }
    ViewRegistry.register(state, for: id)
    let item = StackItem(type: .webview, id: id)
    setupGeometry(item: item, from: initial)
    return item
}

@MainActor private func createGet(id: String, initial: GetInit) -> StackItem {
    let state = GetState(id: id, 
                         text: initial.text ?? "", 
                         picture: initial.picture ?? "", 
                         placeholder: initial.placeholder ?? "", 
                         issecure: initial.issecure ?? false)
    ViewRegistry.register(state, for: id)
    let item = StackItem(type: .get, id: id)
    setupGeometry(item: item, from: initial)
    return item
}

// MARK: - Geometry & Protocols

private func setupGeometry(item: StackItem, from config: GeometryProtocol) {
    item.itemWidth = config.width ?? 100
    item.itemHeight = config.height ?? 30
    item.x = config.left ?? 0
    item.y = config.top ?? 0
    item.resizemask = config.resizemask ?? 0
    
    if let w = config.width, let h = config.height {
        item.initialParentSize = CGSize(width: w, height: h)
    }
}

public protocol GeometryProtocol {
    var width: Double? { get }
    var height: Double? { get }
    var top: Double? { get }
    var left: Double? { get }
    var resizemask: Int? { get }
}

public struct GenericInit: Codable, GeometryProtocol {
    public let title: String?
    public let caption: String?
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
    public let resizemask: Int?
}

public struct ImageInit: Codable, GeometryProtocol {
    public let systemname: String?
    public let file: String?
    public let url: String?
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
    public let resizemask: Int?
}

// MARK: - Conformance Extensions (Para tipos externos definidos en otros archivos)

extension LabelInit: GeometryProtocol {}
extension ToggleInit: GeometryProtocol {}
extension SliderInit: GeometryProtocol {}
extension WebViewInit: GeometryProtocol {}
extension ProgressInit: GeometryProtocol {}
extension GetInit: GeometryProtocol {}
