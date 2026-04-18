import SwiftUI
import Observation

// MARK: - SwiftGet View
public struct SwiftGetView: View {
    @Bindable var state: GetState
    @FocusState private var isFocused: Bool
    
    public var body: some View {
        ZStack(alignment: .leading) {
            // Fondo estilo Glassmorphism
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.1))
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFocused ? Color.blue.opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1.5)
                )
                .shadow(color: isFocused ? .blue.opacity(0.3) : .clear, radius: 8, x: 0, y: 0)

            Group {
                if state.issecure {
                    SecureField("", text: $state.text)
                } else {
                    TextField("", text: $state.text)
                }
            }
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .focused($isFocused)
            .font(.system(size: 14))
            .foregroundStyle(.primary)
            // Lógica reactiva de PICTURES 100% SwiftUI
            .onChange(of: state.text) { oldValue, newValue in
                print("🏝️ [Swift-UI] ID: \(state.id), onChange: '\(oldValue)' -> '\(newValue)'")
                if oldValue != newValue {
                    applyModernFormatting(newValue)
                }
            }
            
            // Placeholder dinámico (Glass touch)
            if state.text.isEmpty && !isFocused {
                Text(state.placeholder)
                    .foregroundStyle(.secondary.opacity(0.6))
                    .padding(.horizontal, 12)
                    .allowsHitTesting(false)
                    .font(.system(size: 14, weight: .light))
                    .transition(.opacity)
            }
        }
        .frame(height: 36)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
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
}

