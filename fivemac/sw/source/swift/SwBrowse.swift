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

// El estado
@Observable
public class BrowseState: SwApplyable {
    public let id: String
    var columns: [SwBrowseColumn] = []
    var rows: [SwBrowseRow] = []
    var selection: String?
    var backColorHex: String?
    
    public init(id: String) {
        self.id = id
    }
    
    public func apply(property: String, value: Any) {
        Task { @MainActor in
            if property == "backcolor", let hex = value as? String {
                self.backColorHex = hex
            }
            
            if property == "columns", let colsData = value as? [[String: Any]] {
                let newCols = colsData.compactMap { dict -> SwBrowseColumn? in
                    let title = dict["title"] as? String ?? ""
                    let field = dict["field"] as? String ?? ""
                    let width = dict["width"] as? Double
                    return SwBrowseColumn(title: title, field: field, width: width != nil ? CGFloat(width!) : nil)
                }
                if self.columns.map({$0.field}) != newCols.map({$0.field}) {
                    self.columns = newCols
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
            
            if property == "row_update", let rowDataDict = value as? [String: Any] {
                let rowId = rowDataDict["id"] as? String ?? ""
                if let index = self.rows.firstIndex(where: { $0.id == rowId }) {
                    var newRowData: [String: String] = [:]
                    for (key, val) in rowDataDict {
                        newRowData[key] = "\(val)"
                    }
                    self.rows[index] = SwBrowseRow(id: rowId, data: newRowData)
                }
            }
        }
    }
}

// CÉLULA PERSONALIZADA BASADA EN EL ESTÁNDAR NSTableCellView
class SwBrowseCellView: NSTableCellView {
    private let bgView = NSView()
    var bgColor: NSColor?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.wantsLayer = true
        self.layer?.masksToBounds = true
        
        bgView.wantsLayer = true
        bgView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bgView, positioned: .below, relativeTo: nil)
        
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bgView.topAnchor.constraint(equalTo: self.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func updateStyle(isSelected: Bool) {
        if isSelected {
            bgView.layer?.backgroundColor = nil
        } else {
            bgView.layer?.backgroundColor = bgColor?.cgColor
        }
    }
}

// WRAPPER NATIVO DE NSTABLEVIEW
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
        tableView.rowHeight = 24
        
        context.coordinator.tableView = tableView
        scrollView.documentView = tableView
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let tableView = nsView.documentView as? NSTableView else { return }
        
        // Aplicar color de fondo al scroll view y table view
        if let hex = state.backColorHex, let color = NSColor(hex: hex) {
            nsView.drawsBackground = true
            nsView.backgroundColor = color
            tableView.backgroundColor = color
        } else {
            nsView.drawsBackground = false
            tableView.backgroundColor = .controlBackgroundColor
        }
        
        let currentIds = tableView.tableColumns.map { $0.identifier.rawValue }
        let newIds = state.columns.map { $0.field }
        
        if currentIds != newIds {
            for col in tableView.tableColumns { tableView.removeTableColumn(col) }
            for colData in state.columns {
                let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(colData.field))
                col.title = colData.title
                if let width = colData.width { col.width = width }
                col.resizingMask = [.autoresizingMask, .userResizingMask]
                let descriptor = NSSortDescriptor(key: colData.field, ascending: true)
                col.sortDescriptorPrototype = descriptor
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
        
        func numberOfRows(in tableView: NSTableView) -> Int {
            return parent.state.rows.count
        }
        
        func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
            guard let descriptor = tableView.sortDescriptors.first, let field = descriptor.key else { return }
            let ascending = descriptor.ascending
            
            parent.state.rows.sort { r1, r2 in
                let v1 = r1.data[field] ?? ""
                let v2 = r2.data[field] ?? ""
                
                // Intento de ordenación numérica
                if let n1 = Double(v1), let n2 = Double(v2) {
                    return ascending ? n1 < n2 : n1 > n2
                }
                
                // Ordenación de texto (localizada)
                return ascending ? v1.localizedCompare(v2) == .orderedAscending : v1.localizedCompare(v2) == .orderedDescending
            }
            
            tableView.reloadData()
        }
        
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            guard let column = tableColumn, row < parent.state.rows.count else { return nil }
            
            let field = column.identifier.rawValue
            let rowData = parent.state.rows[row].data
            let cellId = NSUserInterfaceItemIdentifier("SwBrowseCell")
            
            var cell = tableView.makeView(withIdentifier: cellId, owner: nil) as? SwBrowseCellView
            if cell == nil {
                cell = SwBrowseCellView(frame: .zero)
                cell?.identifier = cellId
            }
            
            // Limpieza y configuración
            cell?.subviews.forEach { if $0 !== cell?.subviews.first { $0.removeFromSuperview() } } // Mantener solo bgView
            
            let text = rowData[field] ?? ""
            let imageName = rowData["\(field)_img"]
            let colorHex = rowData["\(field)_color"]
            let rowColorHex = rowData["row_color"]
            
            if let hex = colorHex ?? rowColorHex {
                cell?.bgColor = NSColor(hex: hex)
            } else {
                cell?.bgColor = nil
            }
            
            var lastView: NSView?
            if let imgName = imageName, !imgName.isEmpty {
                let imageView = NSImageView()
                if let sysImg = NSImage(systemSymbolName: imgName, accessibilityDescription: nil) { imageView.image = sysImg }
                else if let bundleImg = NSImage(named: imgName) { imageView.image = bundleImg }
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.contentTintColor = .secondaryLabelColor
                cell?.addSubview(imageView)
                NSLayoutConstraint.activate([
                    imageView.centerYAnchor.constraint(equalTo: cell!.centerYAnchor),
                    imageView.leadingAnchor.constraint(equalTo: cell!.leadingAnchor, constant: 4),
                    imageView.widthAnchor.constraint(equalToConstant: 16),
                    imageView.heightAnchor.constraint(equalToConstant: 16)
                ])
                lastView = imageView
            }
            
            let textField = NSTextField(labelWithString: text)
            textField.isBezeled = false
            textField.drawsBackground = false
            textField.isEditable = false
            textField.cell?.lineBreakMode = .byTruncatingTail
            textField.translatesAutoresizingMaskIntoConstraints = false
            cell?.addSubview(textField)
            NSLayoutConstraint.activate([
                textField.centerYAnchor.constraint(equalTo: cell!.centerYAnchor),
                textField.leadingAnchor.constraint(equalTo: lastView?.trailingAnchor ?? cell!.leadingAnchor, constant: 4),
                textField.trailingAnchor.constraint(equalTo: cell!.trailingAnchor, constant: -4)
            ])
            
            cell?.updateStyle(isSelected: tableView.isRowSelected(row))
            return cell
        }
        
