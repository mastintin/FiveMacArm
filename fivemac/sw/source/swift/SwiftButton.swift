import SwiftUI
import Observation

// MARK: - Button State
@Observable
public class SwiftButtonState: SwApplyable {
    public var id: String
    public var caption: String
    public var backgroundColor: AnyShapeStyle = AnyShapeStyle(Color.blue)
    public var foregroundColor: AnyShapeStyle = AnyShapeStyle(Color.white)
    public var vibranceMaterial: AnyShapeStyle? = nil
    public var cornerRadius: CGFloat = 8
    public var isVisible: Bool = true
    public var isEnabled: Bool = true
    public var systemImage: String = ""
    public var iconColor: AnyShapeStyle? = nil
    public var shadowRadius: Double = 0
    public var shadowColor: Color = Color.black.opacity(0.3)
    public var fontSize: Double = 13.0
    public var fontModifiers: String = ""
    public var role: ButtonRole? = nil
    public var isRepeatable: Bool = false
    public var borderShape: String = ".rounded"
    public var pipelineJSON: String? = nil
    
    public init(id: String, caption: String) {
        self.id = id
        self.caption = caption
    }

    @MainActor
    public func apply(property: String, value: Any) {
        let prop = property.lowercased()
        switch prop {
        case "caption", "text", "settext":
            self.caption = String(describing: value)
        case "color", "fgcolor":
            if let sVal = value as? String {
                if sVal.hasPrefix(".") { self.foregroundColor = mapColorStyle(sVal) }
                else { self.foregroundColor = AnyShapeStyle(Color(hex: sVal)) }
            }
        case "backcolor", "bgcolor":
            if let sVal = value as? String {
                if sVal.isEmpty { self.backgroundColor = AnyShapeStyle(Color.clear) }
                else if sVal.hasPrefix(".") { self.backgroundColor = mapColorStyle(sVal) }
                else { self.backgroundColor = AnyShapeStyle(Color(hex: sVal)) }
            } else if let nVal = value as? Int {
                self.backgroundColor = AnyShapeStyle(Color(hex: String(format: "#%06X", nVal)))
            }
        case "vibrance":
            if let sVal = value as? String { self.vibranceMaterial = mapMaterial(sVal) }
        case "corner", "cornerradius":
            if let n = (value as? NSNumber)?.doubleValue ?? (value as? Double) { self.cornerRadius = CGFloat(n) }
        case "visible":
            if let b = value as? Bool { self.isVisible = b }
            else if let n = value as? Int { self.isVisible = (n == 1) }
        case "enabled":
            if let b = value as? Bool { self.isEnabled = b }
            else if let n = value as? Int { self.isEnabled = (n == 1) }
        case "icon":
            if let sVal = value as? String { self.systemImage = sVal }
        case "iconcolor":
            if let sVal = value as? String {
                if sVal.hasPrefix(".") { self.iconColor = mapColorStyle(sVal) }
                else { self.iconColor = AnyShapeStyle(Color(hex: sVal)) }
            }
        case "shadow":
            if let n = (value as? NSNumber)?.doubleValue ?? (value as? Double) { self.shadowRadius = n }
        case "shadowcolor":
            if let sVal = value as? String { self.shadowColor = Color(hex: sVal) }
        case "fontsize":
            if let n = (value as? NSNumber)?.doubleValue ?? (value as? Double) { self.fontSize = n }
        case "fontstyle":
            if let sVal = value as? String { self.fontModifiers = sVal }
        case "role":
            if let n = (value as? NSNumber)?.intValue ?? (value as? Int) {
                switch n {
                case 1: self.role = .destructive
                case 2: self.role = .cancel
                default: self.role = nil
                }
            }
        case "repeat":
            if let b = value as? Bool { self.isRepeatable = b }
            else if let n = value as? Int { self.isRepeatable = (n == 1) }
        case "bordershape":
            if let sVal = value as? String { self.borderShape = sVal.lowercased() }
        case "pipeline_json":
            self.pipelineJSON = value as? String
        default:
            break
        }
    }
}

// MARK: - Button Style
struct PremiumButtonStyle: ButtonStyle {
    @Bindable var state: SwiftButtonState
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(state.foregroundColor)
            .opacity(configuration.isPressed ? 0.7 : (isEnabled ? 1.0 : 0.5))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background {
                if state.borderShape.contains(".capsule") {
                    Capsule().fill(state.vibranceMaterial ?? AnyShapeStyle(Color.clear))
                        .opacity(isEnabled ? 1.0 : 0.3)
                } else if state.borderShape.contains(".circle") {
                    Circle().fill(state.vibranceMaterial ?? AnyShapeStyle(Color.clear))
                        .opacity(isEnabled ? 1.0 : 0.3)
                } else {
                    RoundedRectangle(cornerRadius: state.cornerRadius).fill(state.vibranceMaterial ?? AnyShapeStyle(Color.clear))
                        .opacity(isEnabled ? 1.0 : 0.3)
                }
            }
            .background {
                if state.borderShape.contains(".capsule") {
                    Capsule().fill(state.backgroundColor)
                        .grayscale(isEnabled ? 0 : 0.6)
                        .opacity(isEnabled ? 1.0 : 0.3)
                } else if state.borderShape.contains(".circle") {
                    Circle().fill(state.backgroundColor)
                        .grayscale(isEnabled ? 0 : 0.6)
                        .opacity(isEnabled ? 1.0 : 0.3)
                } else {
                    RoundedRectangle(cornerRadius: state.cornerRadius).fill(state.backgroundColor)
                        .grayscale(isEnabled ? 0 : 0.6)
                        .opacity(isEnabled ? 1.0 : 0.3)
                }
            }
            .shadow(color: state.shadowRadius > 0 ? state.shadowColor : .clear, radius: state.shadowRadius)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Button View
public struct SwiftButtonView: View {
    @Bindable var state: SwiftButtonState
    
    var finalFont: Font {
        var f = Font.system(size: state.fontSize)
        let mods = state.fontModifiers.lowercased()
        if mods.contains(".bold") { f = f.bold() }
        if mods.contains(".italic") { f = f.italic() }
        if mods.contains(".monospaced") { f = f.monospaced() }
        return f
    }

    public var body: some View {
        if state.isVisible {
            Button(role: state.role, action: {
                if let batchJSON = state.pipelineJSON, let data = batchJSON.data(using: .utf8) {
                    Task { @MainActor in
                        await executeWorkflowBatch(jsonData: data)
                    }
                } else {
                    let json = "{\"\(state.id)\":{\"event\":\"click\"}}"
                    Harbour.call("SW_UPDATE_HB", json)
                }
            }) {
                HStack(spacing: 6) {
                    if !state.systemImage.isEmpty {
                        Image(systemName: state.systemImage)
                        .foregroundStyle(state.iconColor ?? state.foregroundColor)
                    }
                    Text(state.caption)
                        .font(finalFont)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(PremiumButtonStyle(state: state))
            .disabled(!state.isEnabled)
            .buttonRepeatBehavior(state.isRepeatable ? .enabled : .disabled)
        }
    }
}

// MARK: - Factory Logic (Encapsulada)
extension SwiftButtonView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(ButtonInit.self, from: jsonData)
        
        let state = SwiftButtonState(id: id, caption: initial.caption ?? initial.title ?? "")
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .button, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

// MARK: - Protocols & Data Structures
public struct ButtonInit: Codable, GeometryProtocol {
    public let caption: String?, title: String?
    public let width, height, top, left: Double?
    public let resizemask: Int?
}
