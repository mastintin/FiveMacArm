import Foundation
import AppKit

/// Comandos universales (Apply, Piping, etc.)
internal struct UniversalCommands {
    
    static func register(in sd: SwDispatcher) {
        sd.register("apply") { params in
            let id = ((params["id"] as? String) ?? (params["p1"] as? String) ?? "").lowercased()
            
            return await MainActor.run { () -> [String: Any]? in
                if let state = ViewRegistry.getState(for: id) as? SwApplyable {
                    for (key, value) in params {
                        // Comando especial: Cerrar
                        if key.lowercased() == "close" && (value as? Bool == true || (value as? Int == 1)) {
                             ViewRegistry.removeFromParent(id: id)
                             if let window = ViewRegistry.get("NSWindow_\(id)") as? NSWindow {
                                 window.close()
                             }
                             let deadIds = ViewRegistry.recursiveClean(id: id)
                             let idsStr = deadIds.map { "\"\($0)\"" }.joined(separator: ", ")
                             let json = "{\"_system\":{\"unregister\":[\(idsStr)]}}"
                             Harbour.call("SW_UPDATE_HB", json)
                             continue
                        }

                        if key != "id" && !key.hasPrefix("p") && key != "cmd" {
                            print("🏝️ [Apply] ID: \(id), Prop: \(key), Val: \(value)")
                            state.apply(property: key, value: value)
                            
                            if let item = ViewRegistry.getItem(for: id) {
                                switch key.lowercased() {
                                    case "top": if let n = (value as? NSNumber)?.doubleValue { item.y = n }
                                    case "left": if let n = (value as? NSNumber)?.doubleValue { item.x = n }
                                    case "width": 
                                        if let n = (value as? NSNumber)?.doubleValue { 
                                            print("🏝️ [Geometry] ID: \(id), Width -> \(n)")
                                            item.itemWidth = n 
                                        }
                                    case "height": 
                                        if let n = (value as? NSNumber)?.doubleValue { 
                                            print("🏝️ [Geometry] ID: \(id), Height -> \(n)")
                                            item.itemHeight = n 
                                        }
                                    case "resizemask": if let n = (value as? NSNumber)?.intValue { item.resizemask = n }
                                    case "interactive": if let b = value as? Bool { item.isInteractive = b }
                                    default: break
                                }
                            }
                            sd.recordChange(id: id, property: key, value: value)
                        }
                    }
                    return ["status": "ok", "id": id]
                } else {
                    print("⚠️ [Apply] Error - ID no encontrado en Registry: \(id)")
                }
                return nil
            }
        }
    }
    
    /// Resuelve comodines (ctx:) en los parámetros
    static func resolvePiping(_ params: [String: Any]) -> [String: Any] {
        var resolved = params
        for (key, value) in params {
            if let str = value as? String, str.hasPrefix("ctx:") {
                let contextKey = String(str.dropFirst(4))
                print("🔍 [Piping] Intentando resolver: \(str) para clave: \(key)")
                
                // Comodines de sistema
                if contextKey == "now" || contextKey == "time" {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm:ss"
                    let timeStr = formatter.string(from: Date())
                    print("🕒 [Piping] OK -> \(timeStr)")
                    resolved[key] = timeStr
                    continue
                }

                if let contextValue = SwWorkflowContext.shared.get(contextKey) {
                    resolved[key] = contextValue
                }
            }
        }
        return resolved
    }
}
