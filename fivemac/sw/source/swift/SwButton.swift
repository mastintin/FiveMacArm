import SwiftUI
import Observation

// MARK: - Button State
@Observable
public class SwiftButtonState: SwApplyable {
    public var id: String
    public var caption: String
    public var backgroundColor: AnyShapeStyle = AnyShapeStyle(Color.blue)
    public var foregroundColor: AnyShapeStyle = AnyShapeStyle(Color.primary) // Por defecto Negro
    public var vibranceMaterial: AnyShapeStyle? = nil
    public var cornerRadius: CGFloat = 12
    public var isVisible: Bool = true
    public var isEnabled: Bool = true
    public var isGlass: Bool = false
    public var glassTint: Color = .clear
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
                let smart = parseSmartStyle(sVal)
                self.foregroundColor = smart.style
            }
        case "backcolor", "bgcolor":
            if let sVal = value as? String {
                let smart = parseSmartStyle(sVal)
                self.backgroundColor = smart.style
            }
        case "style":
             if let sVal = value as? String {
                let smart = parseSmartStyle(sVal)
                self.isGlass = smart.isMaterial
                self.glassTint = smart.baseColor
             }
        case "glass":
             if let sVal = value as? String {
                let smart = parseSmartStyle(sVal)
                self.glassTint = smart.baseColor
             }
        case "icon":
            if let sVal = value as? String { self.systemImage = sVal }
        case "iconcolor":
            if let sVal = value as? String {
                let smart = parseSmartStyle(sVal)
                self.iconColor = smart.style
            }
        case "shadow":
            if let n = (value as? NSNumber)?.doubleValue ?? (value as? Double) { self.shadowRadius = n }
        case "fontsize":
            if let n = (value as? NSNumber)?.doubleValue ?? (value as? Double) { self.fontSize = n }
        case "bordershape":
            if let sVal = value as? String { self.borderShape = sVal.lowercased() }
        case "pipeline_json":
            self.pipelineJSON = value as? String
        default:
            break
        }
    }
}

// MARK: - Glass Button Style (Artesanal Premium Completo)
struct GlassButtonStyle: ButtonStyle {
    @Bindable var state: SwiftButtonState
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(state.foregroundColor)
            .padding(.horizontal, state.borderShape.contains(".circle") ? 10 : 20)
            .padding(.vertical, 10)
            .background {
                if state.borderShape.contains(".capsule") {
                    ZStack {
                        Capsule().fill(.ultraThinMaterial)
                        if state.glassTint != .clear { Capsule().fill(state.glassTint.opacity(0.45)).blendMode(.overlay) }
                        Capsule().fill(LinearGradient(colors: [.white.opacity(0.4), .clear], startPoint: .top, endPoint: .center)).padding(2)
                        Capsule().stroke(LinearGradient(colors: [.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.5)
                    }
                } else if state.borderShape.contains(".circle") {
                    ZStack {
                        Circle().fill(.ultraThinMaterial)
                        if state.glassTint != .clear { Circle().fill(state.glassTint.opacity(0.45)).blendMode(.overlay) }
                        Circle().fill(LinearGradient(colors: [.white.opacity(0.4), .clear], startPoint: .top, endPoint: .center)).padding(2)
                        Circle().stroke(LinearGradient(colors: [.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.5)
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: state.cornerRadius).fill(.ultraThinMaterial)
                        if state.glassTint != .clear { RoundedRectangle(cornerRadius: state.cornerRadius).fill(state.glassTint.opacity(0.45)).blendMode(.overlay) }
                        RoundedRectangle(cornerRadius: state.cornerRadius).fill(LinearGradient(colors: [.white.opacity(0.4), .clear], startPoint: .top, endPoint: .center)).padding(2)
                        RoundedRectangle(cornerRadius: state.cornerRadius).stroke(LinearGradient(colors: [.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.5)
                    }
                }
            }
            .opacity(isEnabled ? 1.0 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .shadow(color: (state.glassTint == .clear ? Color.black : state.glassTint).opacity(0.2), 
                    radius: configuration.isPressed ? 3 : 6, x: 0, y: 3)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Premium Button Style (Standard)
struct PremiumButtonStyle: ButtonStyle {
    @Bindable var state: SwiftButtonState
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(state.foregroundColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(state.backgroundColor, in: RoundedRectangle(cornerRadius: state.cornerRadius))
            .shadow(color: state.shadowRadius > 0 ? state.shadowColor : .clear, radius: state.shadowRadius)
    }
}

// MARK: - Button View
public struct SwiftButtonView: View {
    @Bindable var state: SwiftButtonState
    
    public var body: some View {
        if state.isVisible {
            Button(action: {
                if let batchJSON = state.pipelineJSON, let data = batchJSON.data(using: .utf8) {
                    Task { @MainActor in await executeWorkflowBatch(jsonData: data) }
                } else {
                    let json = "{\"\(state.id)\":{\"event\":\"click\"}}"
                    Harbour.call("SW_UPDATE_HB", json)
                }
            }) {
                ZStack {
                    HStack(spacing: state.caption.isEmpty ? 0 : 6) {
                        if !state.systemImage.isEmpty {
                            Image(systemName: state.systemImage)
                                .font(.system(size: (state.borderShape.contains(".circle") && state.caption.isEmpty) ? 28 : state.fontSize))
                                .foregroundStyle(state.iconColor ?? state.foregroundColor)
                                .offset(x: (state.systemImage == "play.fill" && state.caption.isEmpty) ? 2 : 0)
                        }
                        
                        if !state.caption.isEmpty {
                            Text(state.caption)
                                .font(.system(size: state.fontSize))
                                .foregroundStyle(state.foregroundColor)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .buttonStyle(state.isGlass ? AnyButtonStyle(GlassButtonStyle(state: state)) : AnyButtonStyle(PremiumButtonStyle(state: state)))
        }
    }
}

struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView
    init<S: ButtonStyle>(_ style: S) { _makeBody = { configuration in AnyView(style.makeBody(configuration: configuration)) } }
    func makeBody(configuration: Configuration) -> AnyView { _makeBody(configuration) }
}

// MARK: - Factory Logic
extension SwiftButtonView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(ButtonInit.self, from: jsonData)
        let state = SwiftButtonState(id: id, caption: initial.caption ?? "")
        
        if let s = initial.style { 
            let smart = parseSmartStyle(s)
            state.isGlass = smart.isMaterial
            state.glassTint = smart.baseColor
        }
        if let b = initial.bordershape { state.borderShape = b }
        if let i = initial.icon { state.systemImage = i }
        if let g = initial.glass {
            let smart = parseSmartStyle(g)
            state.glassTint = smart.baseColor
        }
        if let c = initial.color {
            let smart = parseSmartStyle(c)
            state.foregroundColor = smart.style
        }
        
        ViewRegistry.register(state, for: id)
        let item = StackItem(type: .button, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

public struct ButtonInit: Codable, GeometryProtocol {
    public let caption: String?
    public let style: String?, glass: String?, bordershape: String?, icon: String?, color: String?
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let parentwidth, parentheight: Double?
}
