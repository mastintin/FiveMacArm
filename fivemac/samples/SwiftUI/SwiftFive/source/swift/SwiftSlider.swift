import SwiftUI
import AppKit

// State for the Slider
@available(OSX 10.15, *)
class SliderState: ObservableObject {
    @Published var value: Double
    var callback: ((Double) -> Void)?
    
    init(value: Double, callback: ((Double) -> Void)?) {
        self.value = value
        self.callback = callback
    }
}

// SwiftUI View for the Slider
@available(OSX 10.15, *)
struct SwiftSliderView: View {
    @ObservedObject var state: SliderState

    var body: some View {
        VStack {
            Slider(value: Binding(
                get: { self.state.value },
                set: { newValue in
                    self.state.value = newValue
                    self.state.callback?(newValue)
                }
            ), in: 0...100)
            .padding()
            
            Text("Value: \(Int(state.value))")
                .font(.caption)
        }
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
    }
}

@objc(SwiftSliderLoader)
public class SwiftSliderLoader: NSObject {
    
    @objc(makeSliderWithValue:index:callback:)
    public static func makeSlider(value: NSNumber, index: Int, callback: @escaping ((NSNumber) -> Void)) -> NSView {
        if #available(OSX 10.15, *) {
            let doubleVal = value.doubleValue
            
            // Adapt callback to take Double, output NSNumber
            let swiftCallback: (Double) -> Void = { val in
                callback(NSNumber(value: val))
            }
            
            let state = SliderState(value: doubleVal, callback: swiftCallback)
            let view = SwiftSliderView(state: state)
            
            // Register
            ViewRegistry.register(view, for: index)
            
            let hostingView = NSHostingView(rootView: view)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            return hostingView
        } else {
            return NSView()
        }
    }
}
