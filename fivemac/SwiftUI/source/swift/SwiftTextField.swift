import SwiftUI
import AppKit
import Observation
import HarbourMacro

@Observable
public class TextFieldState: RGBAColorableState {
    var text: String = ""
    var caption: String = ""
    var placeholder: String = ""
    var fontSize: CGFloat = 13.0
    
    var onAction: ((String) -> Void)? = nil
    var id: String = ""
    var textColor: Color = .primary
    var backgroundColor: Color = .clear
    
    init(text: String = "", caption: String = "", placeholder: String = "", id: String = "", callback: ((String) -> Void)? = nil) {
        self.text = text
        self.caption = caption
        self.placeholder = placeholder
        self.id = id
        self.onAction = callback
    }

    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        DispatchQueue.main.async {
            self.backgroundColor = Color(r: r, g: g, b: b, a: a)
        }
    }

    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        DispatchQueue.main.async {
            self.textColor = Color(r: r, g: g, b: b, a: a)
        }
    }
}

struct SwiftTextFieldView: View {
    var state: TextFieldState
    
    var body: some View {
        let textBinding = Binding(
            get: { state.text },
            set: { state.text = $0 }
        )
        
        VStack(alignment: .leading, spacing: 2) {
            if !state.caption.isEmpty {
                Text(state.caption)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            TextField(state.placeholder, text: textBinding, onEditingChanged: { isEditing in
                if !isEditing {
                    state.onAction?(state.text)
                }
            }, onCommit: {
                state.onAction?(state.text)
            })
            .font(.system(size: state.fontSize))
            .foregroundColor(state.textColor)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .background(state.backgroundColor)
        }
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
            .onChange(of: state.text) { _, newValue in
                state.onAction?(newValue)
            }
    }
}

@objc(SwiftTextFieldLoader)
public class SwiftTextFieldLoader: NSObject {

    public static func makeTextField(text: String, caption: String, placeholder: String, id: String, callback: @escaping ((String) -> Void)) -> NSView {
        let finalId = id.isEmpty ? UUID().uuidString : id
        let state = TextFieldState(text: text, caption: caption, placeholder: placeholder, id: finalId, callback: callback)
        
        // Register in central registry
        ViewRegistry.register(state, for: finalId)
        
        let view = SwiftTextFieldView(state: state)
        ViewRegistry.register(view, for: finalId)
        
        let hostingView = NSHostingView(rootView: view)
        hostingView.sizingOptions = []
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
        return hostingView
    }

    public static func makeTextEditor(text: String, id: String, callback: @escaping ((String) -> Void)) -> NSView {
        let finalId = id.isEmpty ? UUID().uuidString : id
        let state = TextFieldState(text: text, id: finalId, callback: callback)
        
        // Register in central registry
        ViewRegistry.register(state, for: finalId)
        
        let view = SwiftTextEditorView(state: state)
        ViewRegistry.register(view, for: finalId)
        ViewRegistry.register(state, for: finalId)

        let hostingView = NSHostingView(rootView: view)
        hostingView.sizingOptions = []
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
        return hostingView
    }

    public static func destroyTextField(id: String, viewPtr: Int64) {
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
public func tf_set_text(id: String, text: String) {
    let block = {
        if let state = ViewRegistry.getState(for: id) as? TextFieldState {
            state.text = text
        }
    }
    if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
}

@HarbourDirect
public func tf_get_text(id: String) -> String {
    return (ViewRegistry.getState(for: id) as? TextFieldState)?.text ?? ""
}

@HarbourDirect
public func tf_set_colors(id: String, fgHex: String, bgHex: String) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? TextFieldState {
            state.textColor = Color(hex: fgHex)
            state.backgroundColor = Color(hex: bgHex)
        }
    }
}

@HarbourDirect
public func tf_set_font_size(id: String, size: Double) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? TextFieldState {
            state.fontSize = CGFloat(size)
        }
    }
}

@HarbourDirect
public func tf_destroy(id: String, viewPtr: Int64) {
    SwiftTextFieldLoader.destroyTextField(id: id, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_textfield_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    text: String, 
    caption: String,
    placeholder: String,
    parentPtr: Int64,
    id: String
    ) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        let finalId = id.isEmpty ? UUID().uuidString : id
        
        let callback: (String) -> Void = { newText in
            let sendToHarbour = {
                SwiftBridge.onChange(finalId, newText)
            }

            if Thread.isMainThread {
               sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }

        let fieldView = SwiftTextFieldLoader.makeTextField(
            text: text, 
            caption: caption,
            placeholder: placeholder,
            id: finalId,
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
    id: String
    ) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        let finalId = id.isEmpty ? UUID().uuidString : id
        
        let callback: (String) -> Void = { newText in
            let sendToHarbour = {
                SwiftBridge.onChange(finalId, newText)
            }

            if Thread.isMainThread {
               sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }

        let fieldView = SwiftTextFieldLoader.makeTextEditor(
            text: text, 
            id: finalId,
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
