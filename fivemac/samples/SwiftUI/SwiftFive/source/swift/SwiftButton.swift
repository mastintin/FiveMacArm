import SwiftUI
import AppKit

@available(OSX 10.15, *)
// State for the Button
@available(OSX 10.15, *)
class ButtonState: ObservableObject {
    @Published var title: String
    @Published var backgroundColor: Color
    @Published var foregroundColor: Color
    @Published var cornerRadius: CGFloat
    @Published var padding: CGFloat
    
    init(title: String, backgroundColor: Color = .blue, foregroundColor: Color = .white, cornerRadius: CGFloat = 8, padding: CGFloat = 0) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
}

// Helper to parse hex color (Duplicated from SwiftLabel.swift to avoid dependency issues)
@available(OSX 10.15, *)
extension Color {
    init(hexBtn: String) { // Renamed to avoid potential conflict if in same module scope
        let hex = hexBtn.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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

@available(OSX 10.15, *)
struct SwiftButtonView: View {
    @ObservedObject var state: ButtonState
    var callback: (() -> Void)?
    
    var body: some View {
        Button(action: {
            self.callback?()
        }) {
            Text(state.title)
                .padding(state.padding > 0 ? state.padding : 10) // Default padding if 0? Or just use value
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(state.backgroundColor)
                .foregroundColor(state.foregroundColor)
                .cornerRadius(state.cornerRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

@objc(SwiftButtonLoader)
public class SwiftButtonLoader: NSObject {
    
    static var lastCreatedState: Any? = nil

    @objc(makeButtonWithTitle:index:callback:)
    public static func makeButton(title: String, index: Int, callback: ((String) -> Void)?) -> NSView {
         if #available(OSX 10.15, *) {
             let state = ButtonState(title: title)
             lastCreatedState = state
             
             // Adapt callback
             let action: () -> Void = {
                 _ = callback?("Click")
             }
             
             let view = SwiftButtonView(state: state, callback: action)
             
             // Register in Registry
             ViewRegistry.register(view, for: index)
             
             let hostingView = NSHostingView(rootView: view)
             hostingView.translatesAutoresizingMaskIntoConstraints = false
             return hostingView
         } else {
             return NSView()
         }
    }

    @objc(setButtonBackgroundColor:)
    public static func setButtonBackgroundColor(_ colorHex: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? ButtonState {
                    state.backgroundColor = Color(hexBtn: colorHex)
                }
            }
        }
    }

    @objc(setButtonForegroundColor:)
    public static func setButtonForegroundColor(_ colorHex: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? ButtonState {
                    state.foregroundColor = Color(hexBtn: colorHex)
                }
            }
        }
    }

    @objc(setButtonCornerRadius:)
    public static func setButtonCornerRadius(_ radius: Double) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? ButtonState {
                    state.cornerRadius = CGFloat(radius)
                }
            }
        }
    }
    
    @objc(setButtonPadding:)
    public static func setButtonPadding(_ padding: Double) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? ButtonState {
                    state.padding = CGFloat(padding)
                }
            }
        }
    }
}
