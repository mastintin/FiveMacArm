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
    var state: ToggleState

    var body: some View {
        let toggleBinding = Binding(
            get: { self.state.isOn },
            set: { newValue in
                self.state.isOn = newValue
                self.state.callback?(newValue)
            }
        )

        Group {
            if state.isSwitch {
                Toggle(isOn: toggleBinding) {
                    Text(state.caption)
                         .foregroundColor(state.textColor)
                }
                .toggleStyle(.switch)
            } else {
                Toggle(isOn: toggleBinding) {
                    Text(state.caption)
                         .foregroundColor(state.textColor)
                }
            }
        }
        .accentColor(state.accentColor)
        .padding()
    }
}

@objc(SwiftToggleLoader)
public class SwiftToggleLoader: NSObject {
    
    public static var states: [String: ToggleState] = [:]
    
    @objc(makeToggleWithCaption:isOn:id:isSwitch:index:callback:)
    public static func makeToggle(caption: String, isOn: Bool, id: String, isSwitch: Bool, index: Int, callback: @escaping ((Bool) -> Void)) -> NSView {
        let state = ToggleState(isOn: isOn, caption: caption, isSwitch: isSwitch, callback: callback)
        let key = id.isEmpty ? String(index) : id
        states[key] = state
        
        let view = SwiftToggleView(state: state)
        ViewRegistry.register(view, for: index)
        
        let hostingView = NSHostingView(rootView: view)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        return hostingView
    }

    public static func setValue(id: String, isOn: Bool) {
        DispatchQueue.main.async {
            if let state = states[id] {
                state.isOn = isOn
            }
        }
    }

    public static func setCaption(id: String, caption: String) {
        DispatchQueue.main.async {
            if let state = states[id] {
                state.caption = caption
            }
        }
    }

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


@HarbourBridge
public func tgl_set_colors(id: String, accentHex: String, textHex: String) {
    SwiftToggleLoader.setColors(id: id, accentHex: accentHex, textHex: textHex)
}

@HarbourDirect
public func tgl_set_value(id: String, value: Bool) {
    SwiftToggleLoader.setValue(id: id, isOn: value)
}

@HarbourDirect
public func swift_toggle_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    caption: String, 
    isOn: Bool, 
    parentPtr: Int64,
    index: Int,
    id: String, 
    isSwitch: Bool
) -> Int64 {
    
    // 1. Definimos la lógica de creación en una función interna
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        
        // Callback que hablará con Harbour (SWIFTTOGGLEONCHANGE)
        let callback: (Bool) -> Void = { newValue in
            DispatchQueue.main.async {
                if let pDynSym = hb_dynsymFindName("SWIFTTOGGLEONCHANGE") {
                    hb_vmPushSymbol(hb_dynsymSymbol(pDynSym))
                    hb_vmPushNil()
                    hb_vmPushNumber(Double(index), 0) 
                    hb_vmPushLogical(newValue ? 1 : 0)
                    hb_vmDo(2)
                }
            }
        }

        // Crear la vista usando el Factory
        let toggleView = SwiftToggleLoader.makeToggle(
            caption: caption, 
            isOn: isOn, 
            id: id,
            isSwitch: isSwitch, 
            index: index, 
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
