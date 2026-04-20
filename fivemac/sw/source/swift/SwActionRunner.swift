import Foundation
import SwiftUI
import AppKit

// MARK: - Bridge con Harbour (Entrada de C)

@_cdecl("HB_FUN_SW_GET_PROXY_MAP")
public func sw_get_proxy_map_hb(_ p: UnsafeMutableRawPointer?) {
    _ = SwDispatcher.shared
    SwDispatcher.registerUniversal()
    
    let map = SwCapabilities.shared.getProxyMap()
    if let data = try? JSONSerialization.data(withJSONObject: map),
       let jsonStr = String(data: data, encoding: .utf8) {
        Harbour.ret(jsonStr)
    } else {
        Harbour.ret("{}")
    }
}

@_cdecl("HB_FUN_SW_PIPELINE_EXEC")
public func sw_pipeline_exec_hb(_ p: UnsafeMutableRawPointer?) {
    guard let jsonStr = hb_parc(1).map({ String(cString: $0) }) else { return }
    print("ActionRunner: Recibido Pipeline -> \(jsonStr)")
    guard let data = jsonStr.data(using: .utf8) else { return }
    
    Task(priority: .userInitiated) {
        await executeWorkflowBatch(jsonData: data)
    }
}

@_cdecl("HB_FUN_SW_PIPELINE_EXEC_SYNC")
public func sw_pipeline_exec_sync_hb(_ p: UnsafeMutableRawPointer?) {
    guard let jsonStr = hb_parc(1).map({ String(cString: $0) }) else { return }
    guard let data = jsonStr.data(using: .utf8) else { return }
    
    class SafeFlag { 
        var value = false 
        private let lock = NSLock()
        func set(_ v: Bool) { lock.lock(); value = v; lock.unlock() }
        func get() -> Bool { lock.lock(); defer { lock.unlock() }; return value }
    }
    let finished = SafeFlag()
    
    Task(priority: .userInitiated) {
        await executeWorkflowBatch(jsonData: data)
        finished.set(true)
    }
    
    let limitDate = Date(timeIntervalSinceNow: 30.0)
    while !finished.get() && Date() < limitDate {
        RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
    }
    
    let lastResult = SwWorkflowContext.shared.get("last_sync_result") ?? ""
    SwWorkflowContext.shared.set("" as Any, for: "last_sync_result")
                     
    if let str = lastResult as? String {
        Harbour.ret(str)
    } else if let b = lastResult as? Bool {
        Harbour.ret(b)
    } else if let i = lastResult as? Int {
        Harbour.ret(i)
    } else {
        Harbour.ret()
    }
}

// NUEVO: Super Puente de Consulta Bidireccional (Ida y Vuelta JSON)
@_cdecl("HB_FUN_SW_PIPELINE_QUERY")
public func sw_pipeline_query_hb(_ p: UnsafeMutableRawPointer?) {
    guard let jsonStr = hb_parc(1).map({ String(cString: $0) }) else { 
        Harbour.ret("{}")
        return 
    }
    print("ActionRunner: Recibida Consulta -> \(jsonStr)")
    guard let data = jsonStr.data(using: .utf8) else { 
        Harbour.ret("{}")
        return 
    }
    
    class SafeResponse { 
        var value: [String: Any]? = nil 
        var finished = false
        private let lock = NSLock()
        func set(_ v: [String: Any]?) { lock.lock(); value = v; finished = true; lock.unlock() }
        func isFinished() -> Bool { lock.lock(); defer { lock.unlock() }; return finished }
    }
    let response = SafeResponse()
    
    Task(priority: .userInitiated) {
        let result = await executeWorkflowQuery(jsonData: data)
        response.set(result)
    }
    
    let limitDate = Date(timeIntervalSinceNow: 15.0) // Timeout más corto para consultas
    while !response.isFinished() && Date() < limitDate {
        RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.005))
    }
    
    if let res = response.value,
       let resData = try? JSONSerialization.data(withJSONObject: res),
       let resStr = String(data: resData, encoding: .utf8) {
        Harbour.ret(resStr)
    } else {
        Harbour.ret("{}")
    }
}

// MARK: - Motores de Ejecución del Tren (Batch Runners)

private func executeWorkflowBatch(jsonData: Data) async {
    _ = await executeWorkflowQuery(jsonData: jsonData)
}

private func executeWorkflowQuery(jsonData: Data) async -> [String: Any]? {
    do {
        guard let actions = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            return nil
        }
        
        var lastResult: [String: Any]? = nil
        
        for params in actions {
            guard let cmd = (params["cmd"] as? String) ?? (params["func"] as? String) else { continue }
            lastResult = await SwDispatcher.shared.execute(name: cmd, params: params)
        }
        
        let changes = SwDispatcher.shared.flushStateChanges()
        if !changes.isEmpty {
            if let data = try? JSONSerialization.data(withJSONObject: changes),
               let jsonStr = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    Harbour.call("SW_PIPELINE_SYNC", jsonStr)
                }
            }
        }
        
        return lastResult
                
    } catch {
        print("ActionRunner Error crítico: \(error)")
        return nil
    }
}
