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
        }
    }

    private func mapFontBase(_ s: String) -> Font {
        let clean = s.lowercased().replacingOccurrences(of: ".", with: "")
        switch clean {
        case "largetitle": return .largeTitle
        case "title": return .title
        case "title2": return .title2
        case "title3": return .title3
        case "headline": return .headline
        case "subheadline": return .subheadline
        case "body": return .body
        case "callout": return .callout
        case "footnote": return .footnote
        case "caption": return .caption
        case "caption2": return .caption2
        default: 
            if let size = Double(clean) { return .system(size: size) }
            return .body
        }
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
                    Image(systemName: state.systemImage)
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
            .padding(hasBack ? 8 : 0)
            .background {
                if let vib = state.vibranceMaterial {
                    Rectangle().fill(vib)
                }
            }
            .background {
                if let bg = state.backgroundColor {
                    Rectangle().fill(bg)
                }
            }
            .cornerRadius(hasBack ? 8 : 0)
            .shadow(color: state.shadowRadius > 0 ? state.shadowColor : .clear, radius: state.shadowRadius)
            .padding(state.shadowRadius)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
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
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .text, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

// MARK: - Protocols & Data Structures
public struct LabelInit: Codable, GeometryProtocol {
    public let text: String?
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let hasscroll: Bool?
}
