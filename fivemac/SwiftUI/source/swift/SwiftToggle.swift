import SwiftUI
import AppKit
import Observation
import HarbourMacro

@Observable
public class ToggleState: HexColorableState {
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

    public func setAccentColor(hex: String) {
        let block = { self.accentColor = Color(hex: hex) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public func setTextColor(hex: String) {
        let block = { self.textColor = Color(hex: hex) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    // LEGACY RGBA methods
    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        let block = { self.accentColor = Color(r: r, g: g, b: b, a: a) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        let block = { self.textColor = Color(r: r, g: g, b: b, a: a) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }
}

public struct ToggleInitialState: Codable {
    public let caption: String
    public let ison: Bool
    public let isswitch: Bool
    public let accentcolor: String?
    public let textcolor: String?
}

struct SwiftToggleView: View {
    @Bindable var state: ToggleState
    
    // Detector de foco de ventana (como en el botón)
    @Environment(\.controlActiveState) var windowState

    var body: some View {
        let isActive = windowState != .inactive
        
        Group {
            if state.isSwitch {
                Toggle(isOn: $state.isOn) {
                    Text(state.caption)
                        .foregroundColor(isActive ? state.textColor : state.textColor.opacity(0.6))
                }
                .toggleStyle(.switch)
            } else {
                Toggle(isOn: $state.isOn) {
                    Text(state.caption)
                        .foregroundColor(isActive ? state.textColor : state.textColor.opacity(0.6))
                }
                .toggleStyle(.checkbox)
            }
        }
        .tint(isActive ? state.accentColor : Color.gray.opacity(0.5))
        .padding(4)
        .onChange(of: state.isOn) { _, newValue in
            state.callback?(newValue)
        }
    }
}

@objc(SwiftToggleLoader)
public class SwiftToggleLoader: NSObject {
    
    public static var states: [String: ToggleState] = [:]

    public static func makeToggle(id: String, json: String, callback: @escaping ((Bool) -> Void)) -> NSView {
        let finalId = id.isEmpty ? UUID().uuidString : id
        
        let decoder = JSONDecoder()
        let initial = (try? decoder.decode(ToggleInitialState.self, from: json.data(using: .utf8) ?? Data()))
        ?? ToggleInitialState(caption: "Toggle", ison: false, isswitch: true, accentcolor: nil, textcolor: nil)

        let state = ToggleState(
            isOn: initial.ison, 
            caption: initial.caption, 
            isSwitch: initial.isswitch, 
            callback: callback
        )
        
        if let acc = initial.accentcolor { state.setAccentColor(hex: acc) }
        if let txt = initial.textcolor { state.setTextColor(hex: txt) }

        // Retención fuerte e inmortalidad
        states[finalId] = state
        ViewRegistry.register(state, for: finalId)
        
        let view = SwiftToggleView(state: state)
        let hostingView = NSHostingView(rootView: view)
        hostingView.wantsLayer = true
        hostingView.layerContentsRedrawPolicy = .beforeViewResize
        hostingView.sizingOptions = [] 
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
        return hostingView
    }

    public static func destroyToggle(id: String, viewPtr: Int64) {
        states.removeValue(forKey: id)
        ViewRegistry.clean(id: id) 
        if viewPtr != 0 {
            if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
                _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }

    public static func setValue(id: String, isOn: Bool) { states[id]?.isOn = isOn }
    public static func setCaption(id: String, caption: String) { states[id]?.caption = caption }
    public static func setAccentColor(id: String, hex: String) { states[id]?.setAccentColor(hex: hex) }
    public static func setTextColor(id: String, hex: String) { states[id]?.setTextColor(hex: hex) }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourDirect public func tgl_set_caption(id: String, caption: String) { SwiftToggleLoader.setCaption(id: id, caption: caption) }
@HarbourDirect public func tgl_get_value(id: String) -> Bool { return SwiftToggleLoader.states[id]?.isOn ?? false }
@HarbourDirect public func tgl_set_value(id: String, value: Bool ) { SwiftToggleLoader.setValue(id: id, isOn: value ) }
@HarbourDirect public func tgl_set_fg(id: String, hex: String) { SwiftToggleLoader.setTextColor(id: id, hex: hex) }
@HarbourDirect public func tgl_set_bg(id: String, hex: String) { SwiftToggleLoader.setAccentColor(id: id, hex: hex) }

@HarbourDirect
public func tgl_destroy(id: String, viewPtr: Int64) {
    SwiftToggleLoader.destroyToggle(id: id, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_toggle_create(
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
        
        let callback: (Bool) -> Void = { newValue in
            DispatchQueue.main.async {
                SwiftBridge.onChange(finalId, newValue)
            }
        }

        let toggleView = SwiftToggleLoader.makeToggle(
            id: finalId, 
            json: json,
            callback: callback
        )
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            applySwiftViewLayout(swiftView: toggleView, parent: parentObj, top: top, left: left, w: width, h: height)
            viewAddress = Int64(Int(bitPattern: Unmanaged.passRetained(toggleView).toOpaque()))
        }
        
        return viewAddress
    }

    if Thread.isMainThread { return executeCreation() } else { return DispatchQueue.main.sync { executeCreation() } }
}
