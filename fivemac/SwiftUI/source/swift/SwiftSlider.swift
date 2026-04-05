import SwiftUI
import AppKit
import Observation
import HarbourMacro

// MARK: - State for the Slider

@Observable
public class SliderState: HexColorableState, RGBAColorableState {
    var value: Double
    var minValue: Double
    var maxValue: Double
    var showValue: Bool
    var accentColor: Color
    var backgroundColor: Color
    var foregroundColor: Color
    var isBold: Bool
    var fontSize: CGFloat
    var isGlass: Bool
    var callback: ((Double) -> Void)?

    init(
        value: Double = 0.0,
        minValue: Double = 0.0,
        maxValue: Double = 100.0,
        showValue: Bool = true,
        accentColor: Color = .blue,
        backgroundColor: Color = .clear,
        foregroundColor: Color = .primary,
        isBold: Bool = false,
        fontSize: CGFloat = 12,
        isGlass: Bool = false,
        callback: ((Double) -> Void)? = nil
    ) {
        self.value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.showValue = showValue
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.isBold = isBold
        self.fontSize = fontSize
        self.isGlass = isGlass
        self.callback = callback
    }

    // Modern Hex Color support
    public func setAccentColor(hex: String) {
        let block = { self.accentColor = Color(hex: hex) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public func setTextColor(hex: String) {
        let block = { self.foregroundColor = Color(hex: hex) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    // Legacy RGBA support
    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        let block = { self.accentColor = Color(r: r, g: g, b: b, a: a) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        let block = { self.foregroundColor = Color(r: r, g: g, b: b, a: a) }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }
}

// MARK: - Initial State Decodable

public struct SliderInitialState: Codable {
    public let value: Double
    public let min: Double?
    public let max: Double?
    public let showvalue: Bool?
    public let accentcolor: String?
    public let bgcolor: String?
    public let textcolor: String?
    public let fontsize: Double?
    public let isbold: Bool?
    public let isglass: Bool?
}

// MARK: - SwiftUI View for the Slider

struct SwiftSliderView: View {
    @Bindable var state: SliderState

    var body: some View {
        let sliderBinding = Binding(
            get: { self.state.value },
            set: { newValue in
                self.state.value = newValue
                self.state.callback?(newValue)
            }
        )
       
        VStack(spacing: 8) {
            Slider(value: sliderBinding, in: state.minValue...state.maxValue)
                .controlSize(.small)
                .tint(state.accentColor)
                .if(state.isGlass) { view in
                    view.shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                }
            
            if state.showValue {
                Text("\(Int(state.value))")
                    .font(.system(size: state.fontSize, weight: state.isBold ? .bold : .regular))
                    .foregroundColor(state.foregroundColor)
            }
        }
        .padding(8)
        .background(
             Group {
                 if state.isGlass {
                     VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                         .cornerRadius(8)
                 } else {
                     state.backgroundColor
                         .cornerRadius(8)
                 }
             }
        )
    }
}

// MARK: - Loader & Memory Management

@objc(SwiftSliderLoader)
public class SwiftSliderLoader: NSObject {
    
    // Strong retention for memory stability
    public static var states: [String: SliderState] = [:]

    public static func makeSlider(id: String, json: String, callback: @escaping ((Double) -> Void)) -> NSView {
        let finalId = id.isEmpty ? UUID().uuidString : id
        
        let decoder = JSONDecoder()
        let initial = (try? decoder.decode(SliderInitialState.self, from: json.data(using: .utf8) ?? Data()))
        ?? SliderInitialState(value: 0.0, min: 0, max: 100, showvalue: true, accentcolor: nil, bgcolor: nil, textcolor: nil, fontsize: 12, isbold: false, isglass: false)

        let state = SliderState(
            value: initial.value,
            minValue: initial.min ?? 0.0,
            maxValue: initial.max ?? 100.0,
            showValue: initial.showvalue ?? true,
            accentColor: Color(hex: initial.accentcolor ?? "blue"),
            backgroundColor: Color(hex: initial.bgcolor ?? "clear"),
            foregroundColor: Color(hex: initial.textcolor ?? "primary"),
            isBold: initial.isbold ?? false,
            fontSize: CGFloat(initial.fontsize ?? 12),
            isGlass: initial.isglass ?? false,
            callback: callback
        )
        
        states[finalId] = state
        ViewRegistry.register(state, for: finalId)
        
        let sliderView = SwiftSliderView(state: state)
        let hostingView = NSHostingView(rootView: sliderView)
        hostingView.sizingOptions = []
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
        
        return hostingView
    }

    public static func destroySlider(id: String, viewPtr: Int64) {
        states.removeValue(forKey: id)
        ViewRegistry.clean(id: id) 
        if viewPtr != 0 {
            if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
                _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }

    public static func setValue(id: String, value: Double) {
        DispatchQueue.main.async { states[id]?.value = value }
    }
}

// MARK: - Harbour Bridge Macros

@HarbourDirect public func sld_set_value(id: String, value: Double) { SwiftSliderLoader.setValue(id: id, value: value) }
@HarbourDirect public func sld_get_value(id: String) -> Double { return SwiftSliderLoader.states[id]?.value ?? 0.0 }

@HarbourDirect 
public func sld_set_accent_color(id: String, hex: String) { SwiftSliderLoader.states[id]?.setAccentColor(hex: hex) }

@HarbourDirect 
public func sld_set_text_color(id: String, hex: String) { SwiftSliderLoader.states[id]?.setTextColor(hex: hex) }

@HarbourDirect
public func sld_destroy(id: String, viewPtr: Int64) {
    SwiftSliderLoader.destroySlider(id: id, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_slider_create(
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
        
        let callback: (Double) -> Void = { newValue in
            DispatchQueue.main.async {
                SwiftBridge.onChange(finalId, newValue)
            }
        }

        let sliderView = SwiftSliderLoader.makeSlider(
            id: finalId, 
            json: json,
            callback: callback
        )

        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            applySwiftViewLayout(swiftView: sliderView, parent: parentObj, top: top, left: left, w: width, h: height)
            viewAddress = Int64(Int(bitPattern: Unmanaged.passRetained(sliderView).toOpaque()))
        }
        
        return viewAddress
    }

    if Thread.isMainThread { return executeCreation() } else { return DispatchQueue.main.sync { executeCreation() } }
}
