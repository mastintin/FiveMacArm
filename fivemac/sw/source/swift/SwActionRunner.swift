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

// ELIMINADAS FUNCIONES DUPLICADAS (Ahora en SwHarbourApi.swift para mayor estabilidad)

@_cdecl("HB_FUN_SW_PIPELINE_QUERY")
public func sw_pipeline_query_hb(_ p: UnsafeMutableRawPointer?) {
    let json = hb_parc(1).map { String(cString: $0) } ?? "{}"
    let result = SwDispatcher.shared.executeSync(json: json)
    Harbour.ret(result)
}

// MARK: - Motores de Ejecución del Tren (Batch Runners)

func executeWorkflowBatch(jsonData: Data) async {
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
