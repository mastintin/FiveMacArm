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
    public var tintStyle: AnyShapeStyle = AnyShapeStyle(Color.blue)
    public var tintColor: Color = .blue // For shadows and internal logic
    public var isGlass: Bool = false
    public var style: Int = 0 
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
                let smart = parseSmartStyle(sVal)
                self.isGlass = smart.isMaterial
                self.tintStyle = smart.style
                self.tintColor = smart.baseColor
            }
        case "style":
            if let iVal = (value as? NSNumber)?.intValue { self.style = iVal }
        case "visible", "lvisible":
            self.isVisible = SwUtils.toBool(value)
        case "enabled", "lenabled":
            self.isEnabled = SwUtils.toBool(value)
        case "showvaluelabel", "showvalue":
            self.showValueLabel = SwUtils.toBool(value)
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
        let _ = print("🎨 [Swift-Gauge] Dibujando body para \(state.id). Visible: \(state.isVisible)")
        if state.isVisible {
            VStack(alignment: .center, spacing: 15) {
                if !state.prompt.isEmpty || !state.icon.isEmpty {
                    HStack(spacing: 8) {
                        if !state.icon.isEmpty {
                            Image(systemName: state.icon).foregroundStyle(state.tintColor)
                        }
                        if !state.prompt.isEmpty {
                            Text(state.prompt)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary.opacity(0.8))
                        }
                    }
                }

                gaugeBody
                    .padding(.top, 5)
                    .padding(.vertical, (state.style == 0 || state.style == 2) ? 10 : 0)

                if !state.subtitle.isEmpty {
                    Text(state.subtitle).font(.caption).foregroundStyle(.secondary)
                }
            }
            .opacity(state.isEnabled ? 1.0 : 0.5)
            .disabled(!state.isEnabled)
            .padding(8)
        }
    }

    @ViewBuilder
    private var gaugeBody: some View {
        switch state.style {
        case 1: // Linear
            Gauge(value: state.value, in: state.min...state.max) {
            } currentValueLabel: {
                if state.showValueLabel { valueText }
            }
            .gaugeStyle(.accessoryLinear)
            .tint(state.tintStyle)

        case 2: // Circular Large
            Gauge(value: state.value, in: state.min...state.max) {
            } currentValueLabel: {
                if state.showValueLabel { valueText }
            }
            .gaugeStyle(.accessoryCircular)
            .tint(state.tintStyle)
            .scaleEffect(1.8)

        case 3: // Premium Custom
            PremiumGaugeView(state: state)

        case 4: // Speedometer (Half Circle)
            SpeedometerGaugeView(state: state)

        default: // Circular Standard (Style 0)
            Gauge(value: state.value, in: state.min...state.max) {
            } currentValueLabel: {
                if state.showValueLabel { valueText }
            }
            .gaugeStyle(.accessoryCircular)
            .tint(state.tintStyle)
            .scaleEffect(1.3)
        }
    }

    private var valueText: some View {
        Text("\(Int(state.value))\(state.unitText)").font(.caption2.monospacedDigit())
    }
}

