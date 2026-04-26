import SwiftUI
import Observation

// MARK: - Progress State
@Observable
public class ProgressState: SwApplyable {
    public let id: String
    public var value: Double
    public var min: Double
    public var max: Double
    
    public init(id: String, value: Double, min: Double, max: Double) {
        self.id = id
        self.value = value
        self.min = min
        self.max = max
    }
    
    @MainActor
    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "value":
            if let dVal = (value as? NSNumber)?.doubleValue {
                print("🏝️ [Swift-Progress] Actualizando valor a \(dVal)")
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
        default:
            break
        }
    }
}


// MARK: - Progress View
public struct SwiftProgressView: View {
    @Bindable var state: ProgressState
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text("Progreso: \(Int(state.value)) / \(Int(state.max))")
                .font(.caption2.monospacedDigit())
            ProgressView(value: state.value, total: state.max)
                .progressViewStyle(.linear)
                .controlSize(.small)
                .id(state.value) // Hack para forzar redibujado en actualizaciones rápidas
        }
    }
}

// MARK: - Factory Logic (Encapsulada)
extension SwiftProgressView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(ProgressInit.self, from: jsonData)
        
        let state = ProgressState(id: id, 
                                 value: initial.value ?? 0, 
                                 min: initial.min ?? 0, 
                                 max: initial.max ?? 100)
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .progress, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

// MARK: - Protocols & Data Structures
public struct ProgressInit: Codable, GeometryProtocol {
    public let value, min, max: Double?
    public let width, height, top, left: Double?
    public let resizemask: Int?
}
