import SwiftUI

// MARK: - SwReport Commands
internal struct ReportCommands {
    static func register(in sd: SwDispatcher) {
        sd.register("report_show") { params in
            guard let jsonStr = params["data"] as? String,
                  let data = jsonStr.data(using: .utf8),
                  let reportData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return ["status": "error", "message": "Invalid report data"]
            }
            
            await MainActor.run {
                let id = reportData["id"] as? String ?? "rpt_default"
                let title = reportData["title"] as? String ?? "Report"
                
                let reportWindow = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                    styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                    backing: .buffered, defer: false)
                
                reportWindow.center()
                reportWindow.title = title
                reportWindow.isReleasedWhenClosed = false
                
                let view = SwReportView(data: reportData)
                reportWindow.contentView = NSHostingView(rootView: view)
                reportWindow.makeKeyAndOrderFront(nil)
                
                // Registramos la ventana por si queremos cerrarla luego desde Harbour
                ViewRegistry.register(reportWindow, for: "NSWindow_\(id)")
            }
            
            return ["status": "ok"]
        }
    }
}

// MARK: - SwReport View (The "Modern" Look)
struct SwReportView: View {
    let data: [String: Any]
    
    var body: some View {
        ZStack {
            // Fondo con degradado sutil (Estilo Premium)
            LinearGradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)], 
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // El "Papel" del reporte
                    VStack(alignment: .leading, spacing: 15) {
                        if let elements = data["elements"] as? [[String: Any]] {
                            ForEach(0..<elements.count, id: \.self) { index in
                                ReportElementView(element: elements[index])
                            }
                        }
                    }
                    .padding(40)
                    .frame(maxWidth: 800)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                    .padding(.vertical, 30)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Report Element Dispatcher
struct ReportElementView: View {
    let element: [String: Any]
    
    var body: some View {
        let type = element["type"] as? String ?? ""
        
        Group {
            switch type {
            case "header":
                HStack {
                    if let icon = element["icon"] as? String {
                        Image(systemName: icon)
                            .font(.title)
                            .foregroundStyle(mapColorStyle(element["color"] as? String ?? ".blue"))
                    }
                    Text(element["text"] as? String ?? "")
                        .font(.system(size: 28, weight: .bold))
                }
                .padding(.bottom, 10)
                
            case "text":
                Text(element["text"] as? String ?? "")
                    .font(.system(size: CGFloat(element["size"] as? Int ?? 14)))
                    .foregroundStyle(mapColorStyle(element["color"] as? String ?? "primary"))
                
            case "divider":
                Divider()
                    .padding(.vertical, 5)
                    
            case "table":
                ReportTableView(headers: element["headers"] as? [String] ?? [], 
                                rows: element["rows"] as? [[Any]] ?? [])
                
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Modern Report Table
struct ReportTableView: View {
    let headers: [String]
    let rows: [[Any]]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                ForEach(headers, id: \.self) { header in
                    Text(header)
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(Color.gray.opacity(0.1))
            
            // Rows
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack {
                    let row = rows[rowIndex]
                    ForEach(0..<row.count, id: \.self) { colIndex in
                        Text(String(describing: row[colIndex]))
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                
                if rowIndex < rows.count - 1 {
                    Divider().opacity(0.5)
                }
            }
        }
        .border(Color.gray.opacity(0.2), width: 1)
        .padding(.vertical, 10)
    }
}
