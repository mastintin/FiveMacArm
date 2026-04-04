import SwiftUI
import AppKit
import Observation
import HarbourMacro

// State for the Label
@Observable
public class LabelState: RGBAColorableState {
    var caption: String
    var fontSize: CGFloat
    var fontStyle: String // Empty means use fontSize

    var accentColor: Color = .blue
    var textColor: Color = .primary
    var alignment: TextAlignment = .leading 
    var isVisible: Bool = true
    var isEnabled: Bool = true
  
    init(caption: String, fontSize: CGFloat = 24.0, fontStyle: String = "", textColor: Color = .black) {
        self.caption = caption
        self.fontSize = fontSize
        self.fontStyle = fontStyle
        self.textColor = textColor
    }

    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        DispatchQueue.main.async {
            self.accentColor = Color(r: r, g: g, b: b, a: a)
        }
    }

    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        DispatchQueue.main.async {
            self.textColor = Color(r: r, g: g, b: b, a: a)
        }
    }
}


// New SwiftUI View for the label
struct SwiftLabelView: View {
    var state: LabelState

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
private var swiftUIAlignment: Alignment {
        switch state.alignment {
        case .center: return .center
        case .trailing:  return .trailing
        default:      return .leading
        }
    }

    var body: some View {
        let _ = state.textColor // Esto le dice a SwiftUI: "Observa este cambio"
        let _ = state.fontSize
        Text(state.caption)
            .font(getFont())
            .foregroundColor(state.textColor)
            .multilineTextAlignment(state.alignment) // Alineación del texto en sí
            .frame(maxWidth: .infinity, maxHeight: .infinity, 
                   alignment: state.alignment == .center ? .center : (state.alignment == .trailing ? .trailing : .leading))
    }
}

@objc(SwiftLabelLoader)
public class SwiftLabelLoader: NSObject {

    public static func makeLabel(caption: String, id: String) -> NSView {
        let finalId = id.isEmpty ? UUID().uuidString : id
        let state = LabelState(caption: caption, fontSize: 24.0, fontStyle: "", textColor: .black)
        
        // Register in central registry
        ViewRegistry.register(state, for: finalId)
        
        let view = SwiftLabelView(state: state)
        ViewRegistry.register(view, for: finalId)
        
        let hostingView = NSHostingView(rootView: view)
        hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
        return hostingView
    }
    
    public static func destroyLabel(id: String, viewPtr: Int64) {
        // Clean from registries
        ViewRegistry.clean(id: id)
        
        if viewPtr != 0 {
            if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
                _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }

    public static func updateLabel(_ caption: String, id: String ) {
        let block = {
            if let state = ViewRegistry.getState(for: id) as? LabelState {
                state.caption = caption
            }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public static func setAlignment(id: String, align: Int) {
        let block = {
            if let state = ViewRegistry.getState(for: id) as? LabelState {
                // 0: Left, 1: Right, 2: Center (Estándar Harbour/Win)
                switch align {
                case 1: state.alignment = .center
                case 2: state.alignment = .trailing
                default: state.alignment = .leading
                }
            }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public static func setLabelFontSize(_ size: Double, id: String) {
        let block = {
            if let state = ViewRegistry.getState(for: id) as? LabelState {
                state.fontSize = CGFloat(size)
                state.fontStyle = "" // Clear style to usage size
            }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }
    
    public static func setLabelFontStyle(_ style: String, id: String) {
        DispatchQueue.main.async {
            if let state = ViewRegistry.getState(for: id) as? LabelState {
                state.fontStyle = style
            }
        }
    }

    // Versión ultra-rápida para Harbour (nRGB)
    public static func setColors(id: String, textColor: Int, alpha: Int) {
        DispatchQueue.main.async {
            if let state = ViewRegistry.getState(for: id) as? LabelState {
                let a = Double(alpha) / 255.0
                state.textColor = Color(hbColor: textColor).opacity(a)
            }    
        }
    }

    // Versión para Hexadecimal (Strings)
    public static func setColors(id: String, textHex: String, alpha: Int) {
        DispatchQueue.main.async {
            if let state = ViewRegistry.getState(for: id) as? LabelState {
                state.textColor = Color(hex: textHex).opacity(Double(alpha) / 255.0)
            }
        }
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourDirect
public func lbl_set_align(id: String, align: Int) {
    SwiftLabelLoader.setAlignment(id: id, align: align)
}

@HarbourDirect
public func lbl_set_text(id: String, text: String) {
    SwiftLabelLoader.updateLabel( text, id: id )
}

@HarbourDirect
public func lbl_set_font(id: String, size: Double) {
    SwiftLabelLoader.setLabelFontSize(size, id:id  )
}

@HarbourDirect
public func lbl_set_font_style(id: String, style: String) {
    SwiftLabelLoader.setLabelFontStyle(style, id:id  )
}

@HarbourDirect
public func lbl_set_colors_rgba(id: String, text: Int, alpha: Int) {
    SwiftLabelLoader.setColors(id: id, textColor: text, alpha: alpha)
}

@HarbourDirect
public func lbl_set_colors_hex(id: String, text: String,alpha: Int) {
    SwiftLabelLoader.setColors(id: id, textHex: text, alpha: alpha)
}
@HarbourDirect
public func lbl_destroy(id: String, viewPtr: Int64) {
    SwiftLabelLoader.destroyLabel(id: id, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_label_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    caption: String, 
    parentPtr: Int64,
    id: String
     ) -> Int64 {
    
    // 1. Definimos la lógica de creación en una función interna
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        
        // Crear la vista usando el Factory
        let labelView = SwiftLabelLoader.makeLabel(
            caption: caption, 
            id: id
        )
        
        _ = labelView.identifier?.rawValue ?? id

        // Buscar el contenedor del padre (hWnd de Harbour)
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            // Aplicar Layout (Asegúrate de que applySwiftViewLayout use .maxXMargin y .minYMargin)
            applySwiftViewLayout(
                swiftView: labelView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            // Retener la vista para Harbour
            let viewPtr = Unmanaged.passRetained(labelView).toOpaque()
            viewAddress = Int64(Int(bitPattern: viewPtr))
        } else {
            print("Error: El parentPtr \(parentPtr) no es una dirección de memoria válida")
        }
        
        return viewAddress
    }

    // 2. EVITAR EL DEADLOCK:
    // Si ya estamos en el hilo principal (Harbour Main Thread), ejecutamos directo.
    // Si no, usamos sync para esperar el resultado.
    if Thread.isMainThread {
        return executeCreation()
    } else {
        return DispatchQueue.main.sync {
            return executeCreation()
        }
    }
}