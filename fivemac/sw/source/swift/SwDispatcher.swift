import Foundation
import AppKit

/// El motor de despacho central (El Cerebro) - Versión Unificada sw
public class SwDispatcher {
    public static let shared = SwDispatcher()
    
    /// Diccionario de comandos ejecutables
    private var commands: [String: ([String: Any]) async -> Void] = [:]
    
    /// Tacógrafo para registrar cambios de estado hacia Harbour
    private var stateChanges: [String: [String: Any]] = [:]
    
    private let queue = DispatchQueue(label: "com.fivemac.dispatcher", attributes: .concurrent)

    private init() {
        registerBaseCommands()
    }
    
    public func register(_ name: String, action: @escaping ([String: Any]) async -> Void) {
        queue.sync(flags: .barrier) {
            commands[name.lowercased()] = action
        }
    }
    
    public func execute(name: String, params: [String: Any]) async {
        let cleanName = name.lowercased()
        let resolvedParams = resolvePiping(params)
        
        var action: (([String: Any]) async -> Void)?
        queue.sync {
            action = commands[cleanName]
        }
        
        if let action = action {
            await action(resolvedParams)
        } else {
            print("SwDispatcher: Error - Comando '\(name)' no registrado en el motor Swift.")
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
        // Pasamos 'self' (la instancia actual que se está creando) 
        // para evitar llamar a .shared antes de tiempo (Recursion Lock)
        NetworkCommands.register(in: self)
        FilesCommands.register(in: self)
        ViewsCommands.register(in: self)
        SystemCommands.register(in: self)
    }

    // DISPATCHER UNIVERSAL: Mapea directamente nombres de propiedades
    public static func registerUniversal() {

        self.shared.register("apply") { params in
            let id = ((params["id"] as? String) ?? (params["p1"] as? String) ?? "").lowercased()
            await MainActor.run {
                if let state = ViewRegistry.getState(for: id) as? SwApplyable {
                    for (key, value) in params {
                        if key != "id" && !key.hasPrefix("p") && key != "cmd" {
                            state.apply(property: key, value: value)
                            
                            // MEJORA: Si es una propiedad de geometría, actualizar también el StackItem (Item de Layout)
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
                                default:
                                    break
                                }
                            }

                            // INFORMAMOS DE VUELTA: Para que Harbour confirme su hState
                            self.shared.recordChange(id: id, property: key, value: value)
                        }
                    }
                }
            }
        }
    }
}
