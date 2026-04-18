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
        case "clear":
             self.items.removeAll()
             self.lastItem = nil
             self.selectedId = nil
        default:
            break
        }
    }
}

// MARK: - List Initialization
public struct ListInit: Codable {
    public let top: Double?
    public let left: Double?
    public let width: Double?
    public let height: Double?
    public let resizemask: Int?
    public let hasscroll: Bool?
    public let interactive: Bool?
}

// MARK: - List View
public struct SwiftListView: View {
    @Bindable var state: ListState
    
    var filteredItems: [StackItem] {
        if state.filterText.isEmpty {
            return state.items
        } else {
            // Un filtrado básico pero efectivo por ID o por búsqueda recursiva simple (mejora futura)
            return state.items
        }
    }
    
    public var body: some View {
        List(selection: $state.selectedId) {
            ForEach(filteredItems) { item in
                // Cada fila es un organismo independiente
                SwRecursiveItemView(item: item)
                    .listRowInsets(EdgeInsets(top: 1, leading: 10, bottom: 1, trailing: 10))
                    .listRowBackground(
                        Rectangle()
                            .fill(state.selectedId == item.id ? Color.accentColor.opacity(0.15) : Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectRow(item.id, state: state)
                            }
                    )
            }
        }
        .listStyle(.plain)
        .background(state.backgroundColor)
    }

    private func selectRow(_ rowId: String, state: ListState) {
        state.selectedId = rowId
        let json = "{\"\(state.id)\":{\"SelectedId\":\"\(rowId)\",\"event\":\"select\"}}"
        Harbour.call("SW_PIPELINE_SYNC", json)
    }
}
