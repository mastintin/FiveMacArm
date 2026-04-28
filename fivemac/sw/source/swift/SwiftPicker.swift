import SwiftUI
import Observation

// MARK: - SwiftPicker View
public struct SwiftPickerView: View {
    @Bindable var state: SwiftPickerState
    
    public var body: some View {
        if state.isVisible {
            VStack(alignment: .leading, spacing: 4) {
                if !state.prompt.isEmpty {
                    Text(state.prompt)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Group {
                    switch state.style {
                    case 1:
                        renderPicker().pickerStyle(.segmented)
                    case 2:
                        renderPicker().pickerStyle(.radioGroup)
                    case 3:
                        renderPicker().pickerStyle(.palette)
                    case 4:
                        renderPicker().pickerStyle(.inline)
                    default:
                        renderPicker().pickerStyle(.menu)
                    }
                }
                .labelsHidden()
                .disabled(!state.isEnabled)
                .onChange(of: state.selection) { oldValue, newValue in
                    SwiftBridge.onChange(state.id, newValue)
                }
            }
        }
    }

    @ViewBuilder
    private func renderPicker() -> some View {
        Picker("", selection: $state.selection) {
            ForEach(state.items, id: \.self) { item in
                Text(item).tag(item)
            }
        }
    }
}

// MARK: - SwiftPicker State
@Observable
public class SwiftPickerState: SwApplyable {
    public let id: String
    public var items: [String] = []
    public var selection: String = ""
    public var prompt: String = ""
    public var style: Int = 0 // 0: Menu, 1: Segmented, 2: Radio, 3: Palette
    public var isVisible: Bool = true
    public var isEnabled: Bool = true
    
    public init(id: String, items: [String] = [], selection: String = "") {
        self.id = id
        self.items = items
        self.selection = selection
    }
    
    @MainActor
    public func apply(property: String, value: Any) {
        let prop = property.lowercased()
        switch prop {
        case "items":
            if let s = value as? String {
                // Harbour suele enviar un JSON string para arrays complejos
                if let data = s.data(using: .utf8),
                   let arr = try? JSONDecoder().decode([String].self, from: data) {
                    self.items = arr
                } else {
                    // O una lista separada por comas?
                    self.items = s.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                }
            } else if let arr = value as? [String] {
                self.items = arr
            }
        case "selection", "value":
            if let s = value as? String { self.selection = s }
        case "prompt", "title":
            if let s = value as? String { self.prompt = s }
        case "style":
            if let i = SwUtils.toInt(value) { self.style = i }
        case "visible":
            self.isVisible = SwUtils.toBool(value)
        case "enabled":
            self.isEnabled = SwUtils.toBool(value)
        default:
            break
        }
    }
}
