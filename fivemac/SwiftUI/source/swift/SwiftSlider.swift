import SwiftUI
import AppKit
import Observation
import HarbourMacro

// State for the Slider

@Observable
public class SliderState: RGBAColorableState {
    var value: Double
    var showValue: Bool
    var callback: ((Double) -> Void)?
    var accentColor: Color = .blue
    var backgroundColor: Color = .clear
    var foregroundColor: Color = .primary
    var isBold: Bool = false
    var fontSize: CGFloat = 12
    var isGlass: Bool = false
    
    init(value: Double = 0.0, showValue: Bool = true, isGlass: Bool = false, callback: ((Double) -> Void)? = nil) {
        self.value = value
        self.showValue = showValue
        self.isGlass = isGlass
        self.callback = callback
    }

    public func setAccentColorRGBA(color: Int, alpha: Int) {
        DispatchQueue.main.async {
            self.accentColor = Color(hbColor: color).opacity(Double(alpha) / 255.0)
        }
    }

    public func setTextColorRGBA(color: Int, alpha: Int) {
        DispatchQueue.main.async {
            self.foregroundColor = Color(hbColor: color).opacity(Double(alpha) / 255.0)
        }
    }
}

// SwiftUI View for the Slider

struct SwiftSliderView: View {
    var state: SliderState

    var body: some View {
        let sliderBinding = Binding(
            get: { self.state.value },
            set: { newValue in
                self.state.value = newValue
                self.state.callback?(newValue)
            }
        )
       
        VStack {
            if state.isGlass {
                Slider(value: sliderBinding, in: 0...100)
                    .glassEffect(.regular.interactive())
                    .tint(state.accentColor)
            } else {
                 Slider(value: sliderBinding, in: 0...100)
                    .tint(state.accentColor)
            }
            
            if state.showValue {
                Text("Value: \(Int(state.value))")
                    .font(.system(size: state.fontSize))
                    .fontWeight(state.isBold ? .bold : .regular)
                    .foregroundColor(state.foregroundColor)
            }
        }
        .padding()
        .background(
             Group {
                 if state.isGlass {
                     Color.clear
                 } else {
                    state.backgroundColor
                     .cornerRadius(8)
                 }
             }
        )
    }
}

@objc(SwiftSliderLoader)
public class SwiftSliderLoader: NSObject {
    
    public static func makeSlider(value: Double, id: String, showValue: Bool, isGlass: Bool, callback: @escaping ((Double) -> Void)) -> NSView {
        let finalId = id.isEmpty ? UUID().uuidString : id
        let state = SliderState(value: value, showValue: showValue, isGlass: isGlass, callback: callback)
        
        // Use central registry
        ViewRegistry.register(state, for: finalId)
        
        let sliderView = SwiftSliderView(state: state)
        ViewRegistry.register(sliderView, for: finalId)
        
        let hostingView = NSHostingView(rootView: sliderView)
        hostingView.sizingOptions = []
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
        
        return hostingView
    }

    public static func setShowValue(id: String, showValue: Bool) {
        DispatchQueue.main.async {
            if let state = ViewRegistry.getState(for: id) as? SliderState {
                state.showValue = showValue
            }
        }
    }

    public static func destroySlider(id: String, viewPtr: Int64) {
        ViewRegistry.clean(id: id) 
        if viewPtr != 0 {
            if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
                _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourDirect
public func sld_set_value(id: String, value: Double) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? SliderState {
            state.value = value
        }
    }
}

@HarbourDirect
public func sld_get_value(id: String) -> Double {
    return (ViewRegistry.getState(for: id) as? SliderState)?.value ?? 0.0
}

@HarbourDirect
public func sld_set_show_value(id: String, showValue: Bool) {
    SwiftSliderLoader.setShowValue(id: id, showValue: showValue)
}


@HarbourDirect
public func sld_destroy(id: String, viewPtr: Int64) {
    SwiftSliderLoader.destroySlider(id: id, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_slider_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    value: Double, 
    parentPtr: Int64,
    id: String,
    showValue: Bool,
    isGlass: Bool
    ) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        let finalId = id.isEmpty ? UUID().uuidString : id
        
        let callback: (Double) -> Void = { newValue in
            let sendToHarbour = {
                SwiftBridge.onChange(finalId, newValue)
            }

            if Thread.isMainThread {
               sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }

        let sliderView = SwiftSliderLoader.makeSlider(
            value: value, 
            id: finalId, // Pasamos el ID ya generado
            showValue: showValue,
            isGlass: isGlass,
            callback: callback
        )

        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: sliderView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(sliderView).toOpaque()
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
