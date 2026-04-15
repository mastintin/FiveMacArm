import SwiftUI
import HarbourMacro

// MARK: - Independent Stack Model for 'sw'
@Observable
public class SwStackItem: Identifiable {
    public var id: String
    public var type: ItemType
    public var content: String
    public var x: Double = 0
    public var y: Double = 0
    public var width: Double = 100
    public var height: Double = 40

    public init(type: ItemType, content: String, id: String? = nil) {
        self.id = id ?? UUID().uuidString
        self.type = type
        self.content = content
    }

    public enum ItemType: Int {
        case text = 0
        case label = 4
        case toggle = 6
        case button = 9
        case aichat = 17
    }
}

// MARK: - Independent Event Bridge for 'sw'
public struct SwBridge {
    public static func onAction(_ id: String) {
        "SW_ONACTION".withCString { ptr in
            if let pDyn = hb_dynsymFindName(ptr) {
                if let sym = hb_dynsymSymbol(pDyn) {
                    hb_vmPushSymbol(sym)
                    hb_vmPushNil()
                    hb_vmPushString(id)
                    hb_vmDo(1)
                }
            }
        }
    }

    public static func onChange(_ id: String, _ value: Bool) {
        "SW_ONCHANGE".withCString { ptr in
            if let pDyn = hb_dynsymFindName(ptr) {
                if let sym = hb_dynsymSymbol(pDyn) {
                    hb_vmPushSymbol(sym); hb_vmPushNil(); hb_vmPushString(id); hb_vmPushLogical(value ? 1 : 0); hb_vmDo(2)
                }
            }
        }
    }
}

// MARK: - Independent Coordinate System
public class SwFlippedView: NSView {
    public override var isFlipped: Bool { return true }
}

public func applySwiftViewLayout(swiftView: NSView, parent: NSObject, top: Double, left: Double, w: Double, h: Double) {
    let targetView: NSView? = (parent as? NSWindow)?.contentView ?? (parent as? NSView)
    guard let contentView = targetView else { return }
    
    // En este PoC usamos coordenadas directas
    swiftView.frame = NSRect(x: CGFloat(left), y: CGFloat(top), width: CGFloat(w), height: CGFloat(h))
    contentView.addSubview(swiftView)
    swiftView.translatesAutoresizingMaskIntoConstraints = true
    swiftView.autoresizingMask = [.maxXMargin, .minYMargin]
    
    if let id = swiftView.identifier?.rawValue, !id.isEmpty {
       SwRegistry.register(swiftView, for: id)
    }
}
