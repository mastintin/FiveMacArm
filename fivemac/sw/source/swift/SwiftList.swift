import SwiftUI
import Observation

// MARK: - List State
@Observable
public class ListState: SwApplyable, StackStateProtocol {
    public let id: String
    public var items: [StackItem] = []
    public var lastItem: StackItem? = nil
    public var selectedId: String? = nil
    
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
        case "clear":
             self.items.removeAll()
             self.lastItem = nil
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
    public let hasScroll: Bool?
    public let interactive: Bool?
}

// MARK: - List View
public struct SwiftListView: View {
    @Bindable var state: ListState
    
    public var body: some View {
        List {
            ForEach(state.items) { item in
                // Cada fila es un RecursiveItemView
                // No le pasamos Frame fijo aquí porque la lista gestiona el alto de la fila
                SwRecursiveItemView(item: item)
                    .contentShape(Rectangle())
                    .listRowBackground(state.selectedId == item.id ? Color.accentColor.opacity(0.15) : Color.clear)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { _ in
                                selectRow(item.id, state: state)
                            }
                    )
            }
        }
        .listStyle(.plain)
    }

    private func selectRow(_ rowId: String, state: ListState) {
        state.selectedId = rowId
        let json = "{\"\(state.id)\":{\"SelectedId\":\"\(rowId)\",\"event\":\"select\"}}"
        Harbour.call("SW_PIPELINE_SYNC", json)
    }
}
