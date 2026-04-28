import SwiftUI
import UniformTypeIdentifiers

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
    
    /// Parsea fechas de Harbour (YYYYMMDD o YYYY-MM-DD)
    public static func parseHarbourDate(_ s: String) -> Date? {
        if s.count == 8 { // YYYYMMDD
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            return formatter.date(from: s)
        } else { // Probar ISO (YYYY-MM-DD)
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
            return formatter.date(from: s)
        }
    }
}

// MARK: - View Extensions
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Manejador Universal de Drag & Drop para cualquier componente
    func swDropHandler(id: String, isTargeted: Binding<Bool>) -> some View {
        self.onDrop(of: [.fileURL, .image, .item, .data, .url], delegate: UniversalDropDelegate(id: id, isTargeted: isTargeted))
    }
}

// MARK: - Universal Drop Delegate (Final Clean Version)
struct UniversalDropDelegate: DropDelegate {
    let id: String
    @Binding var isTargeted: Bool
    
    func performDrop(info: DropInfo) -> Bool {
        isTargeted = false
        let providers = info.itemProviders(for: [.fileURL, .image, .item, .data, .url])
        
        for provider in providers {
            // 1. Intentamos cargar como URL (archivos y links)
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { (url, _) in
                    if let u = url {
                        self.processAndSend(url: u)
                    }
                }
            }
            // 2. Fallback para datos directos
            else {
                let types = ["public.file-url", "public.url", "public.data"]
                for type in types {
                    if provider.hasItemConformingToTypeIdentifier(type) {
                        provider.loadItem(forTypeIdentifier: type, options: nil) { (item, _) in
                            if let url = item as? URL {
                                self.processAndSend(url: url)
                            } else if let data = item as? Data, let path = String(data: data, encoding: .utf8) {
                                self.processAndSend(path: path)
                            }
                        }
                    }
                }
            }
        }
        return true
    }
    
    private func processAndSend(url: URL) {
        let content: String
        if url.isFileURL {
            content = url.standardized.path.replacingOccurrences(of: "file://", with: "").removingPercentEncoding ?? url.path
        } else {
            content = url.absoluteString
        }
        self.dispatchToHarbour(content)
    }
    
    private func processAndSend(path: String) {
        let cleanPath = path.replacingOccurrences(of: "file://", with: "").removingPercentEncoding ?? path
        self.dispatchToHarbour(cleanPath)
    }
    
    private func dispatchToHarbour(_ content: String) {
        DispatchQueue.main.async {
            let json = "{\"\(id)\":{\"event\":\"drop\",\"files\":[\"\(content)\"]}}"
            Harbour.call("SW_UPDATE_HB", json)
        }
    }
    
    func dropEntered(info: DropInfo) { isTargeted = true }
    func dropExited(info: DropInfo) { isTargeted = false }
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.fileURL, .image, .item, .data, .url])
    }
}

extension Color {
    var isClear: Bool {
        return self == .clear
    }
}
