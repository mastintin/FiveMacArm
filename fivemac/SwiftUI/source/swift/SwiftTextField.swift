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

@available(OSX 11.0, *)
struct SwiftTextEditorView: View {
    @ObservedObject var state: TextFieldState
    
    var body: some View {
        TextEditor(text: $state.text)
            .font(.system(size: state.fontSize))
            .border(Color.gray.opacity(0.2))
    }
}

@objc(SwiftTextFieldLoader)
public class SwiftTextFieldLoader: NSObject {
    
    // Key is String (UUID)
    static var states: [String: TextFieldState] = [:]

    @objc(makeTextFieldWithText:placeholder:id:callback:)
    public static func makeTextField(text: String, placeholder: String, id: String, callback: @escaping (String) -> Void) -> NSView {
         if #available(OSX 10.15, *) {
            let state = TextFieldState(text: text, placeholder: placeholder, id: id)
            state.onAction = callback
            
            states[id] = state 
            
            let view = SwiftTextFieldView(state: state)
            
            if let index = Int(id.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                 ViewRegistry.register(view, for: index)
            }
            
            let hostingView = NSHostingView(rootView: view)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            return hostingView
        } else {
            return NSView()
        }
    }

    @objc(makeTextEditorWithText:id:)
    public static func makeTextEditor(text: String, id: String) -> NSView {
        if #available(OSX 11.0, *) {
            let state = TextFieldState(text: text, id: id)
            states[id] = state
            
            let view = SwiftTextEditorView(state: state)
            let hostingView = NSHostingView(rootView: view)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            return hostingView
        } else {
            return NSView()
        }
    }
    
    @objc(setText:id:)
    public static func setText(_ text: String, id: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = states[id] {
                    state.text = text
                }
            }
        }
    }
    
    @objc(getTextFromId:)
    public static func getText(fromId id: String) -> String {
        if #available(OSX 10.15, *) {
            if let state = states[id] {
                return state.text
            }
        }
        return ""
    }
}
