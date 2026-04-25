import Foundation
import AppKit

/// El motor de despacho central (El Cerebro) - Versión Unificada HSW
public class SwDispatcher {
    public static let shared = SwDispatcher()
    
    /// Diccionario de comandos ejecutables
    private var commands: [String: ([String: Any]) async -> [String: Any]?] = [:]
    
    /// Tacógrafo para registrar cambios de estado hacia Harbour
    private var stateChanges: [String: [String: Any]] = [:]
    
    /// Cola de eventos pendientes para que Harbour los recoja
    private var eventQueue: [[String: Any]] = []
    
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
            return await action(resolvedParams)
        } else {
            print("SwDispatcher: Error - Comando '\(name)' no registrado.")
            return nil
        }
    }

    // EJECUCIÓN SÍNCRONA INTERNA (Para ser llamada desde el puente C)
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
        
        if let resData = try? JSONSerialization.data(withJSONObject: finalResult),
           let resStr = String(data: resData, encoding: .utf8) {
            return resStr
        }
        return "{}"
    }

    // EJECUCIÓN ASÍNCRONA INTERNA
    func executeAsyncInternal(json: String) async {
        guard let data = json.data(using: .utf8) else { return }
        
        if let params = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            await processCommand(params)
        } else if let actions = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            for params in actions {
                await processCommand(params)
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
    
    // MARK: - Piping Logic
    
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

    private func registerBaseCommands() {
        NetworkCommands.register(in: self)
        FilesCommands.register(in: self)
        ViewsCommands.register(in: self)
        SystemCommands.register(in: self)
    }

    // DISPATCHER UNIVERSAL
    public static func registerUniversal() {
        self.shared.register("apply") { params in
            let id = ((params["id"] as? String) ?? (params["p1"] as? String) ?? "").lowercased()
            
            return await MainActor.run { () -> [String: Any]? in
                if let state = ViewRegistry.getState(for: id) as? SwApplyable {
                    for (key, value) in params {
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
                                    case "top": if let n = (value as? NSNumber)?.doubleValue { item.y = n }
                                    case "left": if let n = (value as? NSNumber)?.doubleValue { item.x = n }
                                    case "width": if let n = (value as? NSNumber)?.doubleValue { item.itemWidth = n }
                                    case "height": if let n = (value as? NSNumber)?.doubleValue { item.itemHeight = n }
                                    case "resizemask": if let n = (value as? NSNumber)?.intValue { item.resizemask = n }
                                    case "interactive": if let b = value as? Bool { item.isInteractive = b }
                                    default: break
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

// MARK: - HSW Hybrid Bridge (Top Level @_cdecl)

class SwAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

private let appDelegate = SwAppDelegate()

@_cdecl("hsw_swift_start")
public func hsw_swift_start() {
    let app = NSApplication.shared
    app.setActivationPolicy(.regular)
    app.delegate = appDelegate
    app.activate(ignoringOtherApps: true)
    app.run()
}

@_cdecl("HSW_SEND_COMMAND")
public func hsw_send_command_hb(_ p: UnsafePointer<Int8>?) {
    guard let p = p else { return }
    let jsonStr = String(cString: p)
    Task {
        await SwDispatcher.shared.executeAsyncInternal(json: jsonStr)
    }
}

@_cdecl("SW_PIPELINE_EXEC")
public func sw_pipeline_exec_hb(_ p: UnsafePointer<Int8>?) {
    hsw_send_command_hb(p)
}

@_cdecl("SW_PIPELINE_EXEC_SYNC")
public func sw_pipeline_exec_sync_hb(_ p: UnsafePointer<Int8>?) -> UnsafePointer<Int8>? {
    guard let p = p else { return nil }
    let json = String(cString: p)
    var resultJson: String = "{}"
    let semaphore = DispatchSemaphore(value: 0)
    
    Task {
        resultJson = await SwDispatcher.shared.executeSyncInternal(json: json)
        semaphore.signal()
    }
    _ = semaphore.wait(timeout: .distantFuture)
    return (resultJson as NSString).utf8String
}

@_cdecl("SW_PIPELINE_QUERY")
public func sw_pipeline_query_hb(_ p: UnsafePointer<Int8>?) -> UnsafePointer<Int8>? {
    return sw_pipeline_exec_sync_hb(p)
}
