import SwiftUI
import Observation

// MARK: - Progress State
@Observable
public class ProgressState: SwApplyable {
    public let id: String
    public var value: Double
    public var min: Double
    public var max: Double
    public var prompt: String = ""
    public var subtitle: String = ""
    public var icon: String = ""
    public var tintColor: Color = .blue
    public var isIndeterminate: Bool = false
    public var style: Int = 0 // 0: linear, 1: circular
    public var isVisible: Bool = true

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
            if let dVal = (value as? NSNumber)?.doubleValue { self.value = dVal }
        case "min":
            if let dVal = (value as? NSNumber)?.doubleValue { self.min = dVal }
        case "max":
            if let dVal = (value as? NSNumber)?.doubleValue { self.max = dVal }
        case "prompt":
            if let sVal = value as? String { self.prompt = sVal }
        case "subtitle":
            if let sVal = value as? String { self.subtitle = sVal }
        case "icon":
            if let sVal = value as? String { self.icon = sVal }
        case "tintcolor", "color":
            if let sVal = value as? String {
                if sVal.hasPrefix(".") { self.tintColor = mapBaseColor(sVal) }
                else { self.tintColor = Color(hex: sVal) }
            }
        case "indeterminate":
            if let bVal = value as? Bool { self.isIndeterminate = bVal }
            else if let iVal = value as? Int { self.isIndeterminate = (iVal != 0) }
        case "style":
            if let iVal = (value as? NSNumber)?.intValue { self.style = iVal }
        case "visible":
            if let bVal = value as? Bool { self.isVisible = bVal }
            else if let iVal = value as? Int { self.isVisible = (iVal != 0) }
        default:
            break
        }
    }
}

// MARK: - Progress View
public struct SwiftProgressView: View {
    @Bindable var state: ProgressState

    public var body: some View {
        if state.isVisible {
            VStack(alignment: .leading, spacing: 6) {
                // Header: Icon + Prompt
                if !state.prompt.isEmpty || !state.icon.isEmpty {
                    HStack(spacing: 6) {
                        if !state.icon.isEmpty {
                            Image(systemName: state.icon)
                                .foregroundStyle(state.tintColor)
                        }
                        if !state.prompt.isEmpty {
                            Text(state.prompt)
                                .font(.headline)
                        }
                    }
                }

                // The actual progress
                if state.isIndeterminate {
                    if state.style == 1 {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(state.tintColor)
                    } else {
                        ProgressView()
                            .progressViewStyle(.linear)
                            .tint(state.tintColor)
                    }
                } else {
                    let total = max(1.0, state.max - state.min)
                    let current = state.value - state.min
                    
                    if state.style == 1 {
                        ProgressView(value: max(0, min(current, total)), total: total)
                            .progressViewStyle(.circular)
                            .tint(state.tintColor)
                    } else {
                        ProgressView(value: max(0, min(current, total)), total: total)
                            .progressViewStyle(.linear)
                            .tint(state.tintColor)
                    }
                }

                // Subtitle
                if !state.subtitle.isEmpty {
                    Text(state.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(4)
        }
    }
}

// MARK: - Factory Logic
extension SwiftProgressView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(ProgressInit.self, from: jsonData)
        
        let state = ProgressState(id: id,
                                 value: initial.value ?? 0,
                                 min: initial.min ?? 0,
                                 max: initial.max ?? 100)
        
        state.prompt = initial.prompt ?? ""
        state.subtitle = initial.subtitle ?? ""
        state.icon = initial.icon ?? ""
        state.isIndeterminate = initial.indeterminate ?? false
        state.style = initial.style ?? 0
        
        if let colorHex = initial.tintcolor, !colorHex.isEmpty {
            if colorHex.hasPrefix(".") { state.tintColor = mapBaseColor(colorHex) }
            else { state.tintColor = Color(hex: colorHex) }
        }
        
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .progress, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

// MARK: - Data Structures
public struct ProgressInit: Codable, GeometryProtocol {
    public let value, min, max: Double?
    public let prompt, subtitle, icon, tintcolor: String?
    public let indeterminate: Bool?
    public let style: Int?
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let parentwidth, parentheight: Double?
}
