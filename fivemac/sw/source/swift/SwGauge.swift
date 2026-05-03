import SwiftUI
import Observation

// MARK: - Gauge State
@Observable
public class GaugeState: SwApplyable {
    public let id: String
    public var value: Double
    public var min: Double
    public var max: Double
    public var prompt: String = ""
    public var subtitle: String = ""
    public var icon: String = ""
    public var tintColor: Color = .blue
    public var style: Int = 0 // 0: accessoryCircular, 1: accessoryLinear, 2: capacity
    public var isVisible: Bool = true
    public var isEnabled: Bool = true
    public var showValueLabel: Bool = true
    public var unitText: String = ""

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
        case "prompt", "text":
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
        case "style":
            if let iVal = (value as? NSNumber)?.intValue { self.style = iVal }
        case "visible", "lvisible":
            if let bVal = value as? Bool { self.isVisible = bVal }
            else if let iVal = value as? Int { self.isVisible = (iVal != 0) }
        case "enabled", "lenabled":
            if let bVal = value as? Bool { self.isEnabled = bVal }
            else if let iVal = value as? Int { self.isEnabled = (iVal != 0) }
        case "showvaluelabel", "showvalue":
            if let bVal = value as? Bool { self.showValueLabel = bVal }
            else if let iVal = value as? Int { self.showValueLabel = (iVal != 0) }
        case "unittext", "unit":
            if let sVal = value as? String { self.unitText = sVal }
        default:
            break
        }
    }
}

// MARK: - Gauge View
public struct SwiftGaugeView: View {
    @Bindable var state: GaugeState

    public var body: some View {
        if state.isVisible {
            VStack(alignment: .center, spacing: 6) {
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

                gaugeBody
                    .padding(.vertical, (state.style == 0 || state.style == 2) ? 15 : 0)

                if !state.subtitle.isEmpty {
                    Text(state.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .opacity(state.isEnabled ? 1.0 : 0.5)
            .disabled(!state.isEnabled)
            .padding(8)
        }
    }

    @ViewBuilder
    private var gaugeBody: some View {
        let total = max(1.0, state.max - state.min)
        let current = max(0, min(state.value - state.min, total))
        let pct = Int((current / total) * 100)

        switch state.style {
        case 0: // accessoryCircular
            Gauge(value: state.value, in: state.min...state.max) {
            } currentValueLabel: {
                if state.showValueLabel {
                    valueText(state.value)
                }
            }
            .gaugeStyle(.accessoryCircular)
            .tint(state.tintColor)
            .scaleEffect(1.5)

        case 1: // accessoryLinear
            Gauge(value: state.value, in: state.min...state.max) {
            } currentValueLabel: {
                if state.showValueLabel {
                    valueText(state.value)
                }
            }
            .gaugeStyle(.accessoryLinear)
            .tint(state.tintColor)

        case 2: // full size (default circular larger)
            Gauge(value: state.value, in: state.min...state.max) {
            } currentValueLabel: {
                if state.showValueLabel {
                    valueText(state.value)
                }
            }
            .gaugeStyle(.accessoryCircular)
            .tint(state.tintColor)
            .scaleEffect(2.0)

        default: // default circular
            Gauge(value: state.value, in: state.min...state.max) {
            } currentValueLabel: {
                if state.showValueLabel {
                    valueText(state.value)
                }
            }
            .gaugeStyle(.accessoryCircular)
            .tint(state.tintColor)
            .scaleEffect(1.5)
        }
    }

    @ViewBuilder
    private func valueText(_ value: Double) -> some View {
        let displayValue = Int(value)
        if state.unitText.isEmpty {
            Text("\(displayValue)")
                .font(.caption2.monospacedDigit())
        } else {
            VStack(spacing: 0) {
                Text("\(displayValue)")
                    .font(.caption2.monospacedDigit())
                Text(state.unitText)
                    .font(.system(size: 7))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Factory Logic
extension SwiftGaugeView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(GaugeInit.self, from: jsonData)

        let state = GaugeState(id: id,
                               value: initial.value ?? 0,
                               min: initial.min ?? 0,
                               max: initial.max ?? 100)

        state.prompt = initial.prompt ?? ""
        state.subtitle = initial.subtitle ?? ""
        state.icon = initial.icon ?? ""
        state.style = initial.style ?? 0
        state.showValueLabel = initial.showvaluelabel ?? true
        state.unitText = initial.unittext ?? ""
        state.isEnabled = initial.enabled ?? true
        state.isVisible = initial.visible ?? true

        if let colorHex = initial.tintcolor, !colorHex.isEmpty {
            if colorHex.hasPrefix(".") { state.tintColor = mapBaseColor(colorHex) }
            else { state.tintColor = Color(hex: colorHex) }
        }

        ViewRegistry.register(state, for: id)

        let item = StackItem(type: .gauge, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

// MARK: - Data Structures
public struct GaugeInit: Codable, GeometryProtocol {
    public let value, min, max: Double?
    public let prompt, subtitle, icon, tintcolor, unittext: String?
    public let style: Int?
    public let showvaluelabel, enabled, visible: Bool?
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let parentwidth, parentheight: Double?
}
