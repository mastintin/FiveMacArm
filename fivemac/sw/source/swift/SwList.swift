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
    public var hasSearch: Bool = false
    public var searchStyle: Int = 0 // 0 = Toolbar, 1 = Inline
    
    // Style
    public var style: Int = 0
    public var backgroundColor: Color = .clear
    public var rowSpacing: Double = 0
    
    public init(id: String) {
        self.id = id
    }
    
    @MainActor
    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "style":
             if let nVal = value as? Int { self.style = nVal }
        case "backgroundcolor":
             if let sVal = value as? String { self.backgroundColor = Color(hex: sVal) }
        case "selectedid":
             if let sVal = value as? String { self.selectedId = sVal }
        case "filter":
             if let sVal = value as? String { self.filterText = sVal.lowercased() }
        case "hassearch":
             if let bVal = value as? Bool { self.hasSearch = bVal }
        case "searchstyle":
             if let nVal = value as? Int { self.searchStyle = nVal }
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
    
    private func hasText(_ item: StackItem, _ text: String) -> Bool {
        let query = text.lowercased()
        // 1. Miramos si el objeto actual tiene texto
        if let labelState = ViewRegistry.get(item.id) as? SwiftLabelState {
            let labelText = labelState.text.lowercased()
            let contains = labelText.contains(query)
            print("🏝️ [Search] Label '\(labelState.text)' (lowercased: '\(labelText)') contains '\(query)'? \(contains)")
            if contains { return true }
        }
        if let getState = ViewRegistry.get(item.id) as? SwiftGetState,
           getState.text.lowercased().contains(query) {
            return true
        }
        
        // 2. Si es un contenedor, buscamos en sus hijos
        if let state = ViewRegistry.get(item.id) as? StackStateProtocol {
            for child in state.items {
                if hasText(child, query) { return true }
            }
        }
        
        return false
    }

    var filteredItems: [StackItem] {
        if state.filterText.isEmpty {
            return state.items
        } else {
            return state.items.filter { hasText($0, state.filterText) }
        }
    }
    
    public var body: some View {
        Group {
            if state.hasSearch && state.searchStyle == 0 {
                contentWithSearch()
                    .searchable(text: $state.filterText, placement: .toolbar)
            } else {
                contentWithSearch()
            }
        }
        .onChange(of: state.selectedId) { oldId, newId in
            if let id = newId {
                print("🏝️ [Swift] Detectado cambio de selección: \(id)")
                selectRow(id, state: state)
            }
        }
    }
    
    @ViewBuilder
    private func contentWithSearch() -> some View {
        VStack(spacing: 0) {
            if state.hasSearch && state.searchStyle == 1 {
                // Inline Search Bar
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Buscar...", text: $state.filterText)
                        .textFieldStyle(.plain)
                    if !state.filterText.isEmpty {
                        Button(action: { state.filterText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(6)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 4)
            }
            
            renderList()
        }
    }
    
    @ViewBuilder
    private func renderList() -> some View {
        let list = List(selection: $state.selectedId) {
            ForEach(filteredItems) { item in
                SwRecursiveItemView(item: item)
                    .buttonStyle(.plain) // Evita que la lista nativa se trague los clics de los botones en la fila
                    .tag(item.id as String?) // Es crucial que sea String? para que la selección de la lista nativa funcione
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                    // Hacemos que el fondo sea transparente pero clicable, sin bloquear sub-botones
                    .listRowBackground(
                        Rectangle()
                            .fill(state.selectedId == item.id ? Color.accentColor.opacity(0.15) : Color.clear)
                            .contentShape(Rectangle())
                    )
            }
        }
        
        switch state.style {
        case 1:
            list.listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .background(state.backgroundColor == .clear ? Color.clear : state.backgroundColor)
                .id(state.filterText.isEmpty)
        case 2:
            list.listStyle(.inset)
                .scrollContentBackground(.hidden)
                .background(state.backgroundColor == .clear ? Color.clear : state.backgroundColor)
                .id(state.filterText.isEmpty)
        case 3:
            // Premium Glass/Vibrancy Card Style
            list.listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(4) // Evita que la scrollbar quede cortada por las esquinas
                .background(state.backgroundColor == .clear ? AnyView(Rectangle().fill(.ultraThinMaterial)) : AnyView(state.backgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(4)
                .id(state.filterText.isEmpty)
        default:
            list.listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(state.backgroundColor == .clear ? Color.clear : state.backgroundColor)
                .id(state.filterText.isEmpty)
        }
    }

    private func selectRow(_ rowId: String, state: ListState) {
        print("🏝️ [Swift] selectRow enviando pipeline para: \(rowId)")
        let json = "{\"\(state.id)\":{\"SelectedId\":\"\(rowId)\",\"event\":\"select\"}}"
        Harbour.call("SW_UPDATE_HB", json)
    }
}
