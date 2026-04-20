import Foundation
import AppKit

/// El motor de despacho central (El Cerebro) - Versión Unificada sw
public class SwDispatcher {
    public static let shared = SwDispatcher()
    
    /// Diccionario de comandos ejecutables (Ahora devuelven un resultado opcional)
    private var commands: [String: ([String: Any]) async -> [String: Any]?] = [:]
    
    /// Tacógrafo para registrar cambios de estado hacia Harbour
    private var stateChanges: [String: [String: Any]] = [:]
    
    private let queue = DispatchQueue(label: "com.fivemac.dispatcher", attributes: .concurrent)

    private init() {
        registerBaseCommands()
    }
    
    public func register(_ name: String, action: @escaping ([String: Any]) async -> [String: Any]?) {
        queue.sync(flags: .barrier) {
            commands[name.lowercased()] = action
        }
    }
    
    @discardableResult
    public func execute(name: String, params: [String: Any]) async -> [String: Any]? {
        let cleanName = name.lowercased()
        let resolvedParams = resolvePiping(params)
        
        var action: (([String: Any]) async -> [String: Any]?)?
        queue.sync {
            action = commands[cleanName]
        }
        
        if let action = action {
            let result = await action(resolvedParams)
            if let res = result {
               print("🏝️ [Dispatcher] '\(name)' devolvió: \(res)")
            } else {
               print("🏝️ [Dispatcher] ADVERTENCIA: '\(name)' devolvió NIL.")
            }
            return result
        } else {
            print("SwDispatcher: Error - Comando '\(name)' no registrado en el motor Swift.")
            return nil
        }
    }
    
    // MARK: - State Tracking (The Train Reporting)
    
    public func recordChange(id: String, property: String, value: Any) {
        let cleanProp = property.lowercased()
        
        queue.sync(flags: .barrier) {
            if stateChanges[id] == nil { stateChanges[id] = [:] }
            stateChanges[id]?[cleanProp] = value
        }
    }
    
    public func flushStateChanges() -> [String: [String: Any]] {
        var changes: [String: [String: Any]] = [:]
        queue.sync(flags: .barrier) {
            changes = stateChanges
            stateChanges = [:]
        }
        return changes
    }
    
    // MARK: - Piping Logic (ctx:)
    
    private func resolvePiping(_ params: [String: Any]) -> [String: Any] {
        var resolved = params
        for (key, value) in params {
            if let str = value as? String, str.hasPrefix("ctx:") {
                let contextKey = String(str.dropFirst(4))
                if let contextValue = SwWorkflowContext.shared.get(contextKey) {
                    resolved[key] = contextValue
                }
            }
        }
        return resolved
    }

    // MARK: - Registro de Comandos Core
    
    private func registerBaseCommands() {
        NetworkCommands.register(in: self)
        FilesCommands.register(in: self)
        ViewsCommands.register(in: self)
        SystemCommands.register(in: self)
    }

    // DISPATCHER UNIVERSAL: Mapea directamente nombres de propiedades
    public static func registerUniversal() {

        self.shared.register("apply") { params in
            let id = ((params["id"] as? String) ?? (params["p1"] as? String) ?? "").lowercased()
            
            return await MainActor.run { () -> [String: Any]? in
                if let state = ViewRegistry.getState(for: id) as? SwApplyable {
                    for (key, value) in params {
                        // DETONADOR DE BORRADO UNIVERSAL
                        if key.lowercased() == "close" && (value as? Bool == true || (value as? Int == 1)) {
                             ViewRegistry.removeFromParent(id: id)
                             if let window = ViewRegistry.get("NSWindow_\(id)") as? NSWindow {
                                 window.close()
                             }
                             let deadIds = ViewRegistry.recursiveClean(id: id)
                             let idsStr = deadIds.map { "\"\($0)\"" }.joined(separator: ", ")
                             let json = "{\"_system\":{\"unregister\":[\(idsStr)]}}"
                             Harbour.call("SW_PIPELINE_SYNC", json)
                             continue
                        }

                        if key != "id" && !key.hasPrefix("p") && key != "cmd" {
                            state.apply(property: key, value: value)
                            
                            if let item = ViewRegistry.getItem(for: id) {
                                switch key.lowercased() {
                                case "top":
                                    if let n = (value as? NSNumber)?.doubleValue { item.y = n }
                                case "left":
                                    if let n = (value as? NSNumber)?.doubleValue { item.x = n }
                                case "width":
                                    if let n = (value as? NSNumber)?.doubleValue { item.itemWidth = n }
                                case "height":
                                    if let n = (value as? NSNumber)?.doubleValue { item.itemHeight = n }
                                case "resizemask":
                                    if let n = (value as? NSNumber)?.intValue { item.resizemask = n }
                                case "interactive":
                                    if let b = value as? Bool { item.isInteractive = b }
                                default:
                                    break
                                }
                            }
                            self.shared.recordChange(id: id, property: key, value: value)
                        }
                    }
                    return ["status": "ok", "id": id]
                }
                return nil
            }
        }
    }
}
