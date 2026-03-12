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

    public static func makeTextField(text: String, placeholder: String, id: String, index: Int, callback: @escaping (String) -> Void) -> NSView {
        let state = TextFieldState(text: text, placeholder: placeholder, id: id)
        state.onAction = callback
        
        states[id] = state 
        
        let view = SwiftTextFieldView(state: state)
        ViewRegistry.register(view, for: index)
        
        let hostingView = NSHostingView(rootView: view)
        hostingView.sizingOptions = []
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        return hostingView
    }

    public static func makeTextEditor(text: String, id: String, index: Int) -> NSView {
        let state = TextFieldState(text: text, id: id)
        states[id] = state
        
        let view = SwiftTextEditorView(state: state)
        ViewRegistry.register(view, for: index)

        let hostingView = NSHostingView(rootView: view)
        hostingView.sizingOptions = []
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        return hostingView
    }

    public static func destroyTextField(id: String, index: Int, viewPtr: Int64) {
        states.removeValue(forKey: id)
        ViewRegistry.clean(index:index) 
        
        if viewPtr != 0 {
            if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(viewPtr)) {
                let _ = Unmanaged<NSView>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourDirect
public func tf_set_text(id: String, text: String) {
    DispatchQueue.main.async {
        if let state = SwiftTextFieldLoader.states[id] {
            state.text = text
        }
    }
}

@HarbourDirect
public func tf_get_text(id: String) -> String {
    return SwiftTextFieldLoader.states[id]?.text ?? ""
}

@HarbourDirect
public func tf_set_colors(id: String, fgHex: String, bgHex: String) {
    DispatchQueue.main.async {
        if let state = SwiftTextFieldLoader.states[id] {
            state.textColor = Color(hex: fgHex)
            state.backgroundColor = Color(hex: bgHex)
        }
    }
}

@HarbourDirect
public func tf_set_font_size(id: String, size: Double) {
    DispatchQueue.main.async {
        if let state = SwiftTextFieldLoader.states[id] {
            state.fontSize = CGFloat(size)
        }
    }
}

@HarbourDirect
public func tf_destroy(id: String, index: Int, viewPtr: Int64) {
    SwiftTextFieldLoader.destroyTextField(id: id, index: index, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_textfield_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    text: String, 
    placeholder: String,
    parentPtr: Int64,
    index: Int,
    id: String
    ) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        
        let callback: (String) -> Void = { newText in
            let sendToHarbour = {
                if let pDynSym = hb_dynsymFindName("SWIFTTEXTFIELDONCHANGE") {
                    hb_vmPushSymbol(hb_dynsymSymbol(pDynSym))
                    hb_vmPushNil()
                    hb_vmPushNumber(Double(index), 0) 
                    hb_vmPushString(newText)
                    hb_vmDo(2)
                }
            }

            if Thread.isMainThread {
               sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }

        let fieldView = SwiftTextFieldLoader.makeTextField(
            text: text, 
            placeholder: placeholder,
            id: id,
            index: index, 
            callback: callback
        )
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: fieldView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(fieldView).toOpaque()
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

@HarbourDirect
public func swift_texteditor_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    text: String, 
    parentPtr: Int64,
    index: Int,
    id: String
    ) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        
        let fieldView = SwiftTextFieldLoader.makeTextEditor(
            text: text, 
            id: id,
            index: index
        )
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: fieldView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(fieldView).toOpaque()
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
