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

// MARK: - Progress Initialization (Codable)
public struct ProgressInit: Codable {
    public let value: Double?
    public let min: Double?
    public let max: Double?
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
    public let resizemask: Int?
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
