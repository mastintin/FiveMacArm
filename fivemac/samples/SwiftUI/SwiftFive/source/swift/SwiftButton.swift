import SwiftUI
import AppKit

@available(OSX 10.15, *)
class ButtonState: ObservableObject {
    @Published var title: String
    @Published var backgroundColor: Color
    @Published var foregroundColor: Color
    @Published var cornerRadius: CGFloat
    @Published var padding: CGFloat
    @Published var isGlass: Bool
    @Published var imageName: String

    init(title: String, backgroundColor: Color = .blue, foregroundColor: Color = .white, cornerRadius: CGFloat = 8, padding: CGFloat = 0, isGlass: Bool = false, imageName: String = "") {
        self.title = title
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.isGlass = isGlass
        self.imageName = imageName
    }
}

@available(OSX 10.15, *)
extension Color {
    init(hexBtn: String) {
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
        if #available(macOS 26.2, *), state.isGlass {
            // 1. Native Tahoe Glass (User provided implementation)
            Button(action: {
                self.callback?()
            }) {
                HStack {
                    if !state.imageName.isEmpty {
                        Image(systemName: state.imageName)
                    }
                    Text(state.title)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(state.backgroundColor.opacity(0.8))
            .clipShape(Capsule())
            .glassEffect(.regular, in: Capsule())
            .contentShape(Capsule())
        } else {
             // 2. Normal / Standard Style
             Button(action: {
                 self.callback?()
             }) {
                 HStack {
                    if !state.imageName.isEmpty {
                        Image(systemName: state.imageName)
                    }
                    Text(state.title)
                 }
                 .padding(state.padding > 0 ? state.padding : 10)
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .background(state.backgroundColor)
                 .foregroundColor(state.foregroundColor)
                 .cornerRadius(state.cornerRadius)
             }
             .buttonStyle(PlainButtonStyle())
             .contentShape(Rectangle())
        }
    }
}

@objc(SwiftButtonLoader)
public class SwiftButtonLoader: NSObject {
    
    // CRITICAL: Use Dictionary to prevent Index Collision
    // HYBRID MIGRATION: Key is String to support both "123" (legacy indices) and "UUID-..."
    static var states: [String: ButtonState] = [:]

    @objc(makeButtonWithTitle:index:callback:)
    public static func makeButton(title: String, index: Int, callback: ((String) -> Void)?) -> NSView {
         if #available(OSX 10.15, *) {
             let state = ButtonState(title: title)
             let key = String(index)
             states[key] = state // Store in Dictionary using String key
             
             let action: () -> Void = {
                 _ = callback?("Click")
             }
             
             let view = SwiftButtonView(state: state, callback: action)
             ViewRegistry.register(view, for: index)
             
             let hostingView = NSHostingView(rootView: view)
             hostingView.translatesAutoresizingMaskIntoConstraints = false
             return hostingView
         } else {
             return NSView()
         }
    }

    @objc(setButtonBackgroundColor:index:)
    public static func setButtonBackgroundColor(_ colorHex: String, index: Int) {
        if #available(OSX 10.15, *) {
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.backgroundColor = Color(hexBtn: colorHex)
                }
            }
        }
    }

    @objc(setButtonForegroundColor:index:)
    public static func setButtonForegroundColor(_ colorHex: String, index: Int) {
        if #available(OSX 10.15, *) {
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.foregroundColor = Color(hexBtn: colorHex)
                }
            }
        }
    }

    @objc(setButtonCornerRadius:index:)
    public static func setButtonCornerRadius(_ radius: Double, index: Int) {
        if #available(OSX 10.15, *) {
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.cornerRadius = CGFloat(radius)
                }
            }
        }
    }
    
    @objc(setButtonPadding:index:)
    public static func setButtonPadding(_ padding: Double, index: Int) {
        if #available(OSX 10.15, *) {
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.padding = CGFloat(padding)
                }
            }
        }
    }

    @objc(setButtonGlass:index:)
    public static func setButtonGlass(_ isGlass: Bool, index: Int) {
        if #available(OSX 10.15, *) {
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.isGlass = isGlass
                }
            }
        }
    }

    @objc(setButtonImage:index:)
    public static func setButtonImage(_ imageName: String, index: Int) {
        if #available(OSX 10.15, *) {
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.imageName = imageName
                }
            }
        }
    }
}
