import SwiftUI
import Observation

// MARK: - Menu State
@Observable
public class SwiftMenuState: SwiftVStackState {
    public var id: String
    public var caption: String
    public var systemImage: String = ""

    public init(id: String, caption: String) {
        self.id = id
        self.caption = caption
        super.init()
    }

    @MainActor
    public override func apply(property: String, value: Any) {
        let prop = property.lowercased()
        switch prop {
        case "caption", "text", "settext", "title":
            self.caption = String(describing: value)
        case "icon":
            self.systemImage = String(describing: value)
        case "visible":
            self.isVisible = SwUtils.toBool(value)
        case "enabled":
            self.isEnabled = SwUtils.toBool(value)
        default:
            super.apply(property: property, value: value)
        }
    }
}

// MARK: - Menu View
public struct SwiftMenuView: View {
    @Bindable var state: SwiftMenuState

    public var body: some View {
        if state.isVisible {
            Menu {
                ForEach(state.items) { item in
                    SwRecursiveItemView(item: item)
                }
            } label: {
                HStack(spacing: 6) {
                    if !state.systemImage.isEmpty {
                        Image(systemName: state.systemImage)
                    }
                    Text(state.caption)
                }
            }
            .disabled(!state.isEnabled)
        }
    }
}

// MARK: - MenuItem State
@Observable
public class SwiftMenuItemState: SwApplyable {
    public var id: String
    public var caption: String
    public var systemImage: String = ""
    public var isVisible: Bool = true
    public var isEnabled: Bool = true
    public var shortcut: String = ""

    public init(id: String, caption: String) {
        self.id = id
        self.caption = caption
    }

    @MainActor
    public func apply(property: String, value: Any) {
        let prop = property.lowercased()
        switch prop {
        case "caption", "text", "settext", "title":
            self.caption = String(describing: value)
        case "icon":
            self.systemImage = String(describing: value)
        case "visible":
            self.isVisible = SwUtils.toBool(value)
        case "enabled":
            self.isEnabled = SwUtils.toBool(value)
        case "shortcut":
            self.shortcut = String(describing: value)
        default:
            break
        }
    }
}

// MARK: - MenuItem View
public struct SwiftMenuItemView: View {
    @Bindable var state: SwiftMenuItemState

    public var body: some View {
        if state.isVisible {
            Button(action: {
                let json = "{\"\(state.id)\":{\"event\":\"click\"}}"
                Harbour.call("SW_UPDATE_HB", json)
            }) {
                HStack {
                    Text(state.caption)
                    if !state.systemImage.isEmpty {
                        Spacer()
                        Image(systemName: state.systemImage)
                    }
                }
            }
            .disabled(!state.isEnabled)
        }
    }
}

// MARK: - Factory Logic
extension SwiftMenuView {
    @MainActor
    public static func create(id: String, initial: GenericInit) -> StackItem {
        let state = SwiftMenuState(id: id, caption: initial.caption ?? initial.title ?? "Menu")
        ViewRegistry.register(state, for: id)
        let item = StackItem(type: .menu, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

extension SwiftMenuItemView {
    @MainActor
    public static func create(id: String, initial: GenericInit) -> StackItem {
        let state = SwiftMenuItemState(id: id, caption: initial.caption ?? initial.title ?? "Item")
        ViewRegistry.register(state, for: id)
        let item = StackItem(type: .menuitem, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}
