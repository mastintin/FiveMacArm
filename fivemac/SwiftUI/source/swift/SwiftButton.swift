import SwiftUI
import AppKit
import Observation
import HarbourMacro

@Observable
public class ButtonState {
    var title: String
    var backgroundColor: Color
    var foregroundColor: Color
    var cornerRadius: CGFloat
    var padding: CGFloat
    var isGlass: Bool
    var imageName: String

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



struct SwiftButtonView: View {
    var state: ButtonState
    var callback: (() -> Void)?
    
    var body: some View {
        if state.isGlass {
             Button(action: { self.callback?() }) {
                 HStack {
                     if !state.imageName.isEmpty {
                         Image(systemName: state.imageName)
                     }
                     Text(state.title)
                 }
                 .padding(.horizontal, 12)
                 .padding(.vertical, 8)
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .background(state.backgroundColor.opacity(0.8))
                 .clipShape(Capsule())
                 .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
             }
             .buttonStyle(PlainButtonStyle())
             .foregroundColor(state.foregroundColor)
             .contentShape(Capsule())
             .ifAvailable_glassEffect()
        } else {
             Button(action: { self.callback?() }) {
                 HStack {
                     if !state.imageName.isEmpty {
                         Image(systemName: state.imageName)
                     }
                     Text(state.title)
                 }
                 .padding(state.padding > 0 ? state.padding : 10)
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .background(state.backgroundColor)
                 .cornerRadius(state.cornerRadius)
             }
             .buttonStyle(PlainButtonStyle())
             .foregroundColor(state.foregroundColor)
             .contentShape(Rectangle())
        }
    }
}

extension View {
    @ViewBuilder
    func ifAvailable_glassEffect() -> some View {
        if #available(macOS 26.0, *) {
             self.glassEffect(.regular, in: Capsule())
        } else {
            self
        }
    }
}

@objc(SwiftButtonLoader)
public class SwiftButtonLoader: NSObject {
    
    // CRITICAL: Use Dictionary to prevent Index Collision
    // HYBRID MIGRATION: Key is String to support both "123" (legacy indices) and "UUID-..."
    public static var states: [String: ButtonState] = [:]

    @objc(makeButtonWithTitle:index:callback:)
    public static func makeButton(title: String, index: Int, callback: ((String) -> Void)?) -> NSView {
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
    }

    @objc(setButtonBackgroundColor:index:)
    public static func setButtonBackgroundColor(_ colorHex: String, index: Int) {
       
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.backgroundColor = Color(hex: colorHex)
                }
            }
       
    }

    @objc(setButtonForegroundColor:index:)
    public static func setButtonForegroundColor(_ colorHex: String, index: Int) {
       
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.foregroundColor = Color(hex: colorHex)
                }
            }
       
    }

    @objc(setButtonCornerRadius:index:)
    public static func setButtonCornerRadius(_ radius: Double, index: Int) {
       
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.cornerRadius = CGFloat(radius)
                }
            }
       
    }
    
    @objc(setButtonPadding:index:)
    public static func setButtonPadding(_ padding: Double, index: Int) {
       
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.padding = CGFloat(padding)
                }
            }
        
    }

    @objc(setButtonGlass:index:)
    public static func setButtonGlass(_ isGlass: Bool, index: Int) {
       
            NSLog("DEBUG: SwiftButton setButtonGlass: \(isGlass) for index: \(index)")
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.isGlass = isGlass
                } else {
                    NSLog("DEBUG: SwiftButton setButtonGlass: State NOT found for index: \(index)")
                }
            }
        
    }

    @objc(setButtonImage:index:)
    public static func setButtonImage(_ imageName: String, index: Int) {
        let key = String(index)
        DispatchQueue.main.async {
            if let state = states[key] {
                state.imageName = imageName
            }
        }
        
    }
}

// --- HARBOUR BRIDGE MACROS ---

@_cdecl("SW_BTN_SET_TEXT")
public func sw_btn_set_text(index: UnsafePointer<Int8>, text: UnsafePointer<Int8>) {
    let key = String(cString: index)
    DispatchQueue.main.async {
        if let state = SwiftButtonLoader.states[key] {
            state.title = String(cString: text)
        }
    }
}

@_cdecl("SW_BTN_SET_BG")
public func sw_btn_set_bg(index: UnsafePointer<Int8>, hex: UnsafePointer<Int8>) {
    SwiftButtonLoader.setButtonBackgroundColor(String(cString: hex), index: Int(String(cString: index)) ?? 0)
}

@_cdecl("SW_BTN_SET_FG")
public func sw_btn_set_fg(index: UnsafePointer<Int8>, hex: UnsafePointer<Int8>) {
    SwiftButtonLoader.setButtonForegroundColor(String(cString: hex), index: Int(String(cString: index)) ?? 0)
}

@_cdecl("SW_BTN_SET_RADIUS")
public func sw_btn_set_radius(index: UnsafePointer<Int8>, radius: UnsafePointer<Int8>) {
    SwiftButtonLoader.setButtonCornerRadius(Double(String(cString: radius)) ?? 0, index: Int(String(cString: index)) ?? 0)
}

@_cdecl("SW_BTN_SET_PADDING")
public func sw_btn_set_padding(index: UnsafePointer<Int8>, padding: UnsafePointer<Int8>) {
    SwiftButtonLoader.setButtonPadding(Double(String(cString: padding)) ?? 0, index: Int(String(cString: index)) ?? 0)
}

@_cdecl("SW_BTN_SET_GLASS")
public func sw_btn_set_glass(index: UnsafePointer<Int8>, glass: UnsafePointer<Int8>) {
    let bGlass = (String(cString: glass) == "1")
    SwiftButtonLoader.setButtonGlass(bGlass, index: Int(String(cString: index)) ?? 0)
}

@_cdecl("SW_BTN_SET_IMAGE")
public func sw_btn_set_image(index: UnsafePointer<Int8>, image: UnsafePointer<Int8>) {
    SwiftButtonLoader.setButtonImage(String(cString: image), index: Int(String(cString: index)) ?? 0)
}
