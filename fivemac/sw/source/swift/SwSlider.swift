import SwiftUI
import Observation

// MARK: - Slider State
@Observable
public class SliderState: SwApplyable {
    public let id: String
    public var value: Double
    public var min: Double
    public var max: Double
    public var step: Double?
    public var showValue: Bool
    public var isCircular: Bool = false
    public var isEnabled: Bool = true
    public var isVisible: Bool = true
    public var prompt: String = ""
    public var iconMin: String = ""
    public var iconMax: String = ""
    public var tintColor: Color = .blue
    
    public init(id: String, value: Double, min: Double, max: Double, showValue: Bool) {
        self.id = id
        self.value = value
        self.min = min
        self.max = max
        self.showValue = showValue
    }
    
    @MainActor
    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "value":
            if let dVal = (value as? NSNumber)?.doubleValue { self.value = dVal }
        case "min":
            if let dVal = (value as? NSNumber)?.doubleValue { self.min = dVal }
        case "max":
            if let dVal = (value as? NSNumber)?.doubleValue { self.max = dVal }
        case "step":
            if let dVal = (value as? NSNumber)?.doubleValue { self.step = dVal }
        case "showvalue":
            if let bVal = value as? Bool { self.showValue = bVal }
            else if let iVal = value as? Int { self.showValue = (iVal != 0) }
        case "circular", "lcircular":
            if let bVal = value as? Bool { self.isCircular = bVal }
            else if let iVal = value as? Int { self.isCircular = (iVal != 0) }
        case "enabled", "lenabled":
            if let bVal = value as? Bool { self.isEnabled = bVal }
            else if let iVal = value as? Int { self.isEnabled = (iVal != 0) }
        case "visible", "lvisible":
            if let bVal = value as? Bool { self.isVisible = bVal }
            else if let iVal = value as? Int { self.isVisible = (iVal != 0) }
        case "prompt", "title", "text":
            if let sVal = value as? String { self.prompt = sVal }
        case "iconmin":
            if let sVal = value as? String { self.iconMin = sVal }
        case "iconmax":
            if let sVal = value as? String { self.iconMax = sVal }
        case "color", "tintcolor":
            if let sVal = value as? String {
                if sVal.hasPrefix(".") { self.tintColor = mapBaseColor(sVal) }
                else { self.tintColor = Color(hex: sVal) }
            }
        default:
            break
        }
    }
}



// MARK: - Slider View
public struct SwiftSliderView: View {
    @Bindable var state: SliderState
    
    public var body: some View {
        if state.isVisible {
            VStack(alignment: .leading, spacing: 4) {
                if !state.prompt.isEmpty {
                    Text(state.prompt)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                
                HStack(spacing: 8) {
                    if !state.iconMin.isEmpty {
                        Image(systemName: state.iconMin)
                            .foregroundStyle(.secondary)
                    }
                    
                    if state.isCircular {
                        circularLayout
                    } else {
                        linearLayout
                    }
                    
                    if !state.iconMax.isEmpty {
                        Image(systemName: state.iconMax)
                            .foregroundStyle(.secondary)
                    }
                    
                    if state.showValue {
                        Text("\(Int(state.value))")
                            .font(.caption.monospacedDigit())
                            .frame(width: 30, alignment: .trailing)
                    }
                }
            }
            .opacity(state.isEnabled ? 1.0 : 0.5)
            .disabled(!state.isEnabled)
            .padding(4)
        }
    }
    
    private var linearLayout: some View {
        let safeMax = state.max > state.min ? state.max : state.min + 1.0
        let range = state.min...safeMax
        
        return Group {
            if let step = state.step, step > 0 {
                Slider(value: $state.value, in: range, step: step)
            } else {
                Slider(value: $state.value, in: range)
            }
        }
        .tint(state.tintColor)
        .controlSize(.small)
        .onChange(of: state.value) { _, newValue in
            SwDispatcher.shared.enqueueEvent(id: state.id, type: "action", data: ["value": newValue])
        }
    }
    
    private var circularLayout: some View {
        let safeMax = state.max > state.min ? state.max : state.min + 1.0
        let range = state.min...safeMax
        
        return Gauge(value: state.value, in: range) {
            // Label opcional dentro del círculo
        } currentValueLabel: {
            Text("\(Int(state.value))")
                .font(.caption2)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(state.tintColor)
        .scaleEffect(1.2)
    }
}

// MARK: - Factory Logic (Encapsulada)
extension SwiftSliderView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(SliderInit.self, from: jsonData)
        
        let state = SliderState(id: id, 
                               value: initial.value ?? 0, 
                               min: initial.min ?? 0, 
                               max: initial.max ?? 100, 
                               showValue: initial.showvalue ?? true)
        
        // Propiedades Premium iniciales
        state.isCircular = initial.circular ?? false
        state.isEnabled  = initial.enabled ?? true
        state.isVisible  = initial.visible ?? true
        state.prompt     = initial.prompt ?? ""
        state.iconMin    = initial.iconmin ?? ""
        state.iconMax    = initial.iconmax ?? ""
        state.step       = initial.step
        
        if let colorHex = initial.tintcolor {
            state.tintColor = Color(hex: colorHex)
        }
        
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .slider, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

// MARK: - Protocols & Data Structures
public struct SliderInit: Codable, GeometryProtocol {
    public let value, min, max, step: Double?
    public let showvalue, circular, enabled, visible: Bool?
    public let prompt, iconmin, iconmax, tintcolor: String?
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let parentwidth, parentheight: Double?
}
