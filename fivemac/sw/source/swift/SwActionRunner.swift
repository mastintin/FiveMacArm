import Foundation
import SwiftUI
import AppKit

// MARK: - Bridge con Harbour (Entrada de C)

@_cdecl("HB_FUN_SW_GET_PROXY_MAP")
public func sw_get_proxy_map_hb(_ p: UnsafeMutableRawPointer?) {
    _ = SwDispatcher.shared
    SwDispatcher.registerUniversal()
    
    // 2. Obtenemos el mapa de capacidades registradas
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
    guard let data = jsonStr.data(using: .utf8) else { return }
    
    Task(priority: .userInitiated) {
        await executeWorkflowBatch(jsonData: data)
    }
}

@_cdecl("HB_FUN_SW_PIPELINE_EXEC_SYNC")
public func sw_pipeline_exec_sync_hb(_ p: UnsafeMutableRawPointer?) {
    guard let jsonStr = hb_parc(1).map({ String(cString: $0) }) else { return }
    guard let data = jsonStr.data(using: .utf8) else { return }
    
    // Contenedor seguro para la bandera de finalización
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
    
    // Devolvemos el resultado (Convención Universal: last_sync_result)
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

// MARK: - Motor de Ejecución del Tren (Batch Runner)

private func executeWorkflowBatch(jsonData: Data) async {
    do {
        guard let actions = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            print("ActionRunner: JSON de lote inválido.")
            return
        }
        
        // El tren procesa las acciones secuencialmente
        for params in actions {
            guard let cmd = (params["cmd"] as? String) ?? (params["func"] as? String) else { continue }
            
            // Delegamos la ejecución en el Cerebro (Dispatcher)
            await SwDispatcher.shared.execute(name: cmd, params: params)
        }
        
        // --- SINCRONIZACIÓN DE ESTADO (Reporte de vuelta a Harbour) ---
        let changes = SwDispatcher.shared.flushStateChanges()
        
        if !changes.isEmpty {
            if let data = try? JSONSerialization.data(withJSONObject: changes),
               let jsonStr = String(data: data, encoding: .utf8) {
                
                DispatchQueue.main.async {
                    // Llamamos a Harbour para sincronizar los hState
                    Harbour.call("SW_PIPELINE_SYNC", jsonStr)
                }
            }
        }
                
    } catch {
        print("ActionRunner Error crítico: \(error)")
    }
}

// Fin del Bridge
