import SwiftUI
import AppKit

// State for the Slider
@available(OSX 10.15, *)
class SliderState: ObservableObject {
    @Published var value: Double
    @Published var showValue: Bool
    @Published var isGlass: Bool
    var callback: ((Double) -> Void)?
    
    init(value: Double, showValue: Bool, isGlass: Bool, callback: ((Double) -> Void)?) {
        self.value = value
        self.showValue = showValue
        self.isGlass = isGlass
        self.callback = callback
    }
}

// SwiftUI View for the Slider
@available(OSX 10.15, *)
struct SwiftSliderView: View {
    @ObservedObject var state: SliderState

    var body: some View {
        let sliderBinding = Binding(
            get: { self.state.value },
            set: { newValue in
                self.state.value = newValue
                self.state.callback?(newValue)
            }
        )
       
        VStack {
           

            if #available(macOS 26.2, *), state.isGlass {
                ZStack {
                     // 1. Glass Rail (Background Track)
                     Capsule()
                         .fill(.ultraThinMaterial)
                         .frame(height: 4)
                         .shadow(color: .white.opacity(0.5), radius: 0, x: 0, y: 1)
                    
                     // 2. The Slider itself
                     Slider(value: sliderBinding, in: 0...100)
                        .glassEffect(.regular.interactive())
                        .tint(.blue.opacity(0.8))
                }
                .contentShape(Capsule())
            } else {
                 Slider(value: sliderBinding, in: 0...100)
            }
            if state.showValue {
                Text("Value: \(Int(state.value))")
                    .font(.caption)
            }
        }
       
        .padding()
        .background(
             Group {
                 if state.isGlass {
                     Color.clear
                 } else {
                    Color.clear
                     //Color.white.opacity(0.5)
                     .cornerRadius(8)
                 }
             }
        )
    }
}

@objc(SwiftSliderLoader)
public class SwiftSliderLoader: NSObject {
    
    // CRITICAL: Dictionary to prevent Index Collision
    // HYBRID MIGRATION: Key is String to support both "123" (legacy indices) and "UUID-..."
    static var states: [String: SliderState] = [:]
    
    @objc(makeSliderWithValue:id:showValue:isGlass:index:callback:)
    public static func makeSlider(value: NSNumber, id: String, showValue: Bool, isGlass: Bool, index: Int, callback: @escaping ((NSNumber) -> Void)) -> NSView {
        if #available(OSX 10.15, *) {
            let doubleVal = value.doubleValue
            
            // Adapt callback to take Double, output NSNumber
            let swiftCallback: (Double) -> Void = { val in
                callback(NSNumber(value: val))
            }
            
            let state = SliderState(value: doubleVal, showValue: showValue, isGlass: isGlass, callback: swiftCallback)
            
            // HYBRID: Use ID if provided, otherwise fallback to String(index)
            let key = id.isEmpty ? String(index) : id
            
            states[key] = state // Store in Dictionary using String key
            
            let view = SwiftSliderView(state: state)
            
            // Register
            ViewRegistry.register(view, for: index)
            
            let hostingView = NSHostingView(rootView: view)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            hostingView.wantsLayer = true
            hostingView.layer?.backgroundColor = NSColor.clear.cgColor
            
            return hostingView
        } else {
            return NSView()
        }
    }
    
    @objc(setSliderValue:id:)
    public static func setSliderValue(_ value: Double, id: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = states[id] {
                    state.objectWillChange.send() // Explicitly notify view
                    state.value = value
                }
            }
        }
    }
    
    @objc(getSliderValueFromIndex:)
    public static func getSliderValue(fromIndex index: Int) -> Double {
        if #available(OSX 10.15, *) {
            let key = String(index)
            if let state = states[key] {
                return state.value
            }
        }
        return 0.0
    }
}
