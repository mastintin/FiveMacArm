import SwiftUI
import AppKit
import Observation
import HarbourMacro

// MARK: - State for the Label

@Observable
public class LabelState: HexColorableState, RGBAColorableState {
    var caption: String
    var fontSize: CGFloat
    var fontStyle: String 
    var accentColor: Color 
    var textColor: Color 
    var alignment: TextAlignment 
    var isBold: Bool
    var isGlass: Bool

    init(
        caption: String, 
        fontSize: CGFloat = 14.0, 
        fontStyle: String = "", 
        textColor: Color = .primary,
        accentColor: Color = .clear,
        alignment: TextAlignment = .leading,
        isBold: Bool = false,
        isGlass: Bool = false
    ) {
        self.caption = caption
        self.fontSize = fontSize
        self.fontStyle = fontStyle
        self.textColor = textColor
        self.accentColor = accentColor
        self.alignment = alignment
        self.isBold = isBold
        self.isGlass = isGlass
    }

    // Modern Hex Color support
    public func setAccentColor(hex: String) {
        let block = { self.accentColor = Color(hex: hex) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public func setTextColor(hex: String) {
        let block = { self.textColor = Color(hex: hex) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    // Legacy RGBA support
    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        let block = { self.accentColor = Color(r: r, g: g, b: b, a: a) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        let block = { self.textColor = Color(r: r, g: g, b: b, a: a) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }
}

// MARK: - Initial State Decodable

public struct LabelInitialState: Codable {
    public let caption: String
    public let fontsize: Double?
    public let fontstyle: String?
    public let textcolor: String?
    public let bgcolor: String?
    public let alignment: Int?
    public let isbold: Bool?
    public let isglass: Bool?
}

// MARK: - SwiftUI View for the Label

struct SwiftLabelView: View {
    @Bindable var state: LabelState

    func getFont() -> Font {
        let baseFont: Font
        switch state.fontStyle {
        case "largeTitle": baseFont = .largeTitle
        case "title": baseFont = .title
        case "headline": baseFont = .headline
        case "subheadline": baseFont = .subheadline
        case "body": baseFont = .body
        case "callout": baseFont = .callout
        case "footnote": baseFont = .footnote
        case "caption": baseFont = .caption
        default: baseFont = .system(size: state.fontSize)
        }
        return state.isBold ? baseFont.bold() : baseFont
    }

    var body: some View {
        Text(state.caption)
            .font(getFont())
            .foregroundColor(state.textColor)
            .multilineTextAlignment(state.alignment)
            .frame(maxWidth: .infinity, maxHeight: .infinity, 
                   alignment: state.alignment == .center ? .center : (state.alignment == .trailing ? .trailing : .leading))
            .background(
                Group {
                    if state.isGlass {
                        VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                    } else {
                        state.accentColor
                    }
                }
            )
    }
}

// MARK: - Loader & Memory Management

@objc(SwiftLabelLoader)
public class SwiftLabelLoader: NSObject {
    
    // TEST: REMOVED static states dictionary to check for fragility

    public static func makeLabel(id: String, json: String) -> NSView {
        let finalId = id.isEmpty ? UUID().uuidString : id
        
        let decoder = JSONDecoder()
        let initial = (try? decoder.decode(LabelInitialState.self, from: json.data(using: .utf8) ?? Data()))
        ?? LabelInitialState(caption: "Label", fontsize: 14.0, fontstyle: "", textcolor: nil, bgcolor: nil, alignment: 0, isbold: false, isglass: false)

        let align: TextAlignment
        switch initial.alignment ?? 0 {
            case 1: align = .center
            case 2: align = .trailing
            default: align = .leading
        }

        let state = LabelState(
            caption: initial.caption,
            fontSize: CGFloat(initial.fontsize ?? 14.0),
            fontStyle: initial.fontstyle ?? "",
            textColor: Color(hex: initial.textcolor ?? "primary"),
            accentColor: Color(hex: initial.bgcolor ?? "clear"),
            alignment: align,
            isBold: initial.isbold ?? false,
            isGlass: initial.isglass ?? false
        )
        
        // TEST: REMOVED registration to global states
        ViewRegistry.register(state, for: finalId)
        
        let labelView = SwiftLabelView(state: state)
        let hostingView = NSHostingView(rootView: labelView)
        hostingView.sizingOptions = []
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
        
        return hostingView
    }

    public static func destroyLabel(id: String, viewPtr: Int64) {
        ViewRegistry.clean(id: id)
        if viewPtr != 0 {
            if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
                _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }
}

// MARK: - Harbour Bridge Macros

@HarbourDirect public func lbl_set_text(id: String, text: String) { 
    DispatchQueue.main.async { 
        if let state = ViewRegistry.getState(for: id) as? LabelState {
            state.caption = text 
        }
    } 
}
@HarbourDirect public func lbl_set_font_size(id: String, size: Double) { 
    DispatchQueue.main.async { 
        if let state = ViewRegistry.getState(for: id) as? LabelState {
            state.fontSize = CGFloat(size)
        }
    } 
}
@HarbourDirect public func lbl_set_bold(id: String, bold: Bool) { 
    DispatchQueue.main.async { 
        if let state = ViewRegistry.getState(for: id) as? LabelState {
            state.isBold = bold 
        }
    } 
}

@HarbourDirect public func lbl_set_accent_color(id: String, hex: String) { 
    if let state = ViewRegistry.getState(for: id) as? LabelState {
        state.setAccentColor(hex: hex)
    } 
}
@HarbourDirect public func lbl_set_text_color(id: String, hex: String) { 
    if let state = ViewRegistry.getState(for: id) as? LabelState {
        state.setTextColor(hex: hex)
    } 
}

@HarbourDirect
public func lbl_destroy(id: String, viewPtr: Int64) {
    SwiftLabelLoader.destroyLabel(id: id, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_label_create(
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
        
        let labelView = SwiftLabelLoader.makeLabel(
            id: finalId, 
            json: json
        )

        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            applySwiftViewLayout(swiftView: labelView, parent: parentObj, top: top, left: left, w: width, h: height)
            viewAddress = Int64(Int(bitPattern: Unmanaged.passRetained(labelView).toOpaque()))
        }
        
        return viewAddress
    }

    if Thread.isMainThread { return executeCreation() } else { return DispatchQueue.main.sync { executeCreation() } }
}