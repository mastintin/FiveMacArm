import SwiftUI
import AppKit

@available(OSX 10.15, *)
class AppState: ObservableObject {
    @Published var labelText: String = "Hello from SwiftUI!"
}

@available(OSX 10.15, *)
struct MyView: View {
    @ObservedObject var state: AppState
    @State private var count = 0
    var callback: ((String) -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Text(state.labelText)
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text("This is a native SwiftUI View embedded in FiveMac.")
                .padding()
            
            HStack {
                Button(action: {
                    print("Button pressed")
                    self.count += 1
                    // Call the callback if it exists
                    self.callback?("Button pressed! Count: \(self.count)")
                }) {
                    Text("Click Me")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Text("Count: \(count)")
                    .font(.title)
            }
            
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.yellow)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

@objc public class SwiftLoader: NSObject {
    
    // Shared state instance
    static var sharedState: Any? = nil

    @objc public static func makeView() -> NSView {
         return makeView(withCallback: nil)
    }
    
    // Explicit selector name to match what we expect in ObjC
    @objc(makeViewWithCallback:)
    public static func makeView(withCallback callback: ((String) -> Void)?) -> NSView {
         if #available(OSX 10.15, *) {
            let state = AppState()
            sharedState = state // Store reference
            
            let view = MyView(state: state, callback: callback)
            let hostingView = NSHostingView(rootView: view)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            return hostingView
         } else {
             let label = NSTextField(labelWithString: "SwiftUI not available on this OS version")
             return label
         }
    }
    
    @objc(updateLabel:)
    public static func updateLabel(_ text: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = sharedState as? AppState {
                    state.labelText = text
                }
            }
        }
    }
}
