import SwiftUI
import AppKit
import Observation
import HarbourMacro

// MARK: - State for the TextField

@Observable
public class TextFieldState: HexColorableState, RGBAColorableState {
    var text: String
    var caption: String
    var placeholder: String
    var fontSize: CGFloat
    var textColor: Color 
    var backgroundColor: Color 
    var isSecure: Bool 
    var id: String
    var onAction: ((String) -> Void)?

    init(
        text: String = "", 
        caption: String = "", 
        placeholder: String = "", 
        id: String = "", 
        fontSize: CGFloat = 13.0,
        textColor: Color = .primary,
        backgroundColor: Color = .clear,
        isSecure: Bool = false,
        callback: ((String) -> Void)? = nil
    ) {
        self.text = text
        self.caption = caption
        self.placeholder = placeholder
        self.id = id
        self.fontSize = fontSize
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.isSecure = isSecure
        self.onAction = callback
    }

    // Modern Hex Color support
    public func setAccentColor(hex: String) {
        let block = { self.backgroundColor = Color(hex: hex) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public func setTextColor(hex: String) {
        let block = { self.textColor = Color(hex: hex) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    // Legacy RGBA support
    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        let block = { self.backgroundColor = Color(r: r, g: g, b: b, a: a) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        let block = { self.textColor = Color(r: r, g: g, b: b, a: a) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }
}

// MARK: - Initial State Decodable

public struct TextFieldInitialState: Codable {
    public let text: String
    public let caption: String?
    public let placeholder: String?
    public let fontsize: Double?
    public let textcolor: String?
    public let bgcolor: String?
    public let issecure: Bool?
}

// MARK: - SwiftUI View for the TextField

struct SwiftTextFieldView: View {
    @Bindable var state: TextFieldState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if !state.caption.isEmpty {
                Text(state.caption)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Group {
                if state.isSecure {
                    SecureField(state.placeholder, text: $state.text)
                } else {
                    TextField(state.placeholder, text: $state.text)
                }
            }
            .font(.system(size: state.fontSize))
            .foregroundColor(state.textColor)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .background(state.backgroundColor)
            .onChange(of: state.text) { _, newValue in
                 // Notificar a Harbour en tiempo real opcionalmente
                 // o esperar al onCommit según la clase Harbour.
                 state.onAction?(newValue)
            }
        }
        .padding(2)
    }
}

// MARK: - SwiftUI View for the TextEditor (Multi-line)

struct SwiftTextEditorView: View {
    @Bindable var state: TextFieldState
    
    var body: some View {
        TextEditor(text: $state.text)
            .font(.system(size: state.fontSize))
            .foregroundColor(state.textColor)
            .scrollContentBackground(.hidden)
            .background(state.backgroundColor)
            .onChange(of: state.text) { _, newValue in
                state.onAction?(newValue)
            }
            .padding(4)
            .border(Color.gray.opacity(0.2), width: 0.5)
    }
}

// MARK: - Loader & Memory Management

@objc(SwiftTextFieldLoader)
public class SwiftTextFieldLoader: NSObject {

    public static func makeTextField(id: String, json: String, isEditor: Bool = false, callback: @escaping ((String) -> Void)) -> NSView {
        let finalId = id.isEmpty ? UUID().uuidString : id
        
        let decoder = JSONDecoder()
        let initial = (try? decoder.decode(TextFieldInitialState.self, from: json.data(using: .utf8) ?? Data()))
        ?? TextFieldInitialState(text: "", caption: nil, placeholder: nil, fontsize: 13.0, textcolor: nil, bgcolor: nil, issecure: false)

        let state = TextFieldState(
            text: initial.text,
            caption: initial.caption ?? "",
            placeholder: initial.placeholder ?? "",
            id: finalId,
            fontSize: CGFloat(initial.fontsize ?? 13.0),
            textColor: Color(hex: initial.textcolor ?? "primary"),
            backgroundColor: Color(hex: initial.bgcolor ?? "clear"),
            isSecure: initial.issecure ?? false,
            callback: callback
        )
        
        ViewRegistry.register(state, for: finalId)
        
        let hostingView: NSHostingView<AnyView>
        if isEditor {
            hostingView = NSHostingView(rootView: AnyView(SwiftTextEditorView(state: state)))
        } else {
            hostingView = NSHostingView(rootView: AnyView(SwiftTextFieldView(state: state)))
        }
        
        hostingView.sizingOptions = []
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
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

// MARK: - Harbour Bridge Macros

@HarbourDirect 
@_cdecl("SD_TF_SET_TEXT")
public func tf_set_text(id: String, text: String) { 
    DispatchQueue.main.async { (ViewRegistry.getState(for: id) as? TextFieldState)?.text = text } 
}

@HarbourDirect 
@_cdecl("SD_TF_GET_TEXT")
public func tf_get_text(id: String) -> String { 
    return (ViewRegistry.getState(for: id) as? TextFieldState)?.text ?? "" 
}

@HarbourDirect 
@_cdecl("SD_TF_SET_ACCENT_COLOR")
public func tf_set_accent_color(id: String, hex: String) { 
    (ViewRegistry.getState(for: id) as? TextFieldState)?.setAccentColor(hex: hex) 
}

@HarbourDirect 
@_cdecl("SD_TF_SET_TEXT_COLOR")
public func tf_set_text_color(id: String, hex: String) { 
    (ViewRegistry.getState(for: id) as? TextFieldState)?.setTextColor(hex: hex) 
}

@HarbourDirect
@_cdecl("SD_TF_SET_FONT_SIZE")
public func tf_set_font_size(id: String, size: Double) { 
    DispatchQueue.main.async { (ViewRegistry.getState(for: id) as? TextFieldState)?.fontSize = CGFloat(size) } 
}

@HarbourDirect
@_cdecl("SD_TF_DESTROY")
public func tf_destroy(id: String, viewPtr: Int64) {
    SwiftTextFieldLoader.destroyTextField(id: id, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_textfield_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    json: String, 
    parentPtr: Int64,
    id: String
    ) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        let finalId = id.isEmpty ? UUID().uuidString : id
        let callback: (String) -> Void = { newText in
            DispatchQueue.main.async {
                SwiftBridge.onChange(finalId, newText)
            }
        }

        let fieldView = SwiftTextFieldLoader.makeTextField(id: finalId, json: json, isEditor: false, callback: callback)

        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            applySwiftViewLayout(swiftView: fieldView, parent: parentObj, top: top, left: left, w: width, h: height)
            viewAddress = Int64(Int(bitPattern: Unmanaged.passRetained(fieldView).toOpaque()))
        }
        
        return viewAddress
    }

    if Thread.isMainThread { return executeCreation() } else { return DispatchQueue.main.sync { executeCreation() } }
}

@HarbourDirect
public func swift_texteditor_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    json: String, 
    parentPtr: Int64,
    id: String
    ) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        let finalId = id.isEmpty ? UUID().uuidString : id
        let callback: (String) -> Void = { newText in
            DispatchQueue.main.async {
                SwiftBridge.onChange(finalId, newText)
            }
        }

        let editorView = SwiftTextFieldLoader.makeTextField(id: finalId, json: json, isEditor: true, callback: callback)

        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            applySwiftViewLayout(swiftView: editorView, parent: parentObj, top: top, left: left, w: width, h: height)
            viewAddress = Int64(Int(bitPattern: Unmanaged.passRetained(editorView).toOpaque()))
        }
        
        return viewAddress
    }

    if Thread.isMainThread { return executeCreation() } else { return DispatchQueue.main.sync { executeCreation() } }
}
