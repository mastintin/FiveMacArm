import SwiftUI
import Observation

// MARK: - SwiftTabView View
public struct SwiftTabView: View {
    @Bindable var state: SwiftTabViewState
    
    public var body: some View {
        if state.isVisible {
            TabView(selection: $state.selection) {
                ForEach(state.items) { item in
                    SwRecursiveItemView(item: item)
                        .tabItem {
                            if let s = ViewRegistry.getState(for: item.id) as? SwiftPanelState {
                                Label(s.title, systemImage: s.caption)
                            } else {
                                Label("Tab", systemImage: "square.grid.2x2")
                            }
                        }
                        .badge(badgeValue(for: item.id))
                        .tag(item.id)
                }
            }
            // En macOS 26 (Sequoia+), sidebarAdaptable es el estándar para apps modernas
            .tabViewStyle(.sidebarAdaptable)
            .padding(state.padding)
            .disabled(!state.isEnabled)
        }
    }

    private func badgeValue(for id: String) -> String? {
        if let s = ViewRegistry.getState(for: id) as? SwiftPanelState, !s.badge.isEmpty {
            return s.badge
        }
        return nil
    }
}

// MARK: - SwiftTabViewState
@Observable
public class SwiftTabViewState: StackStateProtocol, SwApplyable {
    public let id: String
    public var items: [StackItem] = []
    public var lastItem: StackItem?
    public var selection: String = ""
    public var isVisible: Bool = true
    public var isEnabled: Bool = true
    public var padding: CGFloat = 0
    public var style: Int = 1 // Default a Sidebar en 2026
    
    public init(id: String) {
        self.id = id
    }
    
    @MainActor
    public func apply(property: String, value: Any) {
        let prop = property.lowercased()
        switch prop {
        case "selection", "value":
            if let s = value as? String { self.selection = s }
        case "visible":
            self.isVisible = SwUtils.toBool(value)
        case "enabled":
            self.isEnabled = SwUtils.toBool(value)
        case "padding":
            if let n = SwUtils.toDouble(value) { self.padding = CGFloat(n) }
        case "style":
            if let n = SwUtils.toInt(value) { self.style = n }
        default:
            break
        }
    }
}

// MARK: - Factory Logic
extension SwiftTabView {
    @MainActor
    public static func create(id: String, initial: GenericInit) -> StackItem {
        let state = SwiftTabViewState(id: id)
        state.style = initial.style ?? 1
        
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .tabview, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}
