import SwiftUI
import AppKit
import Observation
import HarbourMacro

// State for the Label
@Observable
public class LabelState {
    var text: String
    var fontSize: CGFloat
    var fontStyle: String // Empty means use fontSize
    var textColor: Color
    
    init(text: String, fontSize: CGFloat = 24.0, fontStyle: String = "", textColor: Color = .black) {
        self.text = text
        self.fontSize = fontSize
        self.fontStyle = fontStyle
        self.textColor = textColor
    }
}



// New SwiftUI View for the label
struct SwiftLabelView: View {
    var state: LabelState

    func getFont() -> Font {
        switch state.fontStyle {
        case "largeTitle": return .largeTitle
        case "title": return .title
        case "headline": return .headline
        case "subheadline": return .subheadline
        case "body": return .body
        case "callout": return .callout
        case "footnote": return .footnote
        case "caption": return .caption
        default: return .system(size: state.fontSize)
        }
    }

    var body: some View {
        Text(state.text)
            .font(getFont())
            .foregroundColor(state.textColor)
    }
}

@objc(SwiftLabelLoader)
public class SwiftLabelLoader: NSObject {
    
    // Store states by Index (String for Hybrid Support)
    public static var states: [String: LabelState] = [:]
    
    @objc(makeLabelWithText:index:)
    public static func makeLabel(text: String, index: Int) -> NSView {
         // Default state
        let state = LabelState(text: text, fontSize: 24.0, fontStyle: "", textColor: .black)
        let key = String(index)
        states[key] = state
        
        let view = SwiftLabelView(state: state)
        ViewRegistry.register(view, for: index)
        
        let hostingView = NSHostingView(rootView: view)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        return hostingView
    }
    
    @objc(updateLabel:index:)
    public static func updateLabel(_ text: String, index: Int) {
        let key = String(index)
        DispatchQueue.main.async {
            if let state = states[key] {
                state.text = text
            }
        }
    }

    @objc(setLabelFontSize:index:)
    public static func setLabelFontSize(_ size: Double, index: Int) {
        let key = String(index)
        DispatchQueue.main.async {
            if let state = states[key] {
                state.fontSize = CGFloat(size)
                state.fontStyle = "" // Clear style to usage size
            }
        }
    }

    @objc(setLabelFontStyle:index:)
    public static func setLabelFontStyle(_ style: String, index: Int) {
        let key = String(index)
        DispatchQueue.main.async {
            if let state = states[key] {
                state.fontStyle = style
            }
        }
    }

    @objc(setLabelTextColor:index:)
    public static func setLabelTextColor(_ colorHex: String, index: Int) {
        let key = String(index)
        DispatchQueue.main.async {
            if let state = states[key] {
                state.textColor = Color(hex: colorHex)
            }
        }
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourBridge
public func lbl_set_text(index: String, text: String) {
    SwiftLabelLoader.updateLabel(text, index: Int(index) ?? 0)
}

@HarbourBridge
public func lbl_set_font(index: String, size: String) {
    SwiftLabelLoader.setLabelFontSize(Double(size) ?? 24.0, index: Int(index) ?? 0)
}

@HarbourBridge
public func lbl_set_color(index: String, hexColor: String) {
    SwiftLabelLoader.setLabelTextColor(hexColor, index: Int(index) ?? 0)
}
