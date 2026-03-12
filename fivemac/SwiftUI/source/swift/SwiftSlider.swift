import SwiftUI
import AppKit
import Observation
import HarbourMacro

// State for the Slider

@Observable
public class SliderState {
    var value: Double
    var showValue: Bool
    var callback: ((Double) -> Void)?
    var accentColor: Color = .blue
    var backgroundColor: Color = .clear
    var foregroundColor: Color = .primary
    var isBold: Bool = false
    var fontSize: CGFloat = 12
    var isGlass: Bool = false
    
    init(value: Double, showValue: Bool, isGlass: Bool, callback: ((Double) -> Void)?) {
        self.value = value
        self.showValue = showValue
        self.isGlass = isGlass
        self.callback = callback
    }
}

// SwiftUI View for the Slider

struct SwiftSliderView: View {
    var state: SliderState

    var body: some View {
        let sliderBinding = Binding(
            get: { self.state.value },
            set: { newValue in
                self.state.value = newValue
                self.state.callback?(newValue)
            }
        )
       
        VStack {
            if state.isGlass {
                ZStack {
                     // 1. Glass Rail (Background Track)
                     Capsule()
                         .fill(.ultraThinMaterial)
                         .frame(height: 4)
                         .shadow(color: .white.opacity(0.5), radius: 0, x: 0, y: 1)
                    
                     // 2. The Slider itself
                     Slider(value: sliderBinding, in: 0...100)
                        .modify { view in
                            if #available(macOS 26.0, *) {
                                view.glassEffect(.regular.interactive())
                            } else {
                                view
                            }
                        }
                        .tint(.blue.opacity(0.8))
                }
                .contentShape(Capsule())
            } else {
                 Slider(value: sliderBinding, in: 0...100)
            }
            if state.showValue {
                Text("Value: \(Int(state.value))")
                    .font(.system(size: state.fontSize))
                    .fontWeight(state.isBold ? .bold : .regular)
                    .foregroundColor(state.foregroundColor)
            }
        }
        .accentColor(state.accentColor)
       
        .padding()
        .background(
             Group {
                 if state.isGlass {
                     Color.clear
                 } else {
                    state.backgroundColor
                     .cornerRadius(8)
                 }
             }
        )
    }
}

@objc(SwiftSliderLoader)
public class SwiftSliderLoader: NSObject {
    
    public static var states: [String: SliderState] = [:]
    
    public static func makeSlider(value: Double, id: String, showValue: Bool, isGlass: Bool, index: Int, callback: @escaping ((Double) -> Void)) -> NSView {
        let state = SliderState(value: value, showValue: showValue, isGlass: isGlass, callback: callback)
        let key = id.isEmpty ? String(index) : id
        states[key] = state
        
        let view = SwiftSliderView(state: state)
        ViewRegistry.register(view, for: index)
        
        let hostingView = NSHostingView(rootView: view)
        hostingView.sizingOptions = []
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        
        return hostingView
    }

    public static func destroySlider(id: String, index: Int, viewPtr: Int64) {
        let key = id.isEmpty ? String(index) : id
        states.removeValue(forKey: key)
        ViewRegistry.clean(index:index) 
        
        if viewPtr != 0 {
            if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(viewPtr)) {
                let _ = Unmanaged<NSView>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourDirect
public func sld_set_value(id: String, value: Double) {
    DispatchQueue.main.async {
        if let state = SwiftSliderLoader.states[id] {
            state.value = value
        }
    }
}

@HarbourDirect
public func sld_get_value(id: String) -> Double {
    return SwiftSliderLoader.states[id]?.value ?? 0.0
}

@HarbourDirect
public func sld_set_accent_color(id: String, hex: String) {
    DispatchQueue.main.async {
        if let state = SwiftSliderLoader.states[id] {
            state.accentColor = Color(hex: hex)
        }
    }
}

@HarbourDirect
public func sld_set_colors(id: String, fgHex: String, bgHex: String) {
    DispatchQueue.main.async {
        if let state = SwiftSliderLoader.states[id] {
            state.foregroundColor = Color(hex: fgHex)
            state.backgroundColor = Color(hex: bgHex)
        }
    }
}

@HarbourDirect
public func sld_destroy(id: String, index: Int, viewPtr: Int64) {
    SwiftSliderLoader.destroySlider(id: id, index: index, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_slider_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    value: Double, 
    parentPtr: Int64,
    index: Int,
    id: String,
    showValue: Bool,
    isGlass: Bool
    ) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        
        let callback: (Double) -> Void = { newValue in
            let sendToHarbour = {
                if let pDynSym = hb_dynsymFindName("SWIFTSLIDERONCHANGE") {
                    hb_vmPushSymbol(hb_dynsymSymbol(pDynSym))
                    hb_vmPushNil()
                    hb_vmPushNumber(Double(index), 0) 
                    hb_vmPushDouble(newValue, 0)
                    hb_vmDo(2)
                }
            }

            if Thread.isMainThread {
               sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }

        let sliderView = SwiftSliderLoader.makeSlider(
            value: value, 
            id: id,
            showValue: showValue,
            isGlass: isGlass,
            index: index, 
            callback: callback
        )
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: sliderView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(sliderView).toOpaque()
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
