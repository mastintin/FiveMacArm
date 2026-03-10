import SwiftUI
import AppKit
import Observation
import HarbourMacro

@Observable
public class TextFieldState {
    var text: String = ""
    var placeholder: String = ""
    var fontSize: CGFloat = 13.0
    
    var onAction: ((String) -> Void)? = nil
    var id: String = ""
    var textColor: Color = .primary
    var backgroundColor: Color = .clear
    
    init(text: String = "", placeholder: String = "", id: String = "") {
        self.text = text
        self.placeholder = placeholder
        self.id = id
    }
}

struct SwiftTextFieldView: View {
    var state: TextFieldState
    
    var body: some View {
        let textBinding = Binding(
            get: { state.text },
            set: { state.text = $0 }
        )
        
        TextField(state.placeholder, text: textBinding, onEditingChanged: { isEditing in
            if !isEditing {
                print("DEBUG: [Swift] TextField Editing Finished. Final text: \(state.text)")
                state.onAction?(state.text)
            }
        }, onCommit: {
            print("DEBUG: [Swift] TextField Committed with Enter. Text: \(state.text)")
            state.onAction?(state.text)
        })
        .font(.system(size: state.fontSize))
        .foregroundColor(state.textColor)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .background(state.backgroundColor)
    }
}

struct SwiftTextEditorView: View {
    var state: TextFieldState
    
    var body: some View {
        let textBinding = Binding(
            get: { state.text },
            set: { state.text = $0 }
        )
        
        TextEditor(text: textBinding)
            .font(.system(size: state.fontSize))
            .foregroundColor(state.textColor)
            .scrollContentBackground(.hidden)
            .background(state.backgroundColor)
            .border(Color.gray.opacity(0.2))
    }
}

@objc(SwiftTextFieldLoader)
public class SwiftTextFieldLoader: NSObject {
    
    public static var states: [String: TextFieldState] = [:]

    @objc(makeTextFieldWithText:placeholder:id:callback:)
    public static func makeTextField(text: String, placeholder: String, id: String, callback: @escaping (String) -> Void) -> NSView {
        let state = TextFieldState(text: text, placeholder: placeholder, id: id)
        state.onAction = callback
        
        SwiftTextFieldLoader.states[id] = state 
        
        let view = SwiftTextFieldView(state: state)
        
        if let index = Int(id.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
             ViewRegistry.register(view, for: index)
        }
        
        let hostingView = NSHostingView(rootView: view)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        return hostingView
    }

    @objc(makeTextEditorWithText:id:)
    public static func makeTextEditor(text: String, id: String) -> NSView {
        let state = TextFieldState(text: text, id: id)
        SwiftTextFieldLoader.states[id] = state
        
        let view = SwiftTextEditorView(state: state)
        let hostingView = NSHostingView(rootView: view)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        return hostingView
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourBridge
public func tf_set_text(id: String, text: String) {
    DispatchQueue.main.async {
        if let state = SwiftTextFieldLoader.states[id] {
            state.text = text
        }
    }
}

@HarbourBridge
@discardableResult
public func tf_get_text(id: String) -> String {
    return SwiftTextFieldLoader.states[id]?.text ?? ""
}

@HarbourBridge
public func tf_set_colors(id: String, fgHex: String, bgHex: String) {
    DispatchQueue.main.async {
        if let state = SwiftTextFieldLoader.states[id] {
            state.textColor = Color(hex: fgHex)
            state.backgroundColor = Color(hex: bgHex)
        }
    }
}

@HarbourBridge
public func tf_set_font_size(id: String, size: String) {
    let nSize = CGFloat(Double(size) ?? 13.0)
    DispatchQueue.main.async {
        if let state = SwiftTextFieldLoader.states[id] {
            state.fontSize = nSize
        }
    }
}
