import Foundation

/// Motor de Timers Unificado para HSW
/// Gestiona tareas temporizadas en el Hilo de Background sin bloquear Harbour ni la UI.
internal struct TimerCommands {
    
    /// Almacén de timers activos (ID -> Task)
    private static var activeTimers: [String: Task<Void, Never>] = [:]
    
    static func register(in sd: SwDispatcher) {
        sd.register("timer") { params in
            await TimerCommands.start(params)
            return nil
        }
        
        sd.register("timercancel") { params in
            TimerCommands.stop(params)
            return nil
        }
    }
    
    static func start(_ params: [String: Any]) async {
        let id = (params["id"] as? String) ?? (params["p2"] as? String) ?? UUID().uuidString
        let ms = (params["ms"] as? Int) ?? (params["p1"] as? Int) ?? 1000
        let repeats = (params["repeats"] as? Bool) ?? (params["p3"] as? Bool) ?? true
        let pipelineData = params["pipeline"]
        
        // Cancelar si ya existía uno con el mismo ID
        activeTimers[id]?.cancel()
        
        let task = Task {
            repeat {
                // Espera el intervalo
                try? await Task.sleep(nanoseconds: UInt64(ms) * 1_000_000)
                
                if Task.isCancelled { break }
                
                // 1. Notificar a Harbour (Evento)
                SwDispatcher.shared.enqueueEvent(id: id, type: "timer")
                
                // 2. Ejecutar Pipeline si existe (Autopilot)
                if let pipeline = pipelineData {
                    print("🕒 [Timer] Ejecutando Pipeline Interno: \(pipeline)")
                    if let actions = pipeline as? [[String: Any]] {
                        for p in actions {
                            let cmd = (p["cmd"] as? String) ?? (p["func"] as? String) ?? ""
                            _ = await SwDispatcher.shared.execute(name: cmd, params: p)
                        }
                    } else if let p = pipeline as? [String: Any] {
                        let cmd = (p["cmd"] as? String) ?? (p["func"] as? String) ?? ""
                        _ = await SwDispatcher.shared.execute(name: cmd, params: p)
                    }
                }
                
            } while repeats && !Task.isCancelled
            
            // Limpieza al terminar
            if !Task.isCancelled {
                activeTimers.removeValue(forKey: id)
            }
        }
        
        activeTimers[id] = task
    }
    
    private static func stop(_ params: [String: Any]) {
        let id = (params["id"] as? String) ?? (params["p1"] as? String) ?? ""
        if let task = activeTimers.removeValue(forKey: id) {
            task.cancel()
        }
    }
}
