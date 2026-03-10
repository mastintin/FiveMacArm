import SwiftUI
import AppKit
import Observation
import HarbourMacro

// State for the Slider

@Observable
public class SliderState {
    var value: Double
    var showValue: Bool
    var callback: ((Double) -> Void)?
    var accentColor: Color = .blue
    var backgroundColor: Color = .clear
    var foregroundColor: Color = .primary
    var isBold: Bool = false
    var fontSize: CGFloat = 12
    var isGlass: Bool = false
    
    init(value: Double, showValue: Bool, isGlass: Bool, callback: ((Double) -> Void)?) {
        self.value = value
        self.showValue = showValue
        self.isGlass = isGlass
        self.callback = callback
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
                ZStack {
                     // 1. Glass Rail (Background Track)
                     Capsule()
                         .fill(.ultraThinMaterial)
                         .frame(height: 4)
                         .shadow(color: .white.opacity(0.5), radius: 0, x: 0, y: 1)
                    
                     // 2. The Slider itself
                     Slider(value: sliderBinding, in: 0...100)
                        .modify { view in
                            if #available(macOS 26.0, *) {
                                view.glassEffect(.regular.interactive())
                            } else {
                                view
                            }
                        }
                        .tint(.blue.opacity(0.8))
                }
                .contentShape(Capsule())
            } else {
                 Slider(value: sliderBinding, in: 0...100)
            }
            if state.showValue {
                Text("Value: \(Int(state.value))")
                    .font(.system(size: state.fontSize))
                    .fontWeight(state.isBold ? .bold : .regular)
                    .foregroundColor(state.foregroundColor)
            }
        }
        .accentColor(state.accentColor)
       
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
    
    public static var states: [String: SliderState] = [:]
    
    @objc(makeSliderWithValue:id:showValue:isGlass:index:callback:)
    public static func makeSlider(value: NSNumber, id: String, showValue: Bool, isGlass: Bool, index: Int, callback: @escaping ((NSNumber) -> Void)) -> NSView {
        let doubleVal = value.doubleValue
        let swiftCallback: (Double) -> Void = { val in
            callback(NSNumber(value: val))
        }
        
        let state = SliderState(value: doubleVal, showValue: showValue, isGlass: isGlass, callback: swiftCallback)
        let key = id.isEmpty ? String(index) : id
        SwiftSliderLoader.states[key] = state
        
        let view = SwiftSliderView(state: state)
        ViewRegistry.register(view, for: index)
        
        let hostingView = NSHostingView(rootView: view)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        
        return hostingView
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourBridge
public func sld_set_value(id: String, value: String) {
    let val = Double(value) ?? 0.0
    DispatchQueue.main.async {
        if let state = SwiftSliderLoader.states[id] {
            state.value = val
        }
    }
}

@HarbourBridge
public func sld_get_value(id: String) -> String {
    let val = SwiftSliderLoader.states[id]?.value ?? 0.0
    return String(val)
}

@HarbourBridge
public func sld_set_accent_color(id: String, hex: String) {
    DispatchQueue.main.async {
        if let state = SwiftSliderLoader.states[id] {
            state.accentColor = Color(hex: hex)
        }
    }
}

@HarbourBridge
public func sld_set_colors(id: String, fgHex: String, bgHex: String) {
    DispatchQueue.main.async {
        if let state = SwiftSliderLoader.states[id] {
            state.foregroundColor = Color(hex: fgHex)
            state.backgroundColor = Color(hex: bgHex)
        }
    }
}
