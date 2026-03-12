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
    
    public static var states: [String: ButtonState] = [:]

    public static func makeButton(title: String, id: String, index: Int, callback: @escaping () -> Void) -> NSView {
         let state = ButtonState(title: title)
         let key = id.isEmpty ? String(index) : id
         states[key] = state
         
         let view = SwiftButtonView(state: state, callback: callback)
         ViewRegistry.register(view, for: index)
         
         let hostingView = NSHostingView(rootView: view)
         hostingView.sizingOptions = [] 
         hostingView.translatesAutoresizingMaskIntoConstraints = false
         return hostingView
    }

    public static func destroyButton(id: String, index: Int, viewPtr: Int64) {
        let key = id.isEmpty ? String(index) : id
        states.removeValue(forKey: key)
        ViewRegistry.clean(index:index) 
        
        if viewPtr != 0 {
            if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(viewPtr)) {
                let _ = Unmanaged<NSView>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }

    public static func setText(id: String, text: String) {
        DispatchQueue.main.async { states[id]?.title = text }
    }

    public static func setBackgroundColor(id: String, hex: String) {
        DispatchQueue.main.async { states[id]?.backgroundColor = Color(hex: hex) }
    }

    public static func setForegroundColor(id: String, hex: String) {
        DispatchQueue.main.async { states[id]?.foregroundColor = Color(hex: hex) }
    }

    public static func setCornerRadius(id: String, radius: Double) {
        DispatchQueue.main.async { states[id]?.cornerRadius = CGFloat(radius) }
    }
    
    public static func setPadding(id: String, padding: Double) {
        DispatchQueue.main.async { states[id]?.padding = CGFloat(padding) }
    }

    public static func setGlass(id: String, isGlass: Bool) {
        DispatchQueue.main.async { states[id]?.isGlass = isGlass }
    }

    public static func setImage(id: String, imageName: String) {
        DispatchQueue.main.async { states[id]?.imageName = imageName }
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourDirect
public func btn_set_text(id: String, text: String) {
    SwiftButtonLoader.setText(id: id, text: text)
}

@HarbourDirect
public func btn_set_bg(id: String, hex: String) {
    SwiftButtonLoader.setBackgroundColor(id: id, hex: hex)
}

@HarbourDirect
public func btn_set_fg(id: String, hex: String) {
    SwiftButtonLoader.setForegroundColor(id: id, hex: hex)
}

@HarbourDirect
public func btn_set_radius(id: String, radius: Double) {
    SwiftButtonLoader.setCornerRadius(id: id, radius: radius)
}

@HarbourDirect
public func btn_set_padding(id: String, padding: Double) {
    SwiftButtonLoader.setPadding(id: id, padding: padding)
}

@HarbourDirect
public func btn_set_glass(id: String, isGlass: Bool) {
    SwiftButtonLoader.setGlass(id: id, isGlass: isGlass)
}

@HarbourDirect
public func btn_set_image(id: String, image: String) {
    SwiftButtonLoader.setImage(id: id, imageName: image)
}

@HarbourDirect
public func btn_destroy(id: String, index: Int, viewPtr: Int64) {
    SwiftButtonLoader.destroyButton(id: id, index: index, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_button_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    title: String, 
    parentPtr: Int64,
    index: Int,
    id: String
    ) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        
        let callback: () -> Void = {
            let sendToHarbour = {
                if let pDynSym = hb_dynsymFindName("SWIFTBTNONCLICK") {
                    hb_vmPushSymbol(hb_dynsymSymbol(pDynSym))
                    hb_vmPushNil()
                    hb_vmPushNumber(Double(index), 0) 
                    hb_vmDo(1)
                }
            }

            if Thread.isMainThread {
               sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }

        let buttonView = SwiftButtonLoader.makeButton(
            title: title, 
            id: id,
            index: index, 
            callback: callback
        )
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: buttonView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(buttonView).toOpaque()
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
