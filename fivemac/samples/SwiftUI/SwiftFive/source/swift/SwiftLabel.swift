import SwiftUI
import AppKit

// State for the Label
@available(OSX 10.15, *)
class LabelState: ObservableObject {
    @Published var text: String
    @Published var fontSize: CGFloat
    @Published var fontStyle: String // Empty means use fontSize
    @Published var textColor: Color
    
    init(text: String, fontSize: CGFloat = 24.0, fontStyle: String = "", textColor: Color = .black) {
        self.text = text
        self.fontSize = fontSize
        self.fontStyle = fontStyle
        self.textColor = textColor
    }
}

// Helper to parse hex color
@available(OSX 10.15, *)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// New SwiftUI View for the label
@available(OSX 10.15, *)
struct SwiftLabelView: View {
    @ObservedObject var state: LabelState

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
    
    // Simplistic approach: Keep track of the last created state to update it.
    // In a real app with multiple labels, we'd need a map or ID system.
    static var sharedState: Any? = nil
    
    @objc(makeLabelWithText:index:)
    public static func makeLabel(text: String, index: Int) -> NSView {
         if #available(OSX 10.15, *) {
             // Default state
            let state = LabelState(text: text, fontSize: 24.0, fontStyle: "", textColor: .black)
            sharedState = state
            
            let view = SwiftLabelView(state: state)
            
            // Register
            ViewRegistry.register(view, for: index)
            
            let hostingView = NSHostingView(rootView: view)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            return hostingView
        } else {
            return NSView()
        }
    }
    
    @objc(updateLabel:)
    public static func updateLabel(_ text: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = sharedState as? LabelState {
                    state.text = text
                }
            }
        }
    }

    @objc(setLabelFontSize:)
    public static func setLabelFontSize(_ size: Double) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = sharedState as? LabelState {
                    state.fontSize = CGFloat(size)
                    state.fontStyle = "" // Clear style to usage size
                }
            }
        }
    }

    @objc(setLabelFontStyle:)
    public static func setLabelFontStyle(_ style: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = sharedState as? LabelState {
                    state.fontStyle = style
                }
            }
        }
    }

    @objc(setLabelTextColor:)
    public static func setLabelTextColor(_ colorHex: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = sharedState as? LabelState {
                    state.textColor = Color(hex: colorHex)
                }
            }
        }
    }
}
