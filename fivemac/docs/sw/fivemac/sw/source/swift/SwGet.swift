import SwiftUI
import Observation

// MARK: - SwiftGet View
public struct SwiftGetView: View {
    @Bindable var state: SwiftGetState
    @FocusState private var isFocused: Bool
    
    public var body: some View {
        if state.isVisible {
            VStack(alignment: .leading, spacing: 4) {
                // Etiqueta Integrada (Prompt)
                if !state.prompt.isEmpty {
                    Text(state.prompt)
                        .foregroundStyle(state.promptColor)
                        .font(.system(size: CGFloat(state.promptSize), weight: .bold))
                        .padding(.leading, 2)
                }

                ZStack(alignment: .leading) {
                    // Fondo Dinámico Premium
                    Group {
                        if let vib = state.vibranceMaterial {
                            RoundedRectangle(cornerRadius: state.cornerRadius)
                                .fill(vib)
                        } else {
                            RoundedRectangle(cornerRadius: state.cornerRadius)
                                .fill(state.backgroundColor)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: state.cornerRadius)
                            .stroke(state.isInvalid ? Color.red : (isFocused ? Color.accentColor.opacity(0.8) : Color.white.opacity(0.1)), 
                                    lineWidth: (isFocused || state.isInvalid) ? 2 : 1)
                    )
                    .shadow(color: state.isInvalid ? .red.opacity(0.3) : (isFocused ? state.shadowColor.opacity(0.4) : .clear), radius: 8)

                    HStack(spacing: 8) {
                        // Icono Lateral Opcional
                        if !state.systemImage.isEmpty {
                            Image(systemName: state.systemImage)
                                .foregroundStyle(state.iconColor ?? state.color)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.leading, 10)
                        }

                        // El Campo de Texto Nativo
                        ZStack(alignment: .leading) {
                            if state.text.isEmpty && !isFocused {
                                Text(state.placeholder)
                                    .foregroundStyle(.secondary.opacity(0.5))
                                    .font(.system(size: 14))
                                    .frame(maxWidth: .infinity, alignment: mapAlignment(state.alignment))
                                    .allowsHitTesting(false)
                            }

                            Group {
                                if state.issecure {
                                    SecureField("", text: $state.text)
                                } else {
                                    TextField("", text: $state.text, selection: $state.selection)
                                }
                            }
                            .textFieldStyle(.plain)
                            .focused($isFocused)
                            .onChange(of: isFocused) { oldValue, newValue in
                                if !newValue {
                                    SwiftBridge.onValid(state.id, state.text)
                                }
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(state.color)
                            .multilineTextAlignment(state.alignment)
                            .disabled(!state.isEnabled || state.isReadOnly)
                        }
                        .padding(.leading, state.systemImage.isEmpty ? 12 : 2)
                        .padding(.trailing, state.text.isEmpty ? 12 : 2)

                        // Botón de Borrado
                        if !state.text.isEmpty && state.isEnabled {
                            Button(action: { state.text = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary.opacity(0.6))
                                    .font(.system(size: 14))
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 10)
                        }
                    }
                    .onChange(of: state.text) { oldValue, newValue in
                        if oldValue != newValue {
                            applyModernFormatting(newValue)
                        }
                    }
                }
                .frame(height: 38)
            }
            .opacity(state.isEnabled ? 1.0 : 0.6)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isFocused)
            .animation(.easeInOut, value: state.text.isEmpty)
            .onChange(of: state.isFocusedRequest) { _, newValue in
                if newValue {
                    isFocused = true
                    state.isFocusedRequest = false // Reset para futuras peticiones
                }
            }
        }
    }

    /// Implementación reactiva de PICTURES (PoC Style)
    private func applyModernFormatting(_ newValue: String) {
        let pic = state.picture.uppercased()
        var formatted = newValue

        // 1. Mayúsculas automáticas (@!)
        if pic.contains("@!") {
            formatted = formatted.uppercased()
        }
        
        // 2. Lógica Avanzada de Números y Miles (@E o PICTURES con 9)
        if pic.contains("9") {
            let isEuro = pic.contains("@E")
            let decimalSep: Character = isEuro ? "," : "."
            let thousandSep: String = isEuro ? "." : ","
            
            // Limpiamos todo lo que no sea número o el separador decimal
            let allowedDigits = CharacterSet.decimalDigits
            var clean = newValue.filter { char in
                char.unicodeScalars.allSatisfy { allowedDigits.contains($0) } || char == decimalSep
            }
            
            // Si hay un punto infiltrado (teclado numérico estándar), lo convertimos al separador decimal de la picture
            if isEuro {
                clean = clean.replacingOccurrences(of: ".", with: ",")
            }
            
            // Solo permitimos una coma/punto decimal
            let components = clean.components(separatedBy: String(decimalSep))
            if components.count > 1 {
                clean = components[0] + String(decimalSep) + components[1]
            }
            
            // Formatear parte entera con separadores de miles
            let parts = clean.components(separatedBy: String(decimalSep))
            var integerPart = parts[0]
            
            // Quitamos ceros a la izquierda innecesarios (opcional, pero queda más limpio)
            if integerPart.count > 1 && integerPart.hasPrefix("0") {
                integerPart = String(Int(integerPart) ?? 0)
            }
            
            // Insertar separadores de miles cada 3 dígitos
            var result = ""
            let reversedInt = String(integerPart.reversed())
            for (index, char) in reversedInt.enumerated() {
                if index > 0 && index % 3 == 0 {
                    result += thousandSep
                }
                result += String(char)
            }
            integerPart = String(result.reversed())
            
            // Re-ensamblar
            formatted = integerPart
            if parts.count > 1 {
                formatted += String(decimalSep) + parts[1]
            }
        }

        // Si ha habido cambios por el formateo, actualizamos el estado
        if formatted != newValue {
            state.text = formatted
        }
        
        // Notificar a Harbour del valor actual (formateado o no)
        SwiftBridge.onChange(state.id, formatted)
    }

    private func mapAlignment(_ alignment: TextAlignment) -> Alignment {
        switch alignment {
            case .center: return .center
            case .trailing: return .trailing
            default: return .leading
        }
    }
}

