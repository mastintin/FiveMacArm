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
        return makeObservationTest(id: String(index))
    }

    public static func makeObservationTest(id: String) -> NSView {
         let view = ObservationTestView()
         ViewRegistry.register(view, for: id)
         let hostingView = NSHostingView(rootView: view)
         hostingView.sizingOptions = []
         hostingView.translatesAutoresizingMaskIntoConstraints = false
         return hostingView
    }
    
    @objc(setActionCallback:)
    public static func setActionCallback(callback: @escaping (String) -> Void) {
        CounterModel.shared.onAction = callback
    }
}

// Harbour Macros

@HarbourDirect
public func obs_set_count(val: Int) {
    CounterModel.shared.count = val
}

@HarbourDirect
public func obs_set_msg(msg: String) {
    CounterModel.shared.message = msg
}

@HarbourDirect
public func obs_get_count() -> Int {
    return CounterModel.shared.count
}

@HarbourDirect
public func obs_get_level() -> Double {
    return CounterModel.shared.level
}

@HarbourDirect
public func obs_get_enabled() -> Bool {
    return CounterModel.shared.isEnabled
}

@HarbourDirect
public func obs_destroy(id: String, viewPtr: Int64) {
    ViewRegistry.clean(id: id)
    if viewPtr != 0 {
        if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
            _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
        }
    }
}

@HarbourDirect
public func swift_observation_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    parentPtr: Int64,
    id: String
) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        
        let obsView = SwiftObservationLoader.makeObservationTest(id: id)
        
        let callback: (String) -> Void = { action in
             let sendToHarbour = {
                if let pDynSym = hb_dynsymFindName("SWIFTOBSERONACTION") {
                    hb_vmPushSymbol(hb_dynsymSymbol(pDynSym))
                    hb_vmPushNil()
                    hb_vmPushString(id)
                    hb_vmPushString(action)
                    hb_vmDo(2)
                }
            }
            if Thread.isMainThread {
                sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }
        
        SwiftObservationLoader.setActionCallback(callback: callback)
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: obsView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(obsView).toOpaque()
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