        func tableViewSelectionDidChange(_ notification: Notification) {
            guard let tableView = notification.object as? NSTableView else { return }
            tableView.enumerateAvailableRowViews { (rowView, row) in
                for i in 0..<rowView.numberOfColumns {
                    if let cell = rowView.view(atColumn: i) as? SwBrowseCellView {
                        cell.updateStyle(isSelected: rowView.isSelected)
                    }
                }
            }
            let selectedRow = tableView.selectedRow
            if selectedRow >= 0 && selectedRow < parent.state.rows.count {
                parent.state.selection = parent.state.rows[selectedRow].id
            } else {
                parent.state.selection = nil
            }
        }
        
        @objc func onDoubleClick(_ sender: AnyObject) {
            guard let tableView = sender as? NSTableView else { return }
            let clickedRow = tableView.clickedRow
            if clickedRow >= 0 && clickedRow < parent.state.rows.count {
                let rowId = parent.state.rows[clickedRow].id
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

extension NSColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgb & 0x0000FF) / 255.0,
                  alpha: 1.0)
    }
}

public struct SwiftBrowseView: View {
    @State var state: BrowseState
    public var body: some View {
        VStack(spacing: 0) {
            if state.columns.isEmpty {
                ContentUnavailableView("No Columns Defined", systemImage: "table.badge.more").frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                NSTableViewController(state: state).frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Divider()
            HStack {
                Text(state.selection != nil ? "Selected ID: \(state.selection!)" : "No selection")
                Spacer()
                Text("Total rows: \(state.rows.count)")
            }
            .padding(8).font(.caption).background(Color(NSColor.controlBackgroundColor))
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
