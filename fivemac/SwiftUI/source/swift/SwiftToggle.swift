import SwiftUI
import AppKit
import Observation
import HarbourMacro

// State for the Toggle

@Observable
public class ToggleState: RGBAColorableState {
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
            .tint(state.accentColor)
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
            .tint(state.accentColor)
            .padding(4)
            .onChange(of: state.isOn) { _, newValue in
                state.callback?(newValue)
            }
        }
    }
}

@objc(SwiftToggleLoader)
public class SwiftToggleLoader: NSObject {
    
    public static func makeToggle(caption: String, isOn: Bool, id: String, isSwitch: Bool, callback: @escaping ((Bool) -> Void)) -> NSView {
        let finalId = id.isEmpty ? UUID().uuidString : id
        let state = ToggleState(isOn: isOn, caption: caption, isSwitch: isSwitch, callback: callback)
        
        // Use central registry
        ViewRegistry.register(state, for: finalId)
        
        let view = SwiftToggleView(state: state)
        ViewRegistry.register(view, for: finalId)
        
        let hostingView = NSHostingView(rootView: view)
        hostingView.sizingOptions = [] 
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
        return hostingView
    }

    public static func destroyToggle(id: String, viewPtr: Int64) {
        ViewRegistry.clean(id: id) 
        if viewPtr != 0 {
            if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
                _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }

    public static func setValue(id: String, isOn: Bool) {
        DispatchQueue.main.async {
            (ViewRegistry.getState(for: id) as? ToggleState)?.isOn = isOn
        }
    }

    public static func setCaption(id: String, caption: String) {
        DispatchQueue.main.async {
            (ViewRegistry.getState(for: id) as? ToggleState)?.caption = caption
        }
    }
    
    // Versión ultra-rápida para Harbour (nRGB)
    public static func setColors(id: String, accentColor: Int, textColor: Int, alpha: Int) {
        if let state = ViewRegistry.getState(for: id) as? ToggleState {
            let ac = Color.componentsFrom(hbColor: accentColor, alpha: alpha)
            let tc = Color.componentsFrom(hbColor: textColor, alpha: alpha)
            state.setAccentColorRGBA(r: ac.r, g: ac.g, b: ac.b, a: ac.a)
            state.setTextColorRGBA(r: tc.r, g: tc.g, b: tc.b, a: tc.a)
        }
    }
    
    // Versión para Hexadecimal (Strings)
    public static func setColors(id: String, accentHex: String, textHex: String) {
        DispatchQueue.main.async {
            if let state = ViewRegistry.getState(for: id) as? ToggleState {
                state.accentColor = Color(hex: accentHex)
                state.textColor = Color(hex: textHex)
            }
        }
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourDirect
public func tgl_set_caption(id: String, caption: String) {
    DispatchQueue.main.async {
        (ViewRegistry.getState(for: id) as? ToggleState)?.caption = caption
    }
}

@HarbourDirect
public func tgl_get_value(id: String) -> Bool {
    return (ViewRegistry.getState(for: id) as? ToggleState)?.isOn ?? false
}

@HarbourDirect
public func tgl_set_colors_rgba(id: String, accent: Int, text: Int, alpha: Int) {
    if let state = ViewRegistry.getState(for: id) as? ToggleState {
        let ac = Color.componentsFrom(hbColor: accent, alpha: alpha)
        let tc = Color.componentsFrom(hbColor: text, alpha: alpha)
        state.setAccentColorRGBA(r: ac.r, g: ac.g, b: ac.b, a: ac.a)
        state.setTextColorRGBA(r: tc.r, g: tc.g, b: tc.b, a: tc.a)
    }
}

@HarbourDirect
public func tgl_set_colors_hex(id: String, accent: String, text: String) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? ToggleState {
            state.accentColor = Color(hex: accent)
            state.textColor = Color(hex: text)
        }
    }
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
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        let finalId = id.isEmpty ? UUID().uuidString : id
        
        let callback: (Bool) -> Void = { newValue in
            let sendToHarbour = {
                SwiftBridge.onChange(finalId, newValue)
            }

            if Thread.isMainThread {
               sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }

        let toggleView = SwiftToggleLoader.makeToggle(
            caption: caption, 
            isOn: isOn, 
            id: finalId,
            isSwitch: isSwitch, 
            callback: callback
        )
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: toggleView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(toggleView).toOpaque()
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
