import SwiftUI
import Observation

struct SwBrowseColumn: Identifiable, Codable {
    var id: String { field }
    let title: String
    let field: String
    let width: CGFloat?
}

struct SwBrowseRow: Identifiable {
    let id: String
    var data: [String: String]
}

@Observable
public class BrowseState: SwApplyable {
    public let id: String
    var columns: [SwBrowseColumn] = []
    var rows: [SwBrowseRow] = [
        SwBrowseRow(id: "1", data: ["id": "1", "name": "Manuel Alvarez", "email": "manuel@fivemac.com", "status": "Active"]),
        SwBrowseRow(id: "2", data: ["id": "2", "name": "Antonio Linares", "email": "alinares@harbour.org", "status": "Active"]),
        SwBrowseRow(id: "3", data: ["id": "3", "name": "John Doe", "email": "john@example.com", "status": "Inactive"])
    ]
    var selection: SwBrowseRow.ID?
    var sortOrder = [KeyPathComparator(\SwBrowseRow.id)]
    
    public init(id: String) {
        self.id = id
    }
    
    public func apply(property: String, value: Any) {
        print("🏝️ Swift [BrowseState] Property: \(property), Value: \(value)")
        if property == "columns", let colsData = value as? [[String: Any]] {
            self.columns = colsData.compactMap { dict in
                let title = dict["title"] as? String ?? ""
                let field = dict["field"] as? String ?? ""
                let width = dict["width"] as? Double
                return SwBrowseColumn(title: title, field: field, width: width != nil ? CGFloat(width!) : nil)
            }
        }
        
        if property == "rows", let rowsData = value as? [[String: Any]] {
            self.rows = rowsData.compactMap { dict in
                let id = dict["id"] as? String ?? UUID().uuidString
                var rowData: [String: String] = [:]
                for (key, val) in dict {
                    rowData[key] = "\(val)"
                }
                return SwBrowseRow(id: id, data: rowData)
            }
        }
    }
    
    // Función auxiliar para obtener el título de una columna por índice
    func colTitle(_ index: Int) -> String {
        guard index < columns.count else { return "" }
        return columns[index].title
    }
    
    // Función auxiliar para obtener el valor de una celda por índice de columna
    func cellValue(_ row: SwBrowseRow, _ colIndex: Int) -> String {
        guard colIndex < columns.count else { return "" }
        let field = columns[colIndex].field
        return row.data[field] ?? ""
    }
}

public struct SwiftBrowseView: View {
    @State var state: BrowseState
    
    public var body: some View {
        VStack(spacing: 0) {
            if state.columns.isEmpty {
                ContentUnavailableView("No Columns Defined", systemImage: "table.badge.more")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Usamos columnas fijas mapeadas a los datos dinámicos para asegurar compilación
                Table(state.rows, selection: $state.selection, sortOrder: $state.sortOrder) {
                    TableColumn(state.colTitle(0)) { row in Text(state.cellValue(row, 0)) }
                    TableColumn(state.colTitle(1)) { row in Text(state.cellValue(row, 1)) }
                    TableColumn(state.colTitle(2)) { row in Text(state.cellValue(row, 2)) }
                    TableColumn(state.colTitle(3)) { row in Text(state.cellValue(row, 3)) }
                    TableColumn(state.colTitle(4)) { row in Text(state.cellValue(row, 4)) }
                }
                .tableStyle(.inset)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Divider()
            
            HStack {
                Text(state.selection != nil ? "Selected: \(state.selection!)" : "No selection")
                Spacer()
                Text("Total rows: \(state.rows.count)")
            }
            .padding(8)
            .font(.caption)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @MainActor
    public static func create(id: String, initial: GenericInit) -> StackItem {
        let state = BrowseState(id: id)
        ViewRegistry.register(state, for: id)
        let item = StackItem(type: .browse, id: id)
        item.itemWidth = initial.width
        item.itemHeight = initial.height
        item.x = initial.left
        item.y = initial.top
        return item
    }
}
