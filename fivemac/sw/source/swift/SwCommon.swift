import SwiftUI
import AppKit
import Observation

// MARK: - Registry & State Protocols
public protocol RGBAColorableState: AnyObject {
    func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int)
    func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int)
}

public protocol StackStateProtocol: AnyObject {
    var items: [StackItem] { get set }
    var lastItem: StackItem? { get set }
}

public struct ColorRGBA: Codable {
    public let r, g, b, a: Int
}

public class ViewRegistry {
    private static var states: [String: Any] = [:]
    private static var views: [String: NSView] = [:]
    private static var itemRegistry: [String: StackItem] = [:]
    private static var parentIdMap: [String: String] = [:]

    public static func register(_ value: Any, for id: String) {
        let cleanId = id.lowercased()
        if let view = value as? NSView { views[cleanId] = view }
        else if let item = value as? StackItem { itemRegistry[cleanId] = item }
        else { states[cleanId] = value }
    }

    public static func get(_ id: String) -> Any? { 
        let cleanId = id.lowercased()
        return states[cleanId] ?? views[cleanId] ?? itemRegistry[cleanId] 
    }
    public static func getState(for id: String) -> Any? { states[id.lowercased()] }
    public static func getView(for id: String) -> NSView? { views[id.lowercased()] }
    public static func getItem(for id: String) -> StackItem? { itemRegistry[id.lowercased()] }

    public static func clean(id: String) { 
        let cleanId = id.lowercased()
        states.removeValue(forKey: cleanId)
        views.removeValue(forKey: cleanId)
        itemRegistry.removeValue(forKey: cleanId)
        parentIdMap.removeValue(forKey: cleanId)
    }

    public static func registerParent(id: String, parentId: String) {
        if !parentId.isEmpty {
            parentIdMap[id.lowercased()] = parentId.lowercased()
        }
    }

    public static func getParentId(for id: String) -> String? {
        return parentIdMap[id.lowercased()]
    }

    @MainActor
    public static func removeFromParent(id: String) {
        let cleanId = id.lowercased()
        guard let parentId = parentIdMap[cleanId] else { return }
        guard let parentState = states[parentId] as? StackStateProtocol else { return }
        
        print("ViewRegistry: Eliminando \(cleanId) de su padre \(parentId)")
        parentState.items.removeAll { $0.id.lowercased() == cleanId }
        if parentState.lastItem?.id.lowercased() == cleanId {
            parentState.lastItem = parentState.items.last
        }
    }

    public static func recursiveClean(id: String) -> [String] {
        let cleanId = id.lowercased()
        var cleanedIds: [String] = []
        
        // 1. Si es un item jerárquico, primero matamos a sus hijos
        if itemRegistry[cleanId] != nil {
            // Buscamos si el estado de este item tiene hijos
            if let state = states[cleanId] as? StackStateProtocol {
                for child in state.items {
                    cleanedIds.append(contentsOf: recursiveClean(id: child.id))
                }
            }
        }
        
        // 2. Si es una ventana, también matamos a sus hijos (items absolutos)
        if let windowState = states[cleanId] as? SwiftWindowState {
             for child in windowState.items {
                 cleanedIds.append(contentsOf: recursiveClean(id: child.id))
             }
             // Quitamos también la referencia a la NSWindow nativa si existe
             views.removeValue(forKey: "NSWindow_\(cleanId)")
        }

        // 3. Limpiamos el objeto actual y lo añadimos a la lista
        print("ViewRegistry: Limpieza recursiva de \(cleanId)")
        cleanedIds.append(cleanId)
        clean(id: cleanId)
        
        return cleanedIds
    }
}

// MARK: - Data Models
@Observable
public class StackItem: Identifiable {
    public enum ItemType: Int, Codable {
        case text = 0, vstack = 1, hstack = 2, scroll = 3, image = 4, spacer = 5, divider = 6, zstack = 7, list = 8, button = 9, toggle = 10, slider = 11, webview = 12, progress = 13, get = 14, aichat = 17
    }
    public let id: String
    public var type: ItemType
    public var x: Double?
    public var y: Double?
    public var itemWidth: Double?
    public var itemHeight: Double?
    public var resizemask: Int = 0
    public var initialParentSize: CGSize? = nil
    public var fgColor: ColorRGBA?
    public var hasscroll: Bool = false
    public var isInteractive: Bool = true
    
    public init(type: ItemType, id: String = UUID().uuidString) {
        self.type = type; self.id = id
    }
}

@Observable
public class SwiftVStackState: StackStateProtocol, RGBAColorableState, SwApplyable {
    public var items: [StackItem] = []
    public var lastItem: StackItem?
    public var scrollable: Bool = true
    public init() {}
    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {}
    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {}
    
