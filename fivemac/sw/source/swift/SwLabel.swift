import SwiftUI
import Observation

// MARK: - Label State
@Observable
public class SwiftLabelState: SwApplyable {
    public let id: String
    public var text: String
    public var fontSize: Double = 13.0
    public var fontBase: Font? = nil
    public var fontModifiers: String = ""
    public var color: AnyShapeStyle = AnyShapeStyle(.primary)
    public var textAlignment: TextAlignment = .leading
    public var backgroundColor: AnyShapeStyle? = nil
    public var shadowRadius: Double = 0
    public var shadowColor: Color = Color.black.opacity(0.4)
    public var textShadowRadius: Double = 0
    public var textShadowColor: Color = Color.black.opacity(0.4)
    public var underline: Bool = false
    public var strikethrough: Bool = false
    public var vibranceMaterial: AnyShapeStyle? = nil
    public var isVisible: Bool = true
    public var systemImage: String = ""
    public var iconColor: AnyShapeStyle? = nil
    public var borderShape: String = ""
    public var iconSize: Double = 0
    
    public init(id: String, text: String) {
        self.id = id
        self.text = text
    }
    
    @MainActor
    public func apply(property: String, value: Any) {
        let prop = property.lowercased()
        
        if prop == "text" || prop == "caption" {
            if let sVal = value as? String { self.text = sVal }
        } else if prop == "fontsize" {
            if let sVal = value as? String {
                self.fontBase = mapFontBase(sVal)
            } else {
                self.fontBase = nil
                if let nVal = value as? Double { self.fontSize = nVal }
                else if let nVal = value as? NSNumber { self.fontSize = nVal.doubleValue }
            }
        } else if prop == "fontstyle" {
            if let sVal = value as? String { 
                self.fontModifiers = sVal 
                self.fontBase = mapFontBase(sVal) // <--- ¡Añadido para que reconozca .title1!
                self.underline = sVal.lowercased().contains(".underline")
                self.strikethrough = sVal.lowercased().contains(".strikethrough")
            }
        } else if prop == "color" {
            if let sVal = value as? String {
                if sVal.hasPrefix(".") { self.color = mapColorStyle(sVal) }
                else { self.color = AnyShapeStyle(Color(hex: sVal)) }
            }
            else if let nVal = value as? Int { self.color = AnyShapeStyle(Color(hex: String(format: "#%06X", nVal))) }
        } else if prop == "alignment" {
            if let n = (value as? NSNumber)?.intValue ?? (value as? Int) {
                switch n {
                case 1: self.textAlignment = .center
                case 2: self.textAlignment = .trailing
                default: self.textAlignment = .leading
                }
            }
        } else if prop == "backcolor" {
            if let sVal = value as? String {
                print("🎨 [SwiftLabel] Setting backcolor: '\(sVal)'")
                if sVal.isEmpty {
                    print("🎨 [SwiftLabel] Clearing backcolor (nil)")
                    self.backgroundColor = nil
                } else if sVal.hasPrefix(".") {
                    self.backgroundColor = mapColorStyle(sVal)
                } else {
                    self.backgroundColor = AnyShapeStyle(Color(hex: sVal))
                }
            }
            else if let nVal = value as? Int { self.backgroundColor = AnyShapeStyle(Color(hex: String(format: "#%06X", nVal))) }
        } else if prop == "shadow" {
            if let n = (value as? NSNumber)?.doubleValue ?? (value as? Double) { 
                print("🌑 [SwiftLabel] Shadow Radius: \(n)")
                self.shadowRadius = n 
            }
        } else if prop == "shadowcolor" {
            if let sVal = value as? String { self.shadowColor = Color(hex: sVal) }
            else if let nVal = value as? Int { self.shadowColor = Color(hex: String(format: "#%06X", nVal)) }
            print("🌑 [SwiftLabel] Box Shadow Color: \(self.shadowColor)")
        } else if prop == "textshadow" {
            if let n = (value as? NSNumber)?.doubleValue ?? (value as? Double) { self.textShadowRadius = n }
        } else if prop == "textshadowcolor" {
            if let sVal = value as? String { self.textShadowColor = Color(hex: sVal) }
            else if let nVal = value as? Int { self.textShadowColor = Color(hex: String(format: "#%06X", nVal)) }
        } else if prop == "vibrance" {
            if let sVal = value as? String { self.vibranceMaterial = mapMaterial(sVal) }
        } else if prop == "visible" {
            if let bVal = value as? Bool { self.isVisible = bVal }
            else if let nVal = value as? Int { self.isVisible = (nVal == 1) }
        } else if prop == "icon" {
            if let sVal = value as? String { self.systemImage = sVal }
        } else if prop == "iconcolor" {
            if let sVal = value as? String {
                if sVal.hasPrefix(".") { self.iconColor = mapColorStyle(sVal) }
                else { self.iconColor = AnyShapeStyle(Color(hex: sVal)) }
            }
        } else if prop == "bordershape" {
            if let sVal = value as? String { self.borderShape = sVal.lowercased() }
        } else if prop == "iconsize" {
            if let n = SwUtils.toDouble(value) { self.iconSize = n }
        }
    }

