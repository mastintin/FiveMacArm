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
            
        case "hasscroll", "interactive", "resizemask":
            break // Propiedades generales manejadas por el contenedor
            
        default:
            print("SwButton [\(id)]: Propiedad '\(property)' no reconocida.")
        }
    }
}





// MARK: - Button Initialization (Codable)
public struct ButtonInit: Codable {
    public let caption: String?
    public let interactive: Bool?
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
    public let resizemask: Int?
}


// MARK: - Button View (Visual)
public struct SwiftButtonView: View {
    @Bindable var state: ButtonState
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
            .onTapGesture {
                let json = "{\"\(state.id)\":{\"event\":\"click\"}}"
                Harbour.call("SW_PIPELINE_SYNC", json)
            }
    }
}

// Al final de SwiftButton.swift
extension ButtonState: SwApplyable {
    // Como ya creamos el método apply(property:value:) con la firma exacta,
    // simplemente declarar la extensión ya lo hace compatible.
}