// MARK: - SwiftGet State (Movido de SwCommon para modularidad)
@Observable
public class SwiftGetState: SwApplyable {
    public let id: String
    public var text: String = ""
    public var picture: String = ""
    public var placeholder: String = ""
    public var prompt: String = ""
    public var issecure: Bool = false
    public var isVisible: Bool = true
    public var isEnabled: Bool = true
    
    // UI Premium
    public var color: AnyShapeStyle = AnyShapeStyle(.primary)
    public var backgroundColor: AnyShapeStyle = AnyShapeStyle(Color.white.opacity(0.1))
    public var vibranceMaterial: AnyShapeStyle? = mapMaterial(".ultrathin")
    public var cornerRadius: CGFloat = 10
    public var systemImage: String = ""
    public var iconColor: AnyShapeStyle? = nil
    public var shadowRadius: Double = 0
    public var shadowColor: Color = Color.blue.opacity(0.3)
    
    // Prompt properties
    public var promptColor: AnyShapeStyle = AnyShapeStyle(.secondary)
    public var promptSize: Double = 12
    
    // Selection & Focus
    public var selection: TextSelection? = nil
    public var isFocusedRequest: Bool = false
    
    // Status & Alignment
    public var isInvalid: Bool = false
    public var isReadOnly: Bool = false
    public var alignment: TextAlignment = .leading
    
    public init(id: String, text: String = "", picture: String = "", placeholder: String = "", issecure: Bool = false) {
        self.id = id
        self.text = text
        self.picture = picture
        self.placeholder = placeholder
        self.issecure = issecure
    }
    
    @MainActor
    public func apply(property: String, value: Any) {
        let prop = property.lowercased()
        switch prop {
        case "text":
            if let s = value as? String, self.text != s { self.text = s }
        case "picture":
            if let s = value as? String { self.picture = s }
        case "placeholder":
            if let s = value as? String { self.placeholder = s }
        case "prompt":
            if let s = value as? String { self.prompt = s }
        case "promptcolor":
            if let sVal = value as? String { self.promptColor = mapColorStyle(sVal) }
        case "promptsize":
            if let n = (value as? NSNumber)?.doubleValue ?? (value as? Double) { self.promptSize = n }
        case "issecure":
            if let b = value as? Bool { self.issecure = b }
        case "visible":
            if let b = value as? Bool { self.isVisible = b }
            else if let n = value as? Int { self.isVisible = (n == 1) }
        case "enabled":
            if let b = value as? Bool { self.isEnabled = b }
            else if let n = value as? Int { self.isEnabled = (n == 1) }
        case "color":
            if let sVal = value as? String { self.color = mapColorStyle(sVal) }
        case "backcolor":
            if let sVal = value as? String { self.backgroundColor = mapColorStyle(sVal) }
        case "vibrance":
            if let sVal = value as? String { self.vibranceMaterial = mapMaterial(sVal) }
        case "icon":
            if let sVal = value as? String { self.systemImage = sVal }
        case "iconcolor":
            if let sVal = value as? String { self.iconColor = mapColorStyle(sVal) }
        case "shadow":
            if let n = (value as? NSNumber)?.doubleValue ?? (value as? Double) { self.shadowRadius = n }
        case "shadowcolor":
            if let sVal = value as? String { self.shadowColor = Color(hex: sVal) }
        case "selectall":
            if value as? Bool == true || (value as? Int == 1) {
                self.selection = TextSelection(range: self.text.startIndex..<self.text.endIndex)
            }
        case "selectstart":
            self.selection = TextSelection(insertionPoint: self.text.startIndex)
        case "selectend":
            self.selection = TextSelection(insertionPoint: self.text.endIndex)
        case "focus":
            if value as? Bool == true || (value as? Int == 1) {
                self.isFocusedRequest = true
            }
        case "gotopos":
            if let n = (value as? NSNumber)?.intValue ?? (value as? Int) {
                let index = self.text.index(self.text.startIndex, offsetBy: n, limitedBy: self.text.endIndex) ?? self.text.endIndex
                self.selection = TextSelection(insertionPoint: index)
            }
        case "invalid":
            if let b = value as? Bool { self.isInvalid = b }
            else if let n = value as? Int { self.isInvalid = (n == 1) }
        case "readonly":
            if let b = value as? Bool { self.isReadOnly = b }
            else if let n = value as? Int { self.isReadOnly = (n == 1) }
        case "alignment":
            if let n = (value as? NSNumber)?.intValue ?? (value as? Int) {
                switch n {
                    case 1: self.alignment = .center
                    case 2: self.alignment = .trailing
                    default: self.alignment = .leading
                }
            }
        default:
            break
        }
    }
}

// MARK: - Factory Logic (Encapsulada)
extension SwiftGetView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(GetInit.self, from: jsonData)
        
        let state = SwiftGetState(id: id, 
                                 text: initial.text ?? "", 
                                 picture: initial.picture ?? "", 
                                 placeholder: initial.placeholder ?? "", 
                                 issecure: initial.issecure ?? false)
        state.prompt = initial.prompt ?? ""
        
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .get, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

// MARK: - Protocols & Data Structures
public struct GetInit: Codable, GeometryProtocol {
    public let text, picture, placeholder, prompt: String?, issecure: Bool?
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let parentwidth, parentheight: Double?
}