    public func apply(property: String, value: Any) {
        // Implementación base para propiedades genéricas si es necesario
    }
}

@Observable
public class ImageState: SwApplyable, RGBAColorableState {
    public let id: String
    public var systemName: String = ""
    public var filePath: String = ""
    public var urlStr: String = ""
    public var resizable: Bool = true
    public var contentMode: Int = 0 // 0: fit, 1: fill
    public var foregroundColor: Color = .primary
    public var cornerRadius: CGFloat = 0
    public var shadowRadius: CGFloat = 0
    public var shadowColor: Color = .black.opacity(0.3)
    public var borderWidth: CGFloat = 0
    public var borderColor: Color = .clear
    public var qrText: String = ""
    public var qrScale: Double = 1.0
    public var scaling: Int = 0 // 0: ProportionalDown, 1: AxesIndependently, 2: None, 3: UpOrDown
    public var frameStyle: Int = 0 // 0: None, 1: Photo, 2: GrayBezel, 3: Groove, 4: Button
    
    public init(id: String, systemName: String = "", filePath: String = "", url: String = "") {
        self.id = id
        self.systemName = systemName
        self.filePath = filePath
        self.urlStr = url
    }
    
    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {}
    
    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        DispatchQueue.main.async {
            self.foregroundColor = Color(r: r, g: g, b: b, a: a)
        }
    }
    
    public func apply(property: String, value: Any) {
        let prop = property.lowercased()
        switch prop {
        case "systemname":
            if let s = value as? String { 
                DispatchQueue.main.async {
                    self.systemName = s
                    self.filePath = ""
                    self.urlStr = ""
                }
            }
        case "file":
            if let s = value as? String {
                DispatchQueue.main.async {
                    self.filePath = s
                    self.systemName = ""
                    self.urlStr = ""
                }
            }
        case "url":
            if let s = value as? String {
                DispatchQueue.main.async {
                    self.urlStr = s
                    self.systemName = ""
                    self.filePath = ""
                }
            }
        case "mode":
            if let i = value as? Int { self.contentMode = i }
        case "resizable":
            if let b = value as? Bool { self.resizable = b }
        case "color":
            if let s = value as? String {
                DispatchQueue.main.async { self.foregroundColor = Color(hex: s) }
            }
        case "corner", "cornerradius":
            if let n = (value as? NSNumber)?.doubleValue { self.cornerRadius = CGFloat(n) }
        case "shadow", "shadowradius":
            if let n = (value as? NSNumber)?.doubleValue { self.shadowRadius = CGFloat(n) }
        case "shadowcolor":
            if let s = value as? String { self.shadowColor = Color(hex: s) }
        case "borderwidth":
            if let n = (value as? NSNumber)?.doubleValue { self.borderWidth = CGFloat(n) }
        case "bordercolor":
            if let s = value as? String {
                DispatchQueue.main.async { self.borderColor = Color(hex: s) }
            }
        case "scaling":
            if let i = value as? Int { self.scaling = i }
        case "frame":
            if let i = value as? Int { self.frameStyle = i }
        case "qr":
            if let s = value as? String { 
                self.qrText = s
                self.systemName = ""
                self.filePath = ""
                self.urlStr = ""
            }
        case "qrscale":
            if let n = (value as? NSNumber)?.doubleValue { self.qrScale = n }
        default:
            break
        }
    }
}

@Observable
public class SwiftWindowState: SwiftVStackState {
    public var windowId: String = ""
    public var isInteractive: Bool = true
    public var backgroundColor: AnyShapeStyle? = nil
    
    public init(id: String) {
        self.windowId = id
        super.init()
    }
    
    public override func apply(property: String, value: Any) {
        let prop = property.lowercased()
        print("🏝️ [Swift-Window] ID: \(self.windowId), Prop: \(prop), Val: \(value)")
        
        DispatchQueue.main.async {
            self.windowId = self.windowId.lowercased() 
            if prop == "interactive", let v = value as? Bool {
                self.isInteractive = v
            } else if prop == "backcolor" {
                if let sVal = value as? String {
                    if sVal.hasPrefix(".gradient") {
                        self.backgroundColor = parseGradient(sVal)
                    } else {
                        self.backgroundColor = AnyShapeStyle(Color(hex: sVal))
                    }
                }
            }

            if let win = ViewRegistry.get("NSWindow_\(self.windowId)") as? NSWindow {
                if prop == "title", let v = value as? String {
                    win.title = v
                } else if prop == "center" {
                    win.center()
                } else if prop == "modal", let v = value as? Bool {
                    if v { win.level = .modalPanel }
                } else if prop == "visible" && (value as? Bool == true || (value as? Int == 1)) {
                    win.makeKeyAndOrderFront(nil)
                    NSApp.activate(ignoringOtherApps: true)
                } else if prop == "close" {
                    win.close()
                }
            }
        }
    }
}

