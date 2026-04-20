import SwiftUI
import Observation

// MARK: - List State
@Observable
public class ListState: SwApplyable, StackStateProtocol {
    public let id: String
    public var items: [StackItem] = []
    public var lastItem: StackItem? = nil
    public var selectedId: String? = nil
    public var filterText: String = ""
    public var isInteractive: Bool = false
    
    // Style
    public var backgroundColor: Color = .clear
    public var rowSpacing: Double = 0
    
    public init(id: String) {
        self.id = id
    }
    
    @MainActor
    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "backgroundcolor":
             if let sVal = value as? String { self.backgroundColor = Color(hex: sVal) }
        case "selectedid":
             if let sVal = value as? String { self.selectedId = sVal }
        case "filter":
             if let sVal = value as? String { self.filterText = sVal.lowercased() }
        case "interactive":
             self.isInteractive = (value as? Bool) ?? false
        case "clear":
             self.items.removeAll()
             self.lastItem = nil
             self.selectedId = nil
        default:
            break
        }
    }
}

// MARK: - List View
public struct SwiftListView: View {
    @Bindable var state: ListState
    
    var filteredItems: [StackItem] {
        if state.filterText.isEmpty {
            return state.items
        } else {
            return state.items
        }
    }
    
    public var body: some View {
        List(selection: $state.selectedId) {
            ForEach(filteredItems) { item in
                SwRecursiveItemView(item: item)
                    .tag(item.id as String?) // Crucial para la selección nativa
                    .listRowInsets(EdgeInsets(top: 1, leading: 10, bottom: 1, trailing: 10))
                    .listRowBackground(
                        Rectangle()
                            .fill(state.selectedId == item.id ? Color.accentColor.opacity(0.15) : Color.clear)
                            .contentShape(Rectangle())
                    )
            }
        }
        .listStyle(.plain)
        .background(state.backgroundColor == .clear ? Color.gray.opacity(0.1) : state.backgroundColor)
        .onChange(of: state.selectedId) { oldId, newId in
            if let id = newId {
                print("🏝️ [Swift] Detectado cambio de selección: \(id)")
                selectRow(id, state: state)
            }
        }
    }

    private func selectRow(_ rowId: String, state: ListState) {
        print("🏝️ [Swift] selectRow enviando pipeline para: \(rowId)")
        let json = "{\"\(state.id)\":{\"SelectedId\":\"\(rowId)\",\"event\":\"select\"}}"
        Harbour.call("SW_PIPELINE_SYNC", json)
    }
}
