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
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
}

// MARK: - Native Bridge
@_cdecl("HB_FUN_SW_TOGGLE_CREATE")
public func sw_toggle_create_hb(_ p: UnsafeMutableRawPointer?) {
    let id = hb_parc(1).map { String(cString: $0) } ?? UUID().uuidString
    let jsonStr = hb_parc(2).map { String(cString: $0) } ?? "{}"
    
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
    let initial = (try? decoder.decode(ToggleInit.self, from: jsonStr.data(using: .utf8) ?? Data()))
                ?? ToggleInit(value: false, prompt: "Toggle", isSwitch: false, width: 200, height: 30, top: 0, left: 0)
    
    if ViewRegistry.getState(for: id) == nil {
        let state = ToggleState(id: id, isOn: initial.value ?? false, prompt: initial.prompt ?? "")
        state.isSwitch = initial.isSwitch ?? false
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .toggle, id: id)
        item.itemWidth = initial.width ?? 200
        item.itemHeight = initial.height ?? 30
        item.x = initial.left ?? 0
        item.y = initial.top ?? 0
        ViewRegistry.register(item, for: id)
    }
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
