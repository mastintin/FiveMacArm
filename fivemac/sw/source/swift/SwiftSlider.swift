import SwiftUI
import Observation

// MARK: - Slider State
@Observable
public class SliderState: SwApplyable {
    public let id: String
    public var value: Double
    public var min: Double
    public var max: Double
    public var showValue: Bool
    
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
            if let dVal = (value as? NSNumber)?.doubleValue {
                self.value = dVal
            }
        case "min":
            if let dVal = (value as? NSNumber)?.doubleValue {
                self.min = dVal
            }
        case "max":
            if let dVal = (value as? NSNumber)?.doubleValue {
                self.max = dVal
            }
        case "showvalue":
            if let bVal = value as? Bool { self.showValue = bVal }
            else if let iVal = value as? Int { self.showValue = (iVal != 0) }
        default:
            break
        }
    }
}



// MARK: - Slider View
public struct SwiftSliderView: View {
    @Bindable var state: SliderState
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if state.showValue {
                Text("\(Int(state.value))")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: $state.value, in: state.min...state.max)
                .controlSize(.small)
                .onChange(of: state.value) { oldValue, newValue in
                    print("🎚️ [Slider] Nuevo valor detectado: \(newValue)")
                    SwDispatcher.shared.enqueueEvent(id: state.id, type: "action", data: ["value": newValue])
                }
        }
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
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .slider, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

// MARK: - Protocols & Data Structures
public struct SliderInit: Codable, GeometryProtocol {
    public let value, min, max: Double?, showvalue: Bool?
    public let width, height, top, left: Double?
    public let resizemask: Int?
}