// MARK: - Factory Logic
extension SwiftGaugeView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        print("📊 [Swift-Gauge] Creando Gauge ID: \(id)")
        let decoder = JSONDecoder()
        let initial = try decoder.decode(GaugeInit.self, from: jsonData)
        print("📊 [Swift-Gauge] Decodificación exitosa para \(id). Estilo: \(initial.style ?? 0)")

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
            let low = colorHex.lowercased()
            state.isGlass = low.contains("glass") || low.contains("thin")
            state.tintStyle = mapColorStyle(colorHex)
            
            var cleanColor = colorHex.lowercased()
                .replacingOccurrences(of: ".glass", with: "")
                .replacingOccurrences(of: ".thin", with: "")
                .trimmingCharacters(in: .whitespaces)

            if cleanColor == "." || cleanColor.isEmpty {
                state.tintColor = .cyan
            } else {
                if !cleanColor.hasPrefix(".") { cleanColor = "." + cleanColor }
                state.tintColor = mapBaseColor(cleanColor)
            }
        } else {
            print("📊 [Swift-Gauge] No se recibió tintcolor, usando defecto.")
        }

        ViewRegistry.register(state, for: id)
        let item = StackItem(type: .gauge, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

public struct GaugeInit: Codable, GeometryProtocol {
    public let value, min, max: Double?
    public let prompt, subtitle, icon, tintcolor, unittext: String?
    public let style: Int?
    public let showvaluelabel, enabled, visible: Bool? 
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let parentwidth, parentheight: Double?
}

// MARK: - Premium Gauge Implementation
struct PremiumGaugeView: View {
    var state: GaugeState
    
    var body: some View {
        let percentage = (state.max > state.min) ? (state.value - state.min) / (state.max - state.min) : 0
        let _ = print("🎨 [Swift-Gauge-Premium] Dibujando \(state.id). TintColor: \(state.tintColor)")
        
        ZStack {
            // Background Track
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 10)
            
            // The Gauge Indicator
            if state.isGlass {
                // HIGH QUALITY SYNTHETIC GLASS EFFECT (Simplified for maximum compatibility)
                // 1. Solid vibrant base
                Circle()
                    .trim(from: 0, to: CGFloat(min(max(percentage, 0), 1.0)))
                    .stroke(
                        state.tintColor.opacity(0.8),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                // 2. White Shine on top (Subtle highlight)
                Circle()
                    .trim(from: 0, to: CGFloat(min(max(percentage, 0), 1.0)))
                    .stroke(
                        Color.white.opacity(0.3),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                    )
                    .offset(x: -1.5, y: -1.5)
                    .rotationEffect(.degrees(-90))
                    .blur(radius: 0.5)
            } else {
                // Standard Color/Gradient Style
                Circle()
                    .trim(from: 0, to: CGFloat(min(max(percentage, 0), 1.0)))
                    .stroke(
                        state.tintStyle,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
            
            // Outer Glow
            Circle()
                .trim(from: 0, to: CGFloat(min(max(percentage, 0), 1.0)))
                .stroke(state.tintColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .blur(radius: 6)
                .opacity(0.5)

            VStack(spacing: -2) {
                Text("\(Int(state.value))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                
                if !state.unitText.isEmpty {
                    Text(state.unitText)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(minWidth: 80, minHeight: 80)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: state.value)
    }
}

// MARK: - Speedometer Implementation
struct SpeedometerGaugeView: View {
    var state: GaugeState
    
    var body: some View {
        let percentage = (state.max > state.min) ? (state.value - state.min) / (state.max - state.min) : 0
        
        VStack {
            ZStack {
                // Background Track (Half Circle)
                Circle()
                    .trim(from: 0.1, to: 0.9)
                    .stroke(Color.primary.opacity(0.1), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(90))
                
                // Base layer for materials
                Circle()
                    .trim(from: 0.1, to: 0.1 + (0.8 * CGFloat(min(max(percentage, 0), 1.0))))
                    .stroke(
                        state.tintColor.opacity(0.2),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(90))

                // Progress Track with Dynamic Style
                if state.isGlass {
                    // Glass Speedometer
                    Circle()
                        .trim(from: 0.1, to: 0.1 + (0.8 * CGFloat(min(max(percentage, 0), 1.0))))
                        .stroke(
                            state.tintColor.opacity(0.8),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(90))
                    
                    Circle()
                        .trim(from: 0.1, to: 0.1 + (0.8 * CGFloat(min(max(percentage, 0), 1.0))))
                        .stroke(
                            Color.white.opacity(0.3),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .offset(x: -1.5, y: -1.5)
                        .rotationEffect(.degrees(90))
                        .blur(radius: 0.5)
                } else {
                    Circle()
                        .trim(from: 0.1, to: 0.1 + (0.8 * CGFloat(min(max(percentage, 0), 1.0))))
                        .stroke(
                            state.tintStyle,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(90))
                }
                
                // Outer Glow for Speedometer
                Circle()
                    .trim(from: 0.1, to: 0.1 + (0.8 * CGFloat(min(max(percentage, 0), 1.0))))
                    .stroke(state.tintColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(90))
                    .blur(radius: 6)
                    .opacity(0.5)
                
                VStack(spacing: 0) {
                    Text("\(Int(state.value))")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .contentTransition(.numericText())
                    
                    if !state.unitText.isEmpty {
                        Text(state.unitText)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                }
                .offset(y: 10)
            }
            .frame(minWidth: 120, minHeight: 100)
        }
        .animation(.interpolatingSpring(stiffness: 60, damping: 10), value: state.value)
    }
}
