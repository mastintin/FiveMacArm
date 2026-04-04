import SwiftUI
import AppKit
import Observation
import HarbourMacro

@Observable
public class ButtonState: RGBAColorableState {
    var caption: String
    var backgroundColor: Color
    var foregroundColor: Color
    var cornerRadius: CGFloat
    var padding: CGFloat
    var isGlass: Bool
    var isProminent: Bool = false
    var imageName: String

    init(caption: String, backgroundColor: Color = .clear, foregroundColor: Color = .primary, cornerRadius: CGFloat = 8, padding: CGFloat = 0, isGlass: Bool = false, imageName: String = "", isProminent: Bool = false) {
        self.caption = caption
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.isGlass = isGlass
        self.isProminent = isProminent
        self.imageName = imageName
    }

    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        DispatchQueue.main.async {
            if r == -2 {
                self.isProminent = true
                self.backgroundColor = .accentColor
                self.foregroundColor = .white
            } else {
                self.isProminent = false
                self.backgroundColor = Color(r: r, g: g, b: b, a: a)
            }
        }
    }

    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        DispatchQueue.main.async {
            self.foregroundColor = Color(r: r, g: g, b: b, a: a)
        }
    }
}

public struct ButtonInitialState: Codable {
    public let caption: String
    public let bgColor: ColorRGBA?
    public let fgColor: ColorRGBA?
    public let cornerRadius: Double?
    public let padding: Double?
    public let isGlass: Bool?
    public let isProminent: Bool?
    public let imageName: String?
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
                     Text(state.caption)
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
             if state.isProminent {
                 Button(action: { self.callback?() }) {
                     HStack {
                         if !state.imageName.isEmpty {
                             Image(systemName: state.imageName)
                         }
                         Text(state.caption)
                     }
                     .padding(state.padding > 0 ? state.padding : 10)
                     .frame(maxWidth: .infinity, maxHeight: .infinity)
                 }
                 .buttonStyle(BorderedProminentButtonStyle())
                 .foregroundColor(.white)
                 .cornerRadius(state.cornerRadius)
             } else {
                 Button(action: { self.callback?() }) {
                     HStack {
                         if !state.imageName.isEmpty {
                             Image(systemName: state.imageName)
                         }
                         Text(state.caption)
                     }
                     .padding(state.padding > 0 ? state.padding : 10)
                     .frame(maxWidth: .infinity, maxHeight: .infinity)
                     .background(state.backgroundColor)
                     .cornerRadius(state.cornerRadius)
                 }
                 .buttonStyle(BorderedButtonStyle())
                 .foregroundColor(state.foregroundColor)
                 .contentShape(Rectangle())
             }
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

    public static func makeButton(id: String, json: String, callback: @escaping () -> Void) -> NSView {
         let finalId = id.isEmpty ? UUID().uuidString : id
         
         let decoder = JSONDecoder()
         let initialState = (try? decoder.decode(ButtonInitialState.self, from: json.data(using: .utf8) ?? Data()))
         ?? ButtonInitialState(caption: "SwiftBtn", bgColor: nil, fgColor: nil, cornerRadius: nil, padding: nil, isGlass: nil, isProminent: false, imageName: nil)

         let state = ButtonState(
            caption: initialState.caption,
            backgroundColor: initialState.bgColor.map { Color(rgba: $0) } ?? .clear,
            foregroundColor: initialState.fgColor.map { Color(rgba: $0) } ?? .primary,
            cornerRadius: CGFloat(initialState.cornerRadius ?? 8),
            padding: CGFloat(initialState.padding ?? 0),
            isGlass: initialState.isGlass ?? false,
            imageName: initialState.imageName ?? "",
            isProminent: initialState.isProminent ?? false
         )
         
         // Register in central registries
         ViewRegistry.register(state, for: finalId)
         
         let view = SwiftButtonView(state: state, callback: callback)
         ViewRegistry.register(view, for: finalId)
         
         let hostingView = NSHostingView(rootView: view)
         hostingView.sizingOptions = [] 
         hostingView.translatesAutoresizingMaskIntoConstraints = false
         hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
         return hostingView
    }

    public static func destroyButton(id: String, viewPtr: Int64) {
        ViewRegistry.clean(id:id) 
        
        if viewPtr != 0 {
            if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
                _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }

    public static func setText(id: String, text: String) {
        let block = { if let state = ViewRegistry.getState(for: id) as? ButtonState { state.caption = text } }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public static func setBackgroundColor(id: String, hex: String) {
        let block = { if let state = ViewRegistry.getState(for: id) as? ButtonState { state.backgroundColor = Color(hex: hex) } }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public static func setForegroundColor(id: String, hex: String) {
        let block = { if let state = ViewRegistry.getState(for: id) as? ButtonState { state.foregroundColor = Color(hex: hex) } }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public static func setCornerRadius(id: String, radius: Double) {
        let block = { if let state = ViewRegistry.getState(for: id) as? ButtonState { state.cornerRadius = CGFloat(radius) } }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }
    
    public static func setPadding(id: String, padding: Double) {
        let block = { if let state = ViewRegistry.getState(for: id) as? ButtonState { state.padding = CGFloat(padding) } }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public static func setGlass(id: String, isGlass: Bool) {
        let block = { if let state = ViewRegistry.getState(for: id) as? ButtonState { state.isGlass = isGlass } }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public static func setImage(id: String, imageName: String) {
        let block = { if let state = ViewRegistry.getState(for: id) as? ButtonState { state.imageName = imageName } }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourDirect
public func btn_set_text(id: String, text: String) {
    SwiftButtonLoader.setText(id: id, text: text)
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
public func btn_destroy(id: String, viewPtr: Int64) {
    SwiftButtonLoader.destroyButton(id: id, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_button_create(
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
        
        let callback: () -> Void = {
            let sendToHarbour = {
                SwiftBridge.onAction(finalId)
            }
            if Thread.isMainThread {
                sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }

        let buttonView = SwiftButtonLoader.makeButton(
            id: finalId, 
            json: json,
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

@HarbourDirect
public func swift_button_create_state(id: String, caption: String) {
    let finalId = id.isEmpty ? UUID().uuidString : id
    let state = ButtonState(caption: caption)
    ViewRegistry.register(state, for: finalId)
}
