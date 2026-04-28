import SwiftUI
import Observation

// MARK: - SwiftPicker View
public struct SwiftPickerView: View {
    @Bindable var state: SwiftPickerState
    
    public var body: some View {
        if state.isVisible {
            VStack(alignment: .leading, spacing: 6) {
                // Etiqueta superior Premium
                if !state.prompt.isEmpty {
                    Text(state.prompt.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary.opacity(0.8))
                        .padding(.leading, 2)
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
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onAppear {
                // Auto-selección inicial si está vacío
                if state.selection.isEmpty && !state.items.isEmpty {
                    state.selection = state.parseItemText(state.items[0])
                }
            }
            .labelsHidden()
            .disabled(!state.isEnabled)
            .onChange(of: state.selection) { oldValue, newValue in
                SwiftBridge.onChange(state.id, newValue)
            }
        }
    }
    
    @ViewBuilder
    private func renderPicker() -> some View {
        Picker("", selection: $state.selection) {
            ForEach(state.items, id: \.self) { itemRaw in
                let parts = itemRaw.components(separatedBy: "|")
                let text = parts[0]
                let icon = parts.count > 1 ? parts[1] : ""
                
                HStack {
                    if !icon.isEmpty {
                        Image(systemName: icon)
                    }
                    Text(text)
                }
                .tag(text)
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
    public var style: Int = 0 
    public var isVisible: Bool = true
    public var isEnabled: Bool = true
    
    public init(id: String, items: [String] = [], selection: String = "") {
        self.id = id
        self.items = items
        self.selection = selection
    }
    
    public func parseItemText(_ raw: String) -> String {
        return raw.components(separatedBy: "|")[0]
    }
    
    @MainActor
    public func apply(property: String, value: Any) {
        let prop = property.lowercased()
        switch prop {
        case "items":
            if let s = value as? String {
                if let data = s.data(using: .utf8),
                   let arr = try? JSONDecoder().decode([String].self, from: data) {
                    self.items = arr
                } else {
                    self.items = s.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                }
            } else if let arr = value as? [String] {
                self.items = arr
            }
            if self.selection.isEmpty && !self.items.isEmpty {
                self.selection = parseItemText(self.items[0])
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

// MARK: - Factory Logic
extension SwiftPickerView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(PickerInit.self, from: jsonData)
        
        let state = SwiftPickerState(id: id)
        state.prompt = initial.prompt ?? ""
        state.style = initial.style ?? 0
        
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .picker, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

public struct PickerInit: Codable, GeometryProtocol {
    public let prompt: String?
    public let style: Int?
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let parentwidth, parentheight: Double?
}
