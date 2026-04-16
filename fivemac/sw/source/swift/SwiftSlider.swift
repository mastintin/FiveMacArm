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
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
    public let showValue: Bool?
    public let resizemask: Int?
}

// MARK: - Native Bridge
@_cdecl("HB_FUN_SW_SLIDER_CREATE")
public func sw_slider_create_hb(_ p: UnsafeMutableRawPointer?) {
    let id = hb_parc(1).map { String(cString: $0) } ?? UUID().uuidString
    let jsonStr = hb_parc(2).map { String(cString: $0) } ?? "{}"
    
    let decoder = JSONDecoder()
    let initial = (try? decoder.decode(SliderInit.self, from: jsonStr.data(using: .utf8) ?? Data()))
                ?? SliderInit(value: 0, min: 0, max: 100, width: 200, height: 30, top: 0, left: 0, showValue: true, resizemask: 0)
    
    if ViewRegistry.getState(for: id) == nil {
        let state = SliderState(id: id, 
                             value: initial.value ?? 0, 
                             min: initial.min ?? 0, 
                             max: initial.max ?? 100, 
                             showValue: initial.showValue ?? true)
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .slider, id: id)
        item.itemWidth = initial.width ?? 200
        item.itemHeight = initial.height ?? 30
        item.x = initial.left ?? 0
        item.y = initial.top ?? 0
        item.resizemask = initial.resizemask ?? 0
        ViewRegistry.register(item, for: id)
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
