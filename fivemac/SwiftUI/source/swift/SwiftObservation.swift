import SwiftUI
import Observation
import HarbourMacro

@Observable
public class CounterModel {
    public var count: Int = 0
    public var message: String = "Ready"
    public var level: Double = 50.0
    public var isEnabled: Bool = true
    public var isTesting: Bool = false
    
    public var onAction: ((String) -> Void)?
    
    public static let shared = CounterModel()
    public init() {}
}

public struct ObservationTestView: View {
    var model = CounterModel.shared 
    public init() {}
    
    public var body: some View {
        VStack(spacing: 15) {
            Text(model.message)
                .font(.headline)
                .foregroundColor(.blue)
            
            HStack {
                Text("\(model.count)")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                
                Stepper("", value: Bindable(model).count)
                    .labelsHidden()
                    .onChange(of: model.count) {
                        model.onAction?("count_changed")
                    }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Level: \(Int(model.level))%")
                    .font(.caption)
                
                Slider(value: Bindable(model).level, in: 0...100)
                    .onChange(of: model.level) {
                        model.onAction?("level_changed")
                    }
            }
            
            Toggle("Active System", isOn: Bindable(model).isEnabled)
                .onChange(of: model.isEnabled) {
                    model.onAction?("toggle_changed")
                }
            
            if model.isTesting {
                Text("Testing Mode Active")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// --- BRIDGE ---

@objc(SwiftObservationLoader)
public class SwiftObservationLoader: NSObject {
    @objc(makeObservationTest:)
    public static func makeObservationTest(index: Int) -> NSView {
        let view = ObservationTestView()
        ViewRegistry.register(view, for: index)
        let hostingView = NSHostingView(rootView: view)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        return hostingView
    }
    
    @objc(setActionCallback:)
    public static func setActionCallback(callback: @escaping (String) -> Void) {
        CounterModel.shared.onAction = callback
    }
}

// Harbour Macros

@HarbourBridge
public func obs_set_count(nombre: String) {
    if let n = Int(nombre) {
        CounterModel.shared.count = n
    }
}

@HarbourBridge
public func obs_set_msg(nombre: String) {
    CounterModel.shared.message = nombre
}

@_cdecl("sw_obs_get_count")
public func sw_obs_get_count() -> Int {
    return CounterModel.shared.count
}

@_cdecl("sw_obs_get_level")
public func sw_obs_get_level() -> Double {
    return CounterModel.shared.level
}

@_cdecl("sw_obs_get_enabled")
public func sw_obs_get_enabled() -> Bool {
    return CounterModel.shared.isEnabled
}
