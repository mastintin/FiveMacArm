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

// MARK: - Slider Initialization (Codable)
public struct SliderInit: Codable {
    public let value: Double?
    public let min: Double?
    public let max: Double?
    public let showValue: Bool?
    public let interactive: Bool?
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
    public let resizemask: Int?
    public let hasScroll: Bool?
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
            Slider(value: Binding(
                get: { state.value },
                set: { newValue in
                    state.value = newValue
                    let sVal = Int(newValue)
                    let json = "{\"\(state.id)\":{\"value\":\(sVal)}}"
                    Harbour.call("SW_PIPELINE_SYNC", json)
                }
            ), in: state.min...state.max)
            .controlSize(.small)
        }
    }
}
