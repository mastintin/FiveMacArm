import SwiftUI
import Observation

// MARK: - Toggle State (Reactive)
@Observable
public class ToggleState: SwApplyable {
    public let id: String
    public var isOn: Bool
    public var prompt: String
    public var subtitle: String = ""
    public var icon: String = ""
    public var style: Int = 1 // 0: Checkbox, 1: Switch, 2: Button
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
        case "subtitle", "description":
            if let sVal = value as? String { self.subtitle = sVal }
        case "icon":
            if let sVal = value as? String { self.icon = sVal }
        case "style":
            if let nVal = value as? Int { self.style = nVal }
            else if let nVal = value as? NSNumber { self.style = nVal.intValue }
        case "color", "tintcolor":
            if let sVal = value as? String {
                if sVal.hasPrefix(".") { self.tintColor = mapBaseColor(sVal) }
                else { self.tintColor = Color(hex: sVal) }
            }
        case "textcolor":
            if let sVal = value as? String {
                if sVal.hasPrefix(".") { self.textColor = mapBaseColor(sVal) }
                else { self.textColor = Color(hex: sVal) }
            }
        case "isswitch":
             if let bVal = value as? Bool { self.style = bVal ? 1 : 0 }
        default:
            break
        }
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
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    state.isOn = newValue
                }
                let json = "{\"\(state.id)\":{\"Value\":\(newValue)}}"
                Harbour.call("SW_UPDATE_HB", json)
            }
        )
        
        Toggle(isOn: toggleBinding) {
            HStack(alignment: .center, spacing: 12) {
                if !state.icon.isEmpty {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(isActive ? (state.isOn ? state.tintColor.opacity(0.15) : Color.gray.opacity(0.1)) : Color.clear)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: state.icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(isActive ? (state.isOn ? state.tintColor : .secondary) : .gray)
                            .symbolEffect(.bounce, value: state.isOn)
                    }
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(state.prompt)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isActive ? state.textColor : state.textColor.opacity(0.5))
                    
                    if !state.subtitle.isEmpty {
                        Text(state.subtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .applyToggleStyle(state.style)
        .tint(isActive ? state.tintColor : Color.gray.opacity(0.4))
        .controlSize(state.style == 1 ? .regular : .small)
    }
}

// MARK: - Factory Logic (Encapsulada)
extension SwiftToggleView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(ToggleInit.self, from: jsonData)
        
        let state = ToggleState(id: id, isOn: initial.value ?? false, prompt: initial.prompt ?? "")
        state.style = initial.style ?? ((initial.isswitch ?? false) ? 1 : 0)
        state.icon = initial.icon ?? ""
        state.subtitle = initial.subtitle ?? ""
        
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .toggle, id: id)
        // Usamos una función global para la geometría básica
        setupGeometry(item: item, from: initial)
        return item
    }
}

// MARK: - Protocols & Data Structures
public struct ToggleInit: Codable, GeometryProtocol {
    public let value: Bool?, prompt: String?, isswitch: Bool?, interactive: Bool?, style: Int?
    public let icon: String?, subtitle: String?
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let parentwidth, parentheight: Double?
}

// Helper para aplicar el estilo dinámicamente
extension View {
    @ViewBuilder
    func applyToggleStyle(_ style: Int) -> some View {
        switch style {
        case 0: self.toggleStyle(.checkbox)
        case 1: self.toggleStyle(.switch)
        case 2: self.toggleStyle(.button)
        default: self.toggleStyle(.switch)
        }
    }
}
