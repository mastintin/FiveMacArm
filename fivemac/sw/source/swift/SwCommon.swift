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
    }
}

// MARK: - Data Models
@Observable
public class StackItem: Identifiable {
    public enum ItemType: Int, Codable {
        case text = 0, vstack = 1, hstack = 2, scroll = 3, image = 4, spacer = 5, divider = 6, zstack = 7, list = 8, button = 9, toggle = 10, slider = 11, webview = 12, aichat = 17
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
    
    public init(type: ItemType, id: String = UUID().uuidString) {
        self.type = type; self.id = id
    }
}

@Observable
public class SwiftVStackState: StackStateProtocol, RGBAColorableState {
    public var items: [StackItem] = []
    public var lastItem: StackItem?
    public var scrollable: Bool = true
    public init() {}
    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {}
    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {}
}

@Observable
public class SwiftWindowState: SwiftVStackState, SwApplyable {
    public var windowId: String = ""
    
    public init(id: String) {
        self.windowId = id
        super.init()
    }
    
    public func apply(property: String, value: Any) {
        let prop = property.lowercased()
        DispatchQueue.main.async {
            if let win = ViewRegistry.get("NSWindow_\(self.windowId)") as? NSWindow {
                if prop == "title", let v = value as? String {
                    win.title = v
                } else if prop == "center" {
                    win.center()
                } else if prop == "close" {
                    win.close()
                }
            }
        }
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
        "SW_ONACTION".withCString { ptr in
            if let ds = hb_dynsymFindName(ptr), let sym = hb_dynsymSymbol(ds) {
                hb_vmPushSymbol(sym); hb_vmPushNil(); hb_vmPushString(id, -1); hb_vmDo(1)
            }
        }
    }
}

// MARK: - Colors
extension Color {
    init(rgba: ColorRGBA) { self.init(red: Double(rgba.r)/255, green: Double(rgba.g)/255, blue: Double(rgba.b)/255, opacity: Double(rgba.a)/255) }
    init(r: Int, g: Int, b: Int, a: Int) { self.init(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255) }
    init(hex: String) {
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
