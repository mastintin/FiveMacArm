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
        // Buscamos el tipo de control para poder traducir la propiedad
        var mappedProperty = property
        if let item = ViewRegistry.getItem(for: id) {
            let controlType = "\(item.type)".lowercased()
            mappedProperty = SwCapabilities.shared.getHarbourField(for: controlType, cmd: property)
        }
        
        queue.sync(flags: .barrier) {
            if stateChanges[id] == nil { stateChanges[id] = [:] }
            stateChanges[id]?[mappedProperty] = value
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
}
