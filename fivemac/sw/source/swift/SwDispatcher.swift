import Foundation

/// El motor de despacho central (El Cerebro) - Versión Simplificada HSW
public class SwDispatcher {
    public static let shared = SwDispatcher()
    
    /// Diccionario de comandos ejecutables
    private var commands: [String: ([String: Any]) async -> [String: Any]?] = [:]
    
    /// Tacógrafo para registrar cambios de estado hacia Harbour
    private var stateChanges: [String: [String: Any]] = [:]
    
    /// Cola de eventos pendientes para que Harbour los recoja
    private var eventQueue: [[String: Any]] = []
    
    /// Cola de despacho para asegurar thread-safety (Lectores/Escritores)
    private let queue = DispatchQueue(label: "com.fivemac.dispatcher", attributes: .concurrent)

    private init() {
        // Registro de módulos de comandos
        NetworkCommands.register(in: self)
        FilesCommands.register(in: self)
        ViewsCommands.register(in: self)
        SystemCommands.register(in: self)
        TimerCommands.register(in: self)
        UniversalCommands.register(in: self)
    }
    
    /// Registra un nuevo comando en el despachador
    public func register(_ name: String, action: @escaping ([String: Any]) async -> [String: Any]?) {
        queue.sync(flags: .barrier) {
            commands[name.lowercased()] = action
        }
    }
    
    /// Ejecuta un comando por nombre
    @discardableResult
    public func execute(name: String, params: [String: Any]) async -> [String: Any]? {
        let cleanName = name.lowercased()
        
        // 1. Resolver Piping (Comodines ctx:)
        let resolvedParams = UniversalCommands.resolvePiping(params)
        
        // 2. Buscar y ejecutar acción
        var action: (([String: Any]) async -> [String: Any]?)?
        queue.sync {
            action = commands[cleanName]
        }
        
        if let action = action {
            return await action(resolvedParams)
        } else {
            print("SwDispatcher: Error - Comando '\(name)' no registrado.")
            return nil
        }
    }

    // MARK: - Bridge Helpers (Internal)

    func executeSyncInternal(json: String) async -> String {
        guard let data = json.data(using: .utf8),
              let actions = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return "{}"
        }
        
        var finalResult: [String: Any] = [:]
        for params in actions {
            guard let cmd = (params["cmd"] as? String) ?? (params["func"] as? String) else { continue }
            if let res = await self.execute(name: cmd, params: params) {
                finalResult = res
            }
        }
        
        // Sincronización automática: Si hay cambios de estado acumulados, notificamos a Harbour
        let changes = self.flushStateChanges()
        if !changes.isEmpty {
            if let data = try? JSONSerialization.data(withJSONObject: changes),
               let jsonStr = String(data: data, encoding: .utf8) {
                // Usamos el hilo principal para llamar a Harbour y evitar conflictos
                DispatchQueue.main.async {
                    Harbour.call("SW_UPDATE_HB", jsonStr)
                }
            }
        }
        
        if let resData = try? JSONSerialization.data(withJSONObject: finalResult),
           let resStr = String(data: resData, encoding: .utf8) {
            return resStr
        }
        return "{}"
    }

    func executeAsyncInternal(json: String) async {
        guard let data = json.data(using: .utf8) else { return }
        
        if let params = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            await processCommand(params)
        } else if let actions = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            for params in actions {
                await processCommand(params)
            }
        }
        
        // Sincronización automática de estado
        let changes = self.flushStateChanges()
        if !changes.isEmpty {
            if let data = try? JSONSerialization.data(withJSONObject: changes),
               let jsonStr = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    Harbour.call("SW_UPDATE_HB", jsonStr)
                }
            }
        }
    }
    
    private func processCommand(_ params: [String: Any]) async {
        guard let cmd = (params["cmd"] as? String) ?? (params["func"] as? String) else { return }
        await self.execute(name: cmd, params: params)
    }
    
    // MARK: - State Tracking
    
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
    
    // MARK: - Event Queue Management
    
    public func enqueueEvent(id: String, type: String, data: [String: Any] = [:]) {
        queue.sync(flags: .barrier) {
            var event = data
            event["id"] = id
            event["event"] = type
            eventQueue.append(event)
        }
    }
    
    public func flushEvents() -> [[String: Any]] {
        var events: [[String: Any]] = []
        queue.sync(flags: .barrier) {
            events = eventQueue
            eventQueue = []
        }
        return events
    }
}
