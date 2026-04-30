import SwiftUI
import AppKit
import Observation

@Observable
class AppState {
    var labelText: String = "Hello from SwiftUI!"
}

struct MyView: View {
    var state: AppState
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
    
    static var sharedState: Any? = nil

    @objc public static func makeView() -> NSView {
         return makeView(withCallback: nil)
    }
    
    @objc(makeViewWithCallback:)
    public static func makeView(withCallback callback: ((String) -> Void)?) -> NSView {
        let state = AppState()
        sharedState = state 
        
        let view = MyView(state: state, callback: callback)
        let hostingView = NSHostingView(rootView: view)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        return hostingView
    }
    
    @objc(updateLabel:)
    public static func updateLabel(_ text: String) {
        DispatchQueue.main.async {
            if let state = sharedState as? AppState {
                state.labelText = text
            }
        }
    }
}
