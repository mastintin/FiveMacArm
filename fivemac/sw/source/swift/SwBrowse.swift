import SwiftUI
import AppKit

// Estructuras de datos
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

// El estado sigue siendo el mismo para mantener compatibilidad con Harbour
@Observable
public class BrowseState: SwApplyable {
    public let id: String
    var columns: [SwBrowseColumn] = []
    var rows: [SwBrowseRow] = []
    var selection: String?
    
    public init(id: String) {
        self.id = id
    }
    
    public func apply(property: String, value: Any) {
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
                let rowId = dict["id"] as? String ?? UUID().uuidString
                var rowData: [String: String] = [:]
                for (key, val) in dict {
                    rowData[key] = "\(val)"
                }
                return SwBrowseRow(id: rowId, data: rowData)
            }
        }
    }
}

// WRAPPER NATIVO DE NSTABLEVIEW (El motor real de macOS)
struct NSTableViewController: NSViewRepresentable {
    @Bindable var state: BrowseState
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        
        let tableView = NSTableView()
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.headerView = NSTableHeaderView()
        tableView.target = context.coordinator
        tableView.doubleAction = #selector(Coordinator.onDoubleClick(_:))
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.allowsColumnResizing = true
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.rowHeight = 24 // Altura de fila estándar nativa
        
        context.coordinator.tableView = tableView
        scrollView.documentView = tableView
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let tableView = nsView.documentView as? NSTableView else { return }
        
        // Sincronizar columnas
        if tableView.tableColumns.count != state.columns.count {
            for col in tableView.tableColumns { tableView.removeTableColumn(col) }
            for colData in state.columns {
                let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(colData.field))
                col.title = colData.title
                if let width = colData.width { col.width = width }
                tableView.addTableColumn(col)
            }
        }
        
        tableView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
        var parent: NSTableViewController
        weak var tableView: NSTableView?
        
        init(_ parent: NSTableViewController) {
            self.parent = parent
        }
        
        // DataSource
        func numberOfRows(in tableView: NSTableView) -> Int {
            return parent.state.rows.count
        }
        
        // Delegate - Renderizado de celdas con CENTRADO VERTICAL
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            guard let column = tableColumn, row < parent.state.rows.count else { return nil }
            
            let field = column.identifier.rawValue
            let text = parent.state.rows[row].data[field] ?? ""
            
            // Contenedor para centrar verticalmente
            let container = NSView()
            
            let textField = NSTextField(labelWithString: text)
            textField.isBezeled = false
            textField.drawsBackground = false
            textField.isEditable = false
            textField.cell?.lineBreakMode = .byTruncatingTail
            textField.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubview(textField)
            
            NSLayoutConstraint.activate([
                textField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                textField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
                textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4)
            ])
            
            // Lógica de colores aplicada al CONTENEDOR
            let val = text.lowercased()
            if val == "baja" || val == "inactive" { 
                container.wantsLayer = true
                container.layer?.backgroundColor = NSColor.systemRed.withAlphaComponent(0.2).cgColor 
            }
            else if val == "activo" || val == "active" { 
                container.wantsLayer = true
                container.layer?.backgroundColor = NSColor.systemGreen.withAlphaComponent(0.2).cgColor 
            }
            else if val == "pendiente" { 
                container.wantsLayer = true
                container.layer?.backgroundColor = NSColor.systemOrange.withAlphaComponent(0.2).cgColor 
            }
            
            return container
        }
        
        // Selección
        func tableViewSelectionDidChange(_ notification: Notification) {
            guard let tableView = notification.object as? NSTableView else { return }
            let selectedRow = tableView.selectedRow
            if selectedRow >= 0 && selectedRow < parent.state.rows.count {
                parent.state.selection = parent.state.rows[selectedRow].id
            } else {
                parent.state.selection = nil
            }
        }
        
        // Doble clic nativo
        @objc func onDoubleClick(_ sender: AnyObject) {
            guard let tableView = sender as? NSTableView else { return }
            let clickedRow = tableView.clickedRow
            if clickedRow >= 0 && clickedRow < parent.state.rows.count {
                let rowId = parent.state.rows[clickedRow].id
                print("🏝️ Native [NSTableView] Double Click Detected: Row \(rowId)")
                
                SwDispatcher.shared.recordChange(id: parent.state.id, property: "event", value: "dblclick")
                SwDispatcher.shared.recordChange(id: parent.state.id, property: "rowid", value: rowId)
                
                let changes = SwDispatcher.shared.flushStateChanges()
                if let data = try? JSONSerialization.data(withJSONObject: changes),
                   let json = String(data: data, encoding: .utf8) {
                    Harbour.call("SW_UPDATE_HB", json)
                }
            }
        }
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
                // USAMOS EL CONTROL NATIVO PARA MÁXIMA RESPUESTA
                NSTableViewController(state: state)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Divider()
            
            HStack {
                Text(state.selection != nil ? "Selected ID: \(state.selection!)" : "No selection")
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
