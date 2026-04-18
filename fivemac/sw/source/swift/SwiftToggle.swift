import SwiftUI
import Observation

// MARK: - Toggle State (Reactive)
@Observable
public class ToggleState: SwApplyable {
    public let id: String
    public var isOn: Bool
    public var prompt: String
    public var isSwitch: Bool = false
    public var tintColor: Color = .blue
    public var textColor: Color = .primary
    
    public init(id: String, isOn: Bool, prompt: String) {
        self.id = id
        self.isOn = isOn
        self.prompt = prompt
    }

    @MainActor
    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "value":
            if let bVal = value as? Bool { self.isOn = bVal }
            else if let nVal = value as? NSNumber { self.isOn = nVal.boolValue }
        case "prompt", "caption":
            if let sVal = value as? String { self.prompt = sVal }
        case "color", "tintcolor":
            if let sVal = value as? String { self.tintColor = Color(hex: sVal) }
        case "textcolor":
            if let sVal = value as? String { self.textColor = Color(hex: sVal) }
        default:
            break
        }
    }
}

// MARK: - Toggle Initialization (Codable)
public struct ToggleInit: Codable {
    public let value: Bool?
    public let prompt: String?
    public let isSwitch: Bool?
    public let interactive: Bool?
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
    public let resizemask: Int?
}


// MARK: - Toggle View (Visual Premium)
public struct SwiftToggleView: View {
    @Bindable var state: ToggleState
    @Environment(\.controlActiveState) var controlActiveState
    
    var isActive: Bool { controlActiveState != .inactive }
    
    public var body: some View {
        let toggleBinding = Binding(
            get: { state.isOn },
            set: { newValue in
                state.isOn = newValue
                let json = "{\"\(state.id)\":{\"Value\":\(newValue)}}"
                Harbour.call("SW_PIPELINE_SYNC", json)
            }
        )
        
        HStack {
            if state.isSwitch {
                Toggle(isOn: toggleBinding) {
                    Text(state.prompt)
                        .foregroundStyle(isActive ? state.textColor : state.textColor.opacity(0.5))
                }
                .toggleStyle(.switch)
                .tint(isActive ? state.tintColor : Color.gray.opacity(0.4))
                .controlSize(.small)
            } else {
                Toggle(isOn: toggleBinding) {
                    Text(state.prompt)
                        .foregroundStyle(isActive ? state.textColor : state.textColor.opacity(0.5))
                }
                .toggleStyle(.checkbox)
                .tint(isActive ? state.tintColor : Color.gray.opacity(0.4))
                .controlSize(.small)
            }
        }
    }
}
