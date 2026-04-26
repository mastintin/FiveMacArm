import SwiftUI

public class SwUtils {
    
    /// Convierte cualquier valor a Double de forma segura
    public static func toDouble(_ value: Any) -> Double? {
        if let d = value as? Double { return d }
        if let n = value as? NSNumber { return n.doubleValue }
        if let s = value as? String { return Double(s) }
        if let i = value as? Int { return Double(i) }
        return nil
    }
    
    /// Convierte cualquier valor a Int de forma segura
    public static func toInt(_ value: Any) -> Int? {
        if let i = value as? Int { return i }
        if let n = value as? NSNumber { return n.intValue }
        if let s = value as? String { return Int(s) }
        return nil
    }
    
    /// Convierte cualquier valor a Bool de forma segura
    public static func toBool(_ value: Any) -> Bool {
        if let b = value as? Bool { return b }
        if let i = value as? Int { return i != 0 }
        if let n = value as? NSNumber { return n.boolValue }
        if let s = value as? String {
            let lower = s.lowercased()
            return lower == "true" || lower == "yes" || lower == "1" || lower == ".t."
        }
        return false
    }
    
    /// Convierte un Hex String (#RRGGBB) a Color de SwiftUI
    public static func hexToColor(_ hex: String) -> Color? {
        if hex.isEmpty { return nil }
        return Color(hex: hex)
    }
}
