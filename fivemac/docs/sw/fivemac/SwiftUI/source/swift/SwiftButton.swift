import SwiftUI
import AppKit
import Observation
import HarbourMacro

@Observable
public class ButtonState: HexColorableState {
    var caption: String
    var backgroundColor: Color
    var foregroundColor: Color
    var cornerRadius: CGFloat
    var padding: CGFloat
    var isGlass: Bool
    var style: String
    var imageName: String

    init(caption: String, backgroundColor: Color = .clear, foregroundColor: Color = .primary, cornerRadius: CGFloat = 8, padding: CGFloat = 0, isGlass: Bool = false, imageName: String = "", style: String = "plain") {
        self.caption = caption
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.isGlass = isGlass
        self.style = style
        self.imageName = imageName
    }

    public func setAccentColor(hex: String) {
        let block = { self.backgroundColor = Color(hex: hex) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public func setTextColor(hex: String) {
        let block = { self.foregroundColor = Color(hex: hex) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    // LEGACY RGBA methods
    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        let block = {
            if r == -2 {
                self.style = "prominent"
                self.backgroundColor = .accentColor
                self.foregroundColor = .white
            } else {
                self.style = "plain"
                self.backgroundColor = Color(r: r, g: g, b: b, a: a)
            }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        let block = { self.foregroundColor = Color(r: r, g: g, b: b, a: a) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }
}

public struct ButtonInitialState: Codable {
    public let caption: String
    public let bgcolor: String?
    public let textcolor: String?
    public let cornerradius: Double?
    public let padding: Double?
    public let isglass: Bool?
    public let style: String?
    public let imagename: String?
}

// ESTILO PERSISTENTE CON ACABADO DE SISTEMA
struct PersistentButtonStyle: ButtonStyle {
    var bgColor: Color
    var fgColor: Color
    var radius: CGFloat
    var padding: CGFloat
    var isGlass: Bool
    var styleName: String
    var isActive: Bool 

    func makeBody(configuration: Configuration) -> some View {
        let isProminent = styleName.lowercased() == "prominent"
        let finalBg = isActive ? 
            ((bgColor == .clear && isProminent) ? Color.accentColor : bgColor) : 
            (isProminent ? Color.gray.opacity(0.3) : .clear)
            
        let finalFg = isActive ? 
            ((isProminent && fgColor == .primary) ? Color.white : fgColor) :
            (isProminent ? Color.gray : fgColor.opacity(0.6))

        configuration.label
            .font(.system(size: 13, weight: isProminent ? .medium : .regular))
            .padding(padding > 0 ? padding : 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Group {
                    if isGlass {
                         VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                             .overlay(finalBg.opacity(isActive ? 0.7 : 0.2))
                             .clipShape(Capsule())
                    } else if isProminent || finalBg != .clear {
                         finalBg
                             .clipShape(isProminent ? AnyShape(Capsule()) : AnyShape(RoundedRectangle(cornerRadius: radius)))
                    }
                }
            )
            .foregroundColor(finalFg)
            .cornerRadius(isGlass || isProminent ? 0 : radius)
            .shadow(color: Color.black.opacity(isProminent && isActive ? 0.2 : 0), radius: 1, x: 0, y: 1)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .followsWindowActiveState
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

struct SwiftButtonView: View {
    @Bindable var state: ButtonState
    var callback: (() -> Void)?
    
    @Environment(\.controlActiveState) var windowState

    var body: some View {
        Button(action: { 
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                 self.callback?() 
             }
        }) {
             HStack(spacing: 8) {
                 if !state.imageName.isEmpty {
                     Image(systemName: state.imageName)
                         .font(.system(size: 14))
                 }
                 Text(state.caption)
             }
        }
        .buttonStyle(
            PersistentButtonStyle(
                bgColor: state.backgroundColor,
                fgColor: state.foregroundColor,
                radius: state.cornerRadius,
                padding: state.padding,
                isGlass: state.isGlass,
                styleName: state.style,
                isActive: windowState != .inactive 
            )
        )
    }
}

@objc(SwiftButtonLoader)
public class SwiftButtonLoader: NSObject {
    
    public static func makeButton(id: String, json: String, callback: @escaping () -> Void) -> NSView {
         let finalId = id.isEmpty ? UUID().uuidString : id
         let decoder = JSONDecoder()
         let initialState = (try? decoder.decode(ButtonInitialState.self, from: json.data(using: .utf8) ?? Data()))
         ?? ButtonInitialState(caption: "SwiftBtn", bgcolor: nil, textcolor: nil, cornerradius: nil, padding: nil, isglass: nil, style: nil, imagename: nil)

         let state = ButtonState(
            caption: initialState.caption,
            backgroundColor: Color(hex: initialState.bgcolor ?? "clear"),
            foregroundColor: Color(hex: initialState.textcolor ?? "primary"),
            cornerRadius: CGFloat(initialState.cornerradius ?? 8),
            padding: CGFloat(initialState.padding ?? 0),
            isGlass: initialState.isglass ?? false,
            imageName: initialState.imagename ?? "",
            style: initialState.style ?? "plain"
         )
         
         ViewRegistry.register(state, for: finalId)
         
         let view = SwiftButtonView(state: state, callback: callback)
         let hostingView = NSHostingView(rootView: view)
         hostingView.wantsLayer = true
         hostingView.layerContentsRedrawPolicy = .beforeViewResize
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
        (ViewRegistry.getState(for: id) as? ButtonState)?.caption = text 
    }
    public static func setStyle(id: String, style: String) { 
        (ViewRegistry.getState(for: id) as? ButtonState)?.style = style 
    }
    public static func setBackgroundColor(id: String, hex: String) { 
        (ViewRegistry.getState(for: id) as? ButtonState)?.setAccentColor(hex: hex) 
    }
    public static func setForegroundColor(id: String, hex: String) { 
        (ViewRegistry.getState(for: id) as? ButtonState)?.setTextColor(hex: hex) 
    }
    public static func setCornerRadius(id: String, radius: Double) { 
        DispatchQueue.main.async { (ViewRegistry.getState(for: id) as? ButtonState)?.cornerRadius = CGFloat(radius) } 
    }
    public static func setPadding(id: String, padding: Double) { 
        DispatchQueue.main.async { (ViewRegistry.getState(for: id) as? ButtonState)?.padding = CGFloat(padding) } 
    }
    public static func setGlass(id: String, isGlass: Bool) { 
        DispatchQueue.main.async { (ViewRegistry.getState(for: id) as? ButtonState)?.isGlass = isGlass } 
    }
    public static func setImage(id: String, imageName: String) { 
        DispatchQueue.main.async { (ViewRegistry.getState(for: id) as? ButtonState)?.imageName = imageName } 
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourDirect public func btn_set_text(id: String, text: String) { SwiftButtonLoader.setText(id: id, text: text) }
@HarbourDirect public func btn_set_style(id: String, style: String) { SwiftButtonLoader.setStyle(id: id, style: style) }
@HarbourDirect public func btn_set_fg(id: String, hex: String) { SwiftButtonLoader.setForegroundColor(id: id, hex: hex) }
@HarbourDirect public func btn_set_bg(id: String, hex: String) { SwiftButtonLoader.setBackgroundColor(id: id, hex: hex) }
@HarbourDirect public func btn_set_radius(id: String, radius: Double) { SwiftButtonLoader.setCornerRadius(id: id, radius: radius) }
@HarbourDirect public func btn_set_padding(id: String, padding: Double) { SwiftButtonLoader.setPadding(id: id, padding: padding) }
@HarbourDirect public func btn_set_glass(id: String, isGlass: Bool) { SwiftButtonLoader.setGlass(id: id, isGlass: isGlass) }
@HarbourDirect public func btn_set_image(id: String, image: String) { SwiftButtonLoader.setImage(id: id, imageName: image) }

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
            DispatchQueue.main.async {
                SwiftBridge.onAction(finalId)
            }
        }

        let buttonView = SwiftButtonLoader.makeButton(
            id: finalId, 
            json: json,
            callback: callback
        )

        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            applySwiftViewLayout(swiftView: buttonView, parent: parentObj, top: top, left: left, w: width, h: height)
            viewAddress = Int64(Int(bitPattern: Unmanaged.passRetained(buttonView).toOpaque()))
        }
        
        return viewAddress
    }

    if Thread.isMainThread { return executeCreation() } else { return DispatchQueue.main.sync { executeCreation() } }
}