    private func mapFontBase(_ s: String) -> Font {
        let clean = s.lowercased()
        if clean.contains("largetitle") { return .largeTitle }
        if clean.contains("title1") || (clean.contains("title") && !clean.contains("title2") && !clean.contains("title3")) { return .title }
        if clean.contains("title2") { return .title2 }
        if clean.contains("title3") { return .title3 }
        if clean.contains("headline") { return .headline }
        if clean.contains("subheadline") { return .subheadline }
        if clean.contains("body") { return .body }
        if clean.contains("callout") { return .callout }
        if clean.contains("footnote") { return .footnote }
        if clean.contains("caption2") { return .caption2 }
        if clean.contains("caption") { return .caption }
        
        // Si es un número (tamaño fijo)
        let onlyDigits = clean.replacingOccurrences(of: ".", with: "").filter { "0123456789".contains($0) }
        if let size = Double(onlyDigits) { return .system(size: size) }
        
        return .body
    }
}

// MARK: - Label View
public struct SwiftLabelView: View {
    @Bindable var state: SwiftLabelState
    
    var finalFont: Font {
        var f = state.fontBase ?? .system(size: state.fontSize)
        let mods = state.fontModifiers.lowercased()
        if mods.contains(".bold") { f = f.bold() }
        if mods.contains(".italic") { f = f.italic() }
        if mods.contains(".monospaced") { f = f.monospaced() }
        return f
    }

    var alignment: Alignment {
        switch state.textAlignment {
        case .center: return .center
        case .trailing: return .trailing
        default: return .leading
        }
    }

    public var body: some View {
        if state.isVisible {
            let hasBack = state.backgroundColor != nil || state.vibranceMaterial != nil
            
            HStack(spacing: 8) {
                if !state.systemImage.isEmpty {
                    let _ = print("🖼️ [SwiftLabel] Rendering icon: '\(state.systemImage)' with size: \(state.iconSize)")
                    Image(systemName: state.systemImage)
                        .font(.system(size: state.iconSize > 0 ? state.iconSize : 20)) // Forzamos mínimo 20 si hay icono
                        .foregroundStyle(state.iconColor ?? state.color)
                }
                
                Text(state.text)
                    .underline(state.underline)
                    .strikethrough(state.strikethrough)
            }
            .font(finalFont)
            .multilineTextAlignment(state.textAlignment)
            .shadow(color: state.textShadowRadius > 0 ? state.textShadowColor : .clear, radius: state.textShadowRadius)
            .foregroundStyle(state.color)
            .padding(.horizontal, state.borderShape == ".capsule" ? 12 : (hasBack ? 8 : 0))
            .padding(.vertical, state.borderShape == ".capsule" ? 6 : (hasBack ? 8 : 0))
            .background {
                if state.borderShape == ".capsule" {
                    Capsule().fill(state.backgroundColor ?? AnyShapeStyle(Color.clear))
                } else if hasBack {
                    RoundedRectangle(cornerRadius: 8).fill(state.backgroundColor ?? AnyShapeStyle(Color.clear))
                }
            }
            .background {
                if let vib = state.vibranceMaterial {
                    if state.borderShape == ".capsule" { Capsule().fill(vib) }
                    else { RoundedRectangle(cornerRadius: 8).fill(vib) }
                }
            }
            .shadow(color: state.shadowRadius > 0 ? state.shadowColor : .clear, radius: state.shadowRadius)
            .padding(state.shadowRadius)
            .frame(maxWidth: .infinity, alignment: alignment)
        }
    }
}

// MARK: - Factory Logic (Encapsulada)
extension SwiftLabelView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(LabelInit.self, from: jsonData)
        
        let state = SwiftLabelState(id: id, text: initial.text ?? "")
        print("🏷️ [SwiftLabel] Creating '\(id)' with text: '\(state.text)' shape: '\(initial.bordershape ?? "none")' color: '\(initial.color ?? "none")'")
        if let b = initial.bordershape { state.borderShape = b }
        if let c = initial.color { state.apply(property: "color", value: c) }
        if let bc = initial.backcolor { state.apply(property: "backcolor", value: bc) }
        if let ic = initial.icon { state.systemImage = ic }
        if let icc = initial.iconcolor { state.apply(property: "iconcolor", value: icc) }
        if let fs = initial.fontstyle { state.apply(property: "fontstyle", value: fs) }
        if let isz = initial.iconsize { state.iconSize = isz }
        
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .text, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

// MARK: - Protocols & Data Structures
public struct LabelInit: Codable, GeometryProtocol {
    public let text: String?
    public let bordershape: String?, color: String?, backcolor: String?, icon: String?, iconcolor: String?, fontstyle: String?
    public let iconsize: Double?
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let hasscroll: Bool?
    public let parentwidth, parentheight: Double?
}
