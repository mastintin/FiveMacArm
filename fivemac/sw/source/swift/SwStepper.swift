import SwiftUI
import Observation

// MARK: - Stepper State
@Observable
public class StepperState: SwApplyable {
    public let id: String
    public var value: Double
    public var min: Double
    public var max: Double
    public var step: Double
    public var text: String
    public var isEnabled: Bool = true
    public var isVisible: Bool = true
    
    public init(id: String, value: Double, min: Double, max: Double, step: Double, text: String) {
        self.id = id
        self.value = value
        self.min = min
        self.max = max
        self.step = step
        self.text = text
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
        case "text":
            if let sVal = value as? String { self.text = sVal }
        case "enabled", "lenabled":
            if let bVal = value as? Bool { self.isEnabled = bVal }
            else if let iVal = value as? Int { self.isEnabled = (iVal != 0) }
        case "visible", "lvisible":
            if let bVal = value as? Bool { self.isVisible = bVal }
            else if let iVal = value as? Int { self.isVisible = (iVal != 0) }
        default:
            break
        }
    }
}

// MARK: - Stepper View
public struct SwiftStepperView: View {
    @Bindable var state: StepperState
    
    public var body: some View {
        if state.isVisible {
            Stepper(value: $state.value, in: state.min...state.max, step: state.step) {
                Text(state.text.isEmpty ? "\(Int(state.value))" : "\(state.text): \(Int(state.value))")
            }
            .opacity(state.isEnabled ? 1.0 : 0.5)
            .disabled(!state.isEnabled)
            .onChange(of: state.value) { _, newValue in
                SwDispatcher.shared.enqueueEvent(id: state.id, type: "action", data: ["value": newValue])
            }
            .padding(4)
        }
    }
}

// MARK: - Factory Logic
extension SwiftStepperView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(StepperInit.self, from: jsonData)
        
        let state = StepperState(id: id, 
                               value: initial.value ?? 0, 
                               min: initial.min ?? 0, 
                               max: initial.max ?? 100, 
                               step: initial.step ?? 1,
                               text: initial.text ?? "")
        
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .stepper, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

// MARK: - Protocols & Data Structures
public struct StepperInit: Codable, GeometryProtocol {
    public let value, min, max, step: Double?
    public let text: String?
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let parentwidth, parentheight: Double?
}
