import Foundation
import AppKit

internal struct ViewsCommands {
    static func register(in sd: SwDispatcher) {
        sd.register("update") { params in return await ViewsCommands.update(params) }
        sd.register("apply")  { params in return await ViewsCommands.apply(params) }
        sd.register("create") { params in return await ViewsCommands.create(params) }
        sd.register("text")   { params in 
            var p = params
            p["property"] = "text"
            p["value"] = params["p2"] ?? params["value"]
            return await ViewsCommands.update(p) 
        }

        sd.register("getindex") { params in
            let listId = ((params["id"] as? String) ?? (params["p1"] as? String) ?? "").trimmingCharacters(in: .whitespaces)
            let rowId = ((params["rowid"] as? String) ?? (params["p2"] as? String) ?? "").lowercased().trimmingCharacters(in: .whitespaces)
            
            print("🏝️ [Swift-GetIndex] Buscando en lista: '\(listId)' la fila: '\(rowId)'")
            return await MainActor.run { () -> [String: Any]? in
                if let state = ViewRegistry.getState(for: listId) as? ListState {
                    let index = state.items.firstIndex(where: { $0.id.lowercased() == rowId }) ?? -1
                    print("🏝️ [Swift-GetIndex] Encontrado index: \(index) de un total de \(state.items.count) items")
                    return ["result": index]
                }
                print("🏝️ [Swift-GetIndex] NO se encontró ListState para ID: '\(listId)'")
                return ["result": -1]
            }
        }

        SwCapabilities.shared.register(
            control: "system",
            commands: [
                "SWUPDATE": "update",
                "SWCREATE": "create",
                "SWTEXT":   "text",
                "SWGETINDEX": "getindex"
            ],
            fields: [:]
        )
    }

    @MainActor static func apply(_ params: [String: Any]) async -> [String: Any]? {
        let id = (params["id"] as? String) ?? (params["p1"] as? String) ?? ""
        
        if let state = ViewRegistry.getState(for: id) as? SwApplyable {
            for (key, value) in params {
                // Evitamos procesar las claves de control
                if key != "id" && key != "cmd" && key != "p1" && key != "func" {
                    print("🏝️ [ViewsCommands] Apply key: \(key) = \(value)")
                    state.apply(property: key, value: value)
                    SwDispatcher.shared.recordChange(id: id, property: key, value: value)
                }
            }
            return ["status": "ok", "id": id]
        }
        
        return ["status": "error", "message": "ID \(id) not found for apply"]
    }

    @MainActor static func update(_ params: [String: Any]) async -> [String: Any]? {
        let id = (params["id"] as? String) ?? (params["p1"] as? String) ?? ""
        let property = (params["property"] as? String) ?? "text"
        let value = params["value"] ?? params["p2"]

        if let state = ViewRegistry.getState(for: id) as? SwApplyable {
            state.apply(property: property, value: value as Any)
            SwDispatcher.shared.recordChange(id: id, property: property, value: value as Any)
            return ["status": "ok", "id": id, "property": property]
        }
        
        return ["status": "error", "message": "ID not found"]
    }

    @MainActor static func create(_ params: [String: Any]) async -> [String: Any]? {
        let data = (params["p1"] as? [String: Any]) ?? params
        
        let id = (data["id"] as? String) ?? (params["id"] as? String) ?? ""
        let typeId = (data["type"] as? Int) ?? (params["type"] as? Int) ?? 0
        let parentid = (data["parentid"] as? String) ?? (params["parentid"] as? String) ?? ""
        
        print("SwFactory: Pre-create check - ID: \((data["id"] ?? params["id"]) ?? "N/A"), Type: \((data["type"] ?? params["type"]) ?? "N/A")")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            
            print("SwFactory: Petición de creación procesada para ID \(id) [Tipo \(typeId)]")
            sw_component_create_internal(id: id, typeId: typeId, jsonStr: jsonStr, parentid: parentid)
            return ["status": "ok", "id": id, "type": typeId]
        }
        return ["status": "error", "message": "Invalid JSON data"]
    }
}
