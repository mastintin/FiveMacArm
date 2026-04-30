import SwiftUI

@Observable
public class SwiftSidebarItemState: BaseControlState {
    public var prompt: String = ""
    public var symbol: String = "circle"
    public var isSelected: Bool = false
    public var isInteractive: Bool = true
    
    public init(id: String, prompt: String, symbol: String = "", isInteractive: Bool = true) {
        super.init(id: id)
        self.prompt = prompt
        if !symbol.isEmpty { self.symbol = symbol }
        self.isInteractive = isInteractive
    }
    
    public override func apply(property: String, value: Any) {
        let prop = property.lowercased()
        switch prop {
        case "prompt":
            if let v = value as? String { self.prompt = v }
        case "symbol":
            if let v = value as? String { self.symbol = v }
        case "selected":
            self.isSelected = SwUtils.toBool(value)
        case "interactive":
            self.isInteractive = SwUtils.toBool(value)
        default:
            super.apply(property: property, value: value)
        }
    }
}

public struct SwSidebarItemView: View {
    let state: SwiftSidebarItemState
    @State private var isHovered = false
    
    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: state.symbol)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 20)
            
            Text(state.prompt)
                .font(.system(size: 13))
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .contentShape(RoundedRectangle(cornerRadius: 6))
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(state.isSelected ? Color.accentColor : (isHovered && state.isInteractive ? Color.secondary.opacity(0.15) : Color.clear))
        )
        .foregroundColor(state.isSelected ? .white : .primary)
        .onHover { hovering in 
            if state.isInteractive { isHovered = hovering }
        }
        .onTapGesture {
            if state.isInteractive {
                print("🚢 [Swift] SidebarItem clicked: \(state.id)")
                SwiftBridge.onAction(state.id)
            }
        }
    }

    @MainActor
    public static func create(id: String, initial: GenericInit) -> StackItem {
        let isInter = (initial.interactive ?? 1) != 0
        let state = SwiftSidebarItemState(id: id, prompt: initial.title ?? "", symbol: initial.caption ?? "", isInteractive: isInter)
        ViewRegistry.register(state, for: id)
        let item = StackItem(type: .sidebaritem, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}