public func parseGradient(_ s: String) -> AnyShapeStyle? {
    let low = s.lowercased()
    guard low.hasPrefix(".gradient("), low.hasSuffix(")") else { return nil }
    let colorsStr = low.replacingOccurrences(of: ".gradient(", with: "")
                       .replacingOccurrences(of: ")", with: "")
    let parts = colorsStr.split(separator: ",")
    var colors: [Color] = []
    for part in parts {
        let p = part.trimmingCharacters(in: .whitespaces)
        if p.hasPrefix("#") { colors.append(Color(hex: p)) }
        else if p.hasPrefix(".") { colors.append(mapBaseColor(p)) }
    }
    if colors.count >= 2 {
        return AnyShapeStyle(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    return nil
}

public func mapMaterial(_ s: String) -> AnyShapeStyle? {
    switch s.lowercased() {
    case ".ultrathin": return AnyShapeStyle(.ultraThinMaterial)
    case ".thin": return AnyShapeStyle(.thinMaterial)
    case ".regular": return AnyShapeStyle(.regularMaterial)
    case ".thick": return AnyShapeStyle(.thickMaterial)
    case ".ultrathick": return AnyShapeStyle(.ultraThickMaterial)
    default: return nil
    }
}

public func mapColorStyle(_ s: String) -> AnyShapeStyle {
    if let grad = parseGradient(s) { return grad }
    
    switch s.lowercased() {
    case ".primary": return AnyShapeStyle(.primary)
    case ".secondary": return AnyShapeStyle(.secondary)
    case ".tertiary": return AnyShapeStyle(.tertiary)
    case ".quaternary": return AnyShapeStyle(.quaternary)
    case ".accent": return AnyShapeStyle(Color.accentColor)
    case ".blue": return AnyShapeStyle(Color.blue)
    case ".red": return AnyShapeStyle(Color.red)
    case ".green": return AnyShapeStyle(Color.green)
    case ".orange": return AnyShapeStyle(Color.orange)
    case ".pink": return AnyShapeStyle(Color.pink)
    case ".purple": return AnyShapeStyle(Color.purple)
    case ".yellow": return AnyShapeStyle(Color.yellow)
    case ".gray": return AnyShapeStyle(Color.gray)
    case ".black": return AnyShapeStyle(Color.black)
    case ".white": return AnyShapeStyle(Color.white)
    default: return AnyShapeStyle(.primary)
    }
}

public func mapBaseColor(_ s: String) -> Color {
    switch s.lowercased() {
    case ".blue": return .blue
    case ".purple": return .purple
    case ".pink": return .pink
    case ".orange": return .orange
    case ".red": return .red
    case ".white": return .white
    case ".black": return .black
    default: return .white
    }
}



// MARK: - Layout Utilities
public func applySwiftViewLayout(swiftView: NSView, parent: NSObject, top: Double, left: Double, w: Double, h: Double) {
    let targetView: NSView? = (parent as? NSWindow)?.contentView ?? (parent as? NSView)
    guard let contentView = targetView else { return }
    swiftView.frame = NSRect(x: CGFloat(left), y: CGFloat(top), width: CGFloat(w), height: CGFloat(h))
    contentView.addSubview(swiftView)
    swiftView.translatesAutoresizingMaskIntoConstraints = true
    swiftView.autoresizingMask = [.maxXMargin, .minYMargin]
}

// MARK: - Bridge
public struct SwiftBridge {
    public static func onAction(_ id: String) {
        let json = "{\"\(id)\":{\"event\":\"click\"}}"
        Harbour.call("SW_UPDATE_HB", json)
    }
    
    public static func onChange(_ id: String, _ value: String) {
        let json = "{\"\(id)\":{\"text\":\"\(value)\"}}"
        Harbour.call("SW_UPDATE_HB", json)
    }
    
    public static func onValid(_ id: String, _ value: String) {
        let json = "{\"\(id)\":{\"text\":\"\(value)\",\"event\":\"valid\"}}"
        Harbour.call("SW_UPDATE_HB", json)
    }
}

// MARK: - Colors
extension Color {
    public init(rgba: ColorRGBA) { self.init(red: Double(rgba.r)/255, green: Double(rgba.g)/255, blue: Double(rgba.b)/255, opacity: Double(rgba.a)/255) }
    public init(r: Int, g: Int, b: Int, a: Int) { self.init(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255) }
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
