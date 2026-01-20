import SwiftUI
import AppKit

@available(OSX 10.15, *)
class TextFieldState: ObservableObject {
    @Published var text: String = ""
    @Published var placeholder: String = ""
    @Published var fontSize: CGFloat = 13.0
    
    var onAction: ((String) -> Void)? = nil
    var id: String = ""
    
    init(text: String = "", placeholder: String = "", id: String = "") {
        self.text = text
        self.placeholder = placeholder
        self.id = id
    }
}

@available(OSX 10.15, *)
struct SwiftTextFieldView: View {
    @ObservedObject var state: TextFieldState
    
    var body: some View {
        TextField(state.placeholder, text: $state.text, onEditingChanged: { isEditing in
            if !isEditing {
                print("DEBUG: [Swift] TextField Editing Finished. Final text: \(state.text)")
                state.onAction?(state.text)
            }
        }, onCommit: {
            print("DEBUG: [Swift] TextField Committed with Enter. Text: \(state.text)")
            state.onAction?(state.text)
        })
        .font(.system(size: state.fontSize))
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

@objc(SwiftTextFieldLoader)
public class SwiftTextFieldLoader: NSObject {
    
    // CRITICAL: Dictionary to prevent Index Collision
    // HYBRID MIGRATION: Key is String to support both "123" (legacy indices) and "UUID-..."
    static var states: [String: TextFieldState] = [:]

    @objc(makeTextFieldWithText:placeholder:id:index:callback:)
    public static func makeTextField(text: String, placeholder: String, id: String, index: Int, callback: @escaping (String) -> Void) -> NSView {
         if #available(OSX 10.15, *) {
            let state = TextFieldState(text: text, placeholder: placeholder, id: id)
            state.onAction = callback
            
            let key = String(index)
            states[key] = state // Store in Dictionary using String key
            
            let view = SwiftTextFieldView(state: state)
            
            // Register view for layout
            ViewRegistry.register(view, for: index)
            
            let hostingView = NSHostingView(rootView: view)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            return hostingView
        } else {
            return NSView()
        }
    }
    
    @objc(setText:index:)
    public static func setText(_ text: String, index: Int) {
        if #available(OSX 10.15, *) {
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    print("DEBUG: [Swift] Setting text for index \(index) (key: \(key)): \(text)")
                    state.text = text
                }
            }
        }
    }
    
    @objc(getTextFromIndex:)
    public static func getText(fromIndex index: Int) -> String {
        if #available(OSX 10.15, *) {
            let key = String(index)
            if let state = states[key] {
                 print("DEBUG: [Swift] Getting text for index \(index) (key: \(key)): \(state.text)")
                return state.text
            }
        }
        return ""
    }
}
