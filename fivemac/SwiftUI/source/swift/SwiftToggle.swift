import SwiftUI
import AppKit
import Observation
import HarbourMacro

// State for the Toggle

@Observable
public class ToggleState {
    var isOn: Bool
    var caption: String
    var isSwitch: Bool
    var callback: ((Bool) -> Void)?
    var accentColor: Color = .blue
    var textColor: Color = .primary
    
    init(isOn: Bool, caption: String, isSwitch: Bool, callback: ((Bool) -> Void)?) {
        self.isOn = isOn
        self.caption = caption
        self.isSwitch = isSwitch
        self.callback = callback
    }
}

// SwiftUI View for the Toggle

struct SwiftToggleView: View {
    @Bindable var state: ToggleState

    var body: some View {
        if state.isSwitch {
            Toggle(isOn: $state.isOn) {
                Text(state.caption)
                    .foregroundColor(state.textColor)
            }
            .toggleStyle(.switch) // Estilo Switch (iOS style)
            .accentColor(state.accentColor)
            .padding(4)
            .onChange(of: state.isOn) { _, newValue in
                state.callback?(newValue)
            }
        } else {
            Toggle(isOn: $state.isOn) {
                Text(state.caption)
                    .foregroundColor(state.textColor)
            }
            .toggleStyle(.checkbox) // Estilo Checkbox (macOS standard)
            .accentColor(state.accentColor)
            .padding(4)
            .onChange(of: state.isOn) { _, newValue in
                state.callback?(newValue)
            }
        }
    }
}

@objc(SwiftToggleLoader)
public class SwiftToggleLoader: NSObject {
    public static var states: [String: ToggleState] = [:]
    
    public static func makeToggle(caption: String, isOn: Bool, id: String, isSwitch: Bool, callback: @escaping ((Bool) -> Void)) -> NSView {
        let state = ToggleState(isOn: isOn, caption: caption, isSwitch: isSwitch, callback: callback)
        states[id] = state
        
        let view = SwiftToggleView(state: state)
        let idString: String = id 
        ViewRegistry.register(view, for: idString)
       
        
        let hostingView = NSHostingView(rootView: view)
        hostingView.sizingOptions = [] 
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        return hostingView
    }


    public static func destroyToggle(id: String, viewPtr: Int64) {
        // 1. Limpiar el estado (asumiendo que 'states' también usa el ID)
        states.removeValue(forKey: id)
    
        // 2. Limpiar el registro global de vistas usando el UUID
        ViewRegistry.clean(id: id) 
    
        // 3. Liberar la memoria física (el puntero)
        if viewPtr != 0 {
            if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
                // "Consume" el contador de referencia para que el objeto muera
                _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
}

    // Métodos de actualización rápida (UI Thread)
    public static func setValue(id: String, isOn: Bool) {
        DispatchQueue.main.async { states[id]?.isOn = isOn }
    }

    public static func setCaption(id: String, caption: String) {
        DispatchQueue.main.async { states[id]?.caption = caption }
    }
    
    // Versión ultra-rápida para Harbour (nRGB)
    public static func setColors(id: String, accentColor: Int, textColor: Int, alpha: Int) {
        DispatchQueue.main.async {
            if let state = states[id] {
                // Usamos una pequeña variante de nuestra extensión
                let a = Double(alpha) / 255.0
                state.accentColor = Color(hbColor: accentColor).opacity(a)
            state.textColor = Color(hbColor: textColor).opacity(a)
        }
    }
}
    // Versión para Hexadecimal (Strings)
    public static func setColors(id: String, accentHex: String, textHex: String) {
        DispatchQueue.main.async {
            if let state = states[id] {
                state.accentColor = Color(hex: accentHex)
                state.textColor = Color(hex: textHex)
            }
        }
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourDirect
public func tgl_set_caption(id: String, caption: String) {
    SwiftToggleLoader.setCaption(id: id, caption: caption)
}

@HarbourDirect
public func tgl_get_value(id: String) -> Bool {
    return SwiftToggleLoader.states[id]?.isOn ?? false
}

@HarbourDirect
public func tgl_set_colors_rgba(id: String, accent: Int, text: Int, alpha: Int) {
    SwiftToggleLoader.setColors(id: id, accentColor: accent, textColor: text, alpha: alpha)
}

@HarbourDirect
public func tgl_set_colors_hex(id: String, accent: String, text: String) {
    SwiftToggleLoader.setColors(id: id, accentHex: accent, textHex: text)
}

@HarbourDirect
public func tgl_destroy(id: String, viewPtr: Int64) {
    SwiftToggleLoader.destroyToggle(id: id, viewPtr: viewPtr)
}

@HarbourDirect
public func tgl_set_value(id: String, value: Bool ) {
    SwiftToggleLoader.setValue(id: id, isOn: value )
}


//---------- creacion del control 

@HarbourDirect
public func swift_toggle_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    caption: String, 
    isOn: Bool, 
    parentPtr: Int64,
    id: String, 
    isSwitch: Bool
    ) -> Int64 {
    
    // 1. Definimos la lógica de creación en una función interna
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        
        let callback: (Bool) -> Void = { newValue in
            let sendToHarbour = {
                if let pDynSym = hb_dynsymFindName("SWIFTTOGGLEONCHANGE") {
                    hb_vmPushSymbol(hb_dynsymSymbol(pDynSym))
                    hb_vmPushNil()
                    // Usamos PushNumber o el equivalente que prefieras
                    hb_vmPushString( id ) 
                    hb_vmPushLogical(newValue ? 1 : 0)
                    hb_vmDo(2)
                }
            }

            if Thread.isMainThread {
               sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }

        // Crear la vista usando el Factory
        let toggleView = SwiftToggleLoader.makeToggle(
            caption: caption, 
            isOn: isOn, 
            id: id,
            isSwitch: isSwitch, 
            callback: callback
        )
        
        // Buscar el contenedor del padre (hWnd de Harbour)
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            // Aplicar Layout (Asegúrate de que applySwiftViewLayout use .maxXMargin y .minYMargin)
            applySwiftViewLayout(
                swiftView: toggleView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            // Retener la vista para Harbour
            let viewPtr = Unmanaged.passRetained(toggleView).toOpaque()
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
