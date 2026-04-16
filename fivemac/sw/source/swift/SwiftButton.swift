import SwiftUI
import AppKit
import Observation
import HarbourMacro

// MARK: - Button State
@Observable
public class ButtonState {
    public var id: String
    public var caption: String
    public var backgroundColor: Color
    public var foregroundColor: Color
    public var cornerRadius: CGFloat
    public var isVisible: Bool = true
    
    public init(id: String, caption: String, backgroundColor: Color = .blue, foregroundColor: Color = .white, cornerRadius: CGFloat = 8) {
        self.id = id
        self.caption = caption
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
    }

    /// Motor central de cambios (Cero Hardcode en el Dispatcher)
    @MainActor
    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "caption", "text", "settext":
            self.caption = String(describing: value)
            
        case "bgcolor", "background":
            if let color = value as? Color { self.backgroundColor = color }
            
        case "fgcolor", "foreground":
            if let color = value as? Color { self.foregroundColor = color }
            
        case "corner", "cornerradius":
            if let n = value as? CGFloat { self.cornerRadius = n }
            else if let s = value as? String { self.cornerRadius = CGFloat(Double(s) ?? 8) }
            
        case "visible":
            if let b = value as? Bool { self.isVisible = b }
            
        default:
            print("SwButton [\(id)]: Propiedad '\(property)' no reconocida.")
        }
    }
}





// MARK: - Button Initialization (Codable)
public struct ButtonInit: Codable {
    public let caption: String?
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
}

// MARK: - Native Bridge (Harbour Interface)

@_cdecl("HB_FUN_SW_BUTTON_CREATE")
public func sw_button_create_hb(_ p: UnsafeMutableRawPointer?) {
    let id = hb_parc(1).map { String(cString: $0) } ?? UUID().uuidString
    let jsonStr = hb_parc(2).map { String(cString: $0) } ?? "{}"
    
    let decoder = JSONDecoder()
    let initial = (try? decoder.decode(ButtonInit.self, from: jsonStr.data(using: .utf8) ?? Data()))
                ?? ButtonInit(caption: "Button", width: 90, height: 30, top: 0, left: 0)
    
    if ViewRegistry.getState(for: id) == nil {
        let state = ButtonState(id: id, caption: initial.caption ?? "")
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .button, id: id)
        item.itemWidth = initial.width ?? 90
        item.itemHeight = initial.height ?? 30
        item.x = initial.left ?? 0
        item.y = initial.top ?? 0
        ViewRegistry.register(item, for: id)
    }
    
    // AUTORREGISTRACIÓN: Definimos cómo nos ven desde Harbour y cómo respondemos
    SwCapabilities.shared.register(
        control: "button",
        commands: [
            "SWTEXT": "text", 
            "SWCAPTION": "text", 
            "SWPOS": "pos",
            "SWSETCOLOR": "color"
        ],
        fields: [
            "text": "Caption",
            "pos": "nTop",
            "color": "nClrPane"
        ]
    )
}


@_cdecl("HB_FUN_SW_BUTTON_SETTEXT")
public func sw_button_settext_hb(_ p: UnsafeMutableRawPointer?) {
    let id = hb_parc(1).map { String(cString: $0) } ?? ""
    let text = hb_parc(2).map { String(cString: $0) } ?? ""
    
    if let state = ViewRegistry.getState(for: id) as? ButtonState {
        // Ejecutamos en el MainActor para asegurar la actualización de UI
        Task { @MainActor in
            state.apply(property: "caption", value: text)
        }
    }
}

@_cdecl("HB_FUN_SW_BUTTON_SETCORNER")
public func sw_button_setcorner_hb(_ p: UnsafeMutableRawPointer?) {
    let id = hb_parc(1).map { String(cString: $0) } ?? ""
    let radius = CGFloat(hb_parnd(2))
    
    if let state = ViewRegistry.getState(for: id) as? ButtonState {
        Task { @MainActor in
            state.apply(property: "corner", value: radius)
        }
    }
}

@_cdecl("HB_FUN_SW_BUTTON_SETCOLOR")
public func sw_button_setcolor_hb(_ p: UnsafeMutableRawPointer?) {
    let id = hb_parc(1).map { String(cString: $0) } ?? ""
    let r = Int(hb_parni(2))
    let g = Int(hb_parni(3))
    let b = Int(hb_parni(4))
    let a = Int(hb_parni(5))
    
    if let state = ViewRegistry.getState(for: id) as? ButtonState {
        let color = Color(red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
        Task { @MainActor in
            state.apply(property: "bgcolor", value: color)
        }
    }
}

// MARK: - Button View (Visual)
public struct SwiftButtonView: View {
    @Bindable var state: ButtonState
    let onAction: ((String) -> Void)?
    @State private var isPressed = false
    
    public var body: some View {
        Text(state.caption)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(state.foregroundColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(
                        isPressed 
                        ? LinearGradient(colors: [state.backgroundColor.opacity(0.8), state.backgroundColor], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [state.backgroundColor, state.backgroundColor.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .black.opacity(0.2), radius: isPressed ? 1 : 3, x: 0, y: isPressed ? 1 : 2)
            }
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .contentShape(Capsule())
            .onLongPressGesture(minimumDuration: 0.0, pressing: { pressing in
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = pressing
                }
            }, perform: {
                onAction?(state.id)
            })
    }
}

// Al final de SwiftButton.swift
extension ButtonState: SwApplyable {
    // Como ya creamos el método apply(property:value:) con la firma exacta,
    // simplemente declarar la extensión ya lo hace compatible.
}

