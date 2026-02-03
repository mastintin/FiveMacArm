import SwiftUI
import AppKit
import Charts

@available(OSX 10.15, *)
class ChartState: ObservableObject {
    @Published var dataJson: String
    @Published var type: String
    
    init(dataJson: String, type: String) {
        self.dataJson = dataJson
        self.type = type
    }
}

@available(OSX 10.15, *)
struct SwiftChartView: View {
    @ObservedObject var state: ChartState
    
    struct ChartItem: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
        let group: String
    }
    
    var dataItems: [ChartItem] {
        guard let data = state.dataJson.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        
        return jsonArray.compactMap { dict in
            guard let label = dict["label"] as? String,
                  let value = dict["value"] as? Double else { return nil }
            let group = dict["group"] as? String ?? "Default"
            return ChartItem(label: label, value: value, group: group)
        }
    }
    
    var body: some View {
        Group {
            if #available(macOS 13.0, *) {
                Chart(dataItems) { item in
                    if state.type == "line" {
                        LineMark(
                            x: .value("Label", item.label),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(by: .value("Group", item.group))
                    } else if state.type == "point" {
                         PointMark(
                            x: .value("Label", item.label),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(by: .value("Group", item.group))
                    } else {
                        BarMark(
                            x: .value("Label", item.label),
                            y: .value("Value", item.value)
                        )
                        .foregroundStyle(by: .value("Group", item.group))
                    }
                }
                .padding()
            } else {
                Text("Swift Charts requires macOS 13+")
            }
        }
    }
}

@objc(SwiftChartLoader)
public class SwiftChartLoader: NSObject {
    
    static var states: [String: ChartState] = [:]
    static var views: [String: NSView] = [:]
    
    @objc(makeChart:data:type:index:)
    public static func makeChart(id: String, data: String, type: String, index: Int) -> NSView {
        if #available(OSX 10.15, *) {
            
            let state = ChartState(dataJson: data, type: type)
            
            let key = id.isEmpty ? String(index) : id
            states[key] = state
            
            let view = SwiftChartView(state: state)
            
            ViewRegistry.register(view, for: index)
            
            let hostingView = NSHostingView(rootView: view)
            
            // Registering the hostingView as an object so it can be retrieved by SwiftPDF
            ViewRegistry.registerObject(hostingView, for: index)
            
            views[key] = hostingView
            // hostingView.translatesAutoresizingMaskIntoConstraints = true // Default is true for pure NSView, but NSHostingView might differ? 
            // Better to just NOT set it to false.
            // hostingView.translatesAutoresizingMaskIntoConstraints = false 
            return hostingView
        } else {
            return NSView()
        }
    }
    
    @objc(setData:id:)
    public static func setData(_ data: String, id: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = states[id] {
                    state.dataJson = data
                }
            }
        }
    }
    
    @objc(setType:id:)
    public static func setType(_ type: String, id: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = states[id] {
                    state.type = type
                }
            }
        }
    }

    @objc(makeSnapshot:path:)
    public static func makeSnapshot(id: String, path: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                guard let view = views[id] else {
                    print("Debug: Views available: \(views.keys)")
                    print("Error: View not found for snapshot id: \(id)")
                    return
                }
                
                if let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) {
                    view.cacheDisplay(in: view.bounds, to: rep)
                    if let data = rep.representation(using: .png, properties: [:]) {
                        try? data.write(to: URL(fileURLWithPath: path))
                    }
                }
            }
        }
    }
}
