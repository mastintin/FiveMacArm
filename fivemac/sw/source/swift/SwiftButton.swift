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





// MARK: - Native Bridge (Harbour Interface)

@_cdecl("HB_FUN_SW_BUTTON_CREATE")
public func sw_button_create_hb(_ p: UnsafeMutableRawPointer?) {
    let id = hb_parc(1).map { String(cString: $0) } ?? UUID().uuidString
    let caption = hb_parc(2).map { String(cString: $0) } ?? ""
    
    if ViewRegistry.getState(for: id) == nil {
        let state = ButtonState(id: id, caption: caption)
        ViewRegistry.register(state, for: id)
        
        // CORRECCIÓN AQUÍ: Se añade el parámetro content
        let item = StackItem(type: .button, content: caption, id: id)
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

// MARK: - SwiftUI View Component
public struct SwButton: View {
    let state: ButtonState
    
    public init(state: ButtonState) {
        self.state = state
    }
    
    public var body: some View {
        if state.isVisible {
            Button(action: {
                // Aquí dispararías el evento hacia Harbour si lo necesitas
                print("Botón \(state.id) pulsado")
            }) {
                Text(state.caption)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(state.backgroundColor)
                    .foregroundColor(state.foregroundColor)
                    .cornerRadius(state.cornerRadius)
            }
            .buttonStyle(.plain)
        }
    }
}

// Al final de SwiftButton.swift
extension ButtonState: SwApplyable {
    // Como ya creamos el método apply(property:value:) con la firma exacta,
    // simplemente declarar la extensión ya lo hace compatible.
}

