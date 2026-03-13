import SwiftUI
import AppKit
import Observation
import Charts
import HarbourMacro

@Observable
public class ChartState {
    var dataJson: String
    var type: String
    var title: String = ""
    var subtitle: String = ""
    
    init(dataJson: String, type: String) {
        self.dataJson = dataJson
        self.type = type
    }
}

struct SwiftChartView: View {
    var state: ChartState
    
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
        VStack(alignment: .leading) {
            if !state.title.isEmpty {
                Text(state.title)
                    .font(.headline)
            }
            if !state.subtitle.isEmpty {
                Text(state.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Chart(dataItems) { item in
                switch state.type.lowercased() {
                case "line":
                    LineMark(
                        x: .value("Label", item.label),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(by: .value("Group", item.group))
                    .symbol(by: .value("Group", item.group))
                    
                case "point":
                    PointMark(
                        x: .value("Label", item.label),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(by: .value("Group", item.group))
                    
                case "area":
                    AreaMark(
                        x: .value("Label", item.label),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(by: .value("Group", item.group))
                    
                case "pie", "sector":
                    if #available(macOS 14.0, *) {
                        SectorMark(
                            angle: .value("Value", item.value),
                            innerRadius: .ratio(state.type == "pie" ? 0 : 0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("Label", item.label))
                        .annotation(position: .overlay) {
                            Text("\(Int(item.value))")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    } else {
                        BarMark(
                             x: .value("Label", item.label),
                             y: .value("Value", item.value)
                         )
                         .foregroundStyle(by: .value("Group", item.group))
                    }
                    
                default: // bar
                    BarMark(
                        x: .value("Label", item.label),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(by: .value("Group", item.group))
                }
            }
            .padding(.top, 10)
        }
        .padding()
    }
}

@objc(SwiftChartLoader)
public class SwiftChartLoader: NSObject {
    
    public static var states: [String: ChartState] = [:]
    public static var views: [String: NSView] = [:]
    
    @objc(makeChart:data:type:index:)
    public static func makeChart(id: String, data: String, type: String, index: Int) -> NSView {
        let state = ChartState(dataJson: data, type: type)
        states[id] = state
        
        let view = SwiftChartView(state: state)
        ViewRegistry.register(view, for: id)
        
        let hostingView = NSHostingView(rootView: view)
        views[id] = hostingView
        return hostingView
    }

    @objc(setData:id:)
    public static func setData(data: String, id: String) {
         DispatchQueue.main.async {
             if let state = states[id] {
                 state.dataJson = data
             }
         }
    }

    @objc(setType:id:)
    public static func setType(type: String, id: String) {
         DispatchQueue.main.async {
             if let state = states[id] {
                 state.type = type
             }
         }
    }

    @objc(makeSnapshot:path:)
    public static func makeSnapshot(id: String, path: String) {
        DispatchQueue.main.async {
            guard let view = views[id] else {
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
    
    public static func destroyChart(id: String, viewPtr: Int64) {
        states.removeValue(forKey: id)
        views.removeValue(forKey: id)
        ViewRegistry.clean(id: id)
        
        if viewPtr != 0 {
            if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
                _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }
}

// --- HARBOUR DIRECT BRIDGES ---

@HarbourDirect
public func chart_set_data(id: String, data: String) {
    DispatchQueue.main.async {
        if let state = SwiftChartLoader.states[id] {
            state.dataJson = data
        }
    }
}

@HarbourDirect
public func chart_set_type(id: String, type: String) {
    DispatchQueue.main.async {
        if let state = SwiftChartLoader.states[id] {
            state.type = type
        }
    }
}

@HarbourDirect
public func chart_set_titles(id: String, title: String, subtitle: String) {
    DispatchQueue.main.async {
        if let state = SwiftChartLoader.states[id] {
            state.title = title
            state.subtitle = subtitle
        }
    }
}

@HarbourDirect
public func chart_make_snapshot(id: String, path: String) {
    DispatchQueue.main.async {
        guard let view = SwiftChartLoader.views[id] else {
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

@HarbourDirect
public func chart_destroy(id: String, viewPtr: Int64) {
    SwiftChartLoader.destroyChart(id: id, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_chart_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    parentPtr: Int64,
    id: String,
    data: String,
    type: String
) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        
        let chartView = SwiftChartLoader.makeChart(
            id: id,
            data: data,
            type: type,
            index: 0
        )
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: chartView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(chartView).toOpaque()
            viewAddress = Int64(Int(bitPattern: viewPtr))
        }
        
        return viewAddress
    }

    if Thread.isMainThread {
        return executeCreation()
    } else {
        return DispatchQueue.main.sync {
            return executeCreation()
        }
    }
}
