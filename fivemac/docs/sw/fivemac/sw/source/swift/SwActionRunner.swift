import Foundation
import SwiftUI
import AppKit

// MARK: - Bridge con Harbour (Entrada de C)

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
                    Harbour.call("SW_UPDATE_HB", jsonStr)
                }
            }
        }
        
        return lastResult
                
    } catch {
        print("ActionRunner Error crítico: \(error)")
        return nil
    }
}
