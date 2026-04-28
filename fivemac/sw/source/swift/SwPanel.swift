import SwiftUI
import Observation

// MARK: - SwiftPanel View
public struct SwiftPanelView: View {
    @Bindable var state: SwiftPanelState
    
    public var body: some View {
        if state.isVisible {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(state.items) { item in
                    SwRecursiveItemView(item: item)
                }
            }
            .padding(state.padding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(state.backgroundColor ?? AnyShapeStyle(Color.clear))
            .cornerRadius(state.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: state.cornerRadius)
                    .stroke(state.borderColor, lineWidth: state.borderWidth)
            )
            .shadow(color: state.shadowRadius > 0 ? Color.black.opacity(0.3) : Color.clear, radius: state.shadowRadius)
        }
    }
}

// MARK: - SwiftPanel State
@Observable
public class SwiftPanelState: StackStateProtocol, SwApplyable {
    public let id: String
    public var items: [StackItem] = []
    public var lastItem: StackItem?
    
    public var title: String = ""
    public var caption: String = "" // Icono (SF Symbol)
    public var badge: String = ""
    public var isVisible: Bool = true
    public var isEnabled: Bool = true
    public var backgroundColor: AnyShapeStyle? = nil
    public var borderColor: Color = .clear
    public var borderWidth: CGFloat = 0
    public var cornerRadius: CGFloat = 0
    public var shadowRadius: CGFloat = 0
    public var padding: CGFloat = 0
    
    public init(id: String) {
        self.id = id
    }
    
    @MainActor
    public func apply(property: String, value: Any) {
        let prop = property.lowercased()
        switch prop {
        case "title":
            if let s = value as? String { self.title = s }
        case "caption", "symbol":
            if let s = value as? String { self.caption = s }
        case "badge":
            self.badge = String(describing: value)
        case "backcolor", "backgroundcolor":
            if let s = value as? String { self.backgroundColor = mapColorStyle(sVal: s) }
        case "bordercolor":
            if let s = value as? String { self.borderColor = Color(hex: s) }
        case "borderwidth":
            if let n = SwUtils.toDouble(value) { self.borderWidth = CGFloat(n) }
        case "corner", "cornerradius":
            if let n = SwUtils.toDouble(value) { self.cornerRadius = CGFloat(n) }
        case "shadow":
            if let n = SwUtils.toDouble(value) { self.shadowRadius = CGFloat(n) }
        case "padding":
            if let n = SwUtils.toDouble(value) { self.padding = CGFloat(n) }
        case "visible":
            self.isVisible = SwUtils.toBool(value)
        default:
            break
        }
    }
    
    private func mapColorStyle(sVal: String) -> AnyShapeStyle {
        if sVal.hasPrefix(".") { return SwiftFive.mapColorStyle(sVal) }
        return AnyShapeStyle(Color(hex: sVal))
    }
}

// MARK: - Factory Logic
extension SwiftPanelView {
    @MainActor
    public static func create(id: String, initial: GenericInit) -> StackItem {
        let state = SwiftPanelState(id: id)
        state.title = initial.title ?? ""
        state.caption = initial.caption ?? ""
        
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .panel, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}
