import Foundation
import AppKit

internal struct ViewsCommands {
    static func register(in sd: SwDispatcher) {
        sd.register("update") { params in await ViewsCommands.update(params) }
        sd.register("create") { params in await ViewsCommands.create(params) }
        sd.register("text")   { params in 
            var p = params
            p["property"] = "text"
            p["value"] = params["p2"] ?? params["value"]
            await ViewsCommands.update(p) 
        }

        SwCapabilities.shared.register(
            control: "system",
            commands: [
                "SWUPDATE": "update",
                "SWCREATE": "create",
                "SWTEXT":   "text"
            ],
            fields: [:]
        )
    }

    @MainActor static func update(_ params: [String: Any]) async {
        let id = (params["id"] as? String) ?? (params["p1"] as? String) ?? ""
        let property = (params["property"] as? String) ?? "text"
        let value = params["value"] ?? params["p2"]

        // 1. Actualizar el Estado Lógico (ButtonState, etc.)
        if let state = ViewRegistry.getState(for: id) as? SwApplyable {
            state.apply(property: property, value: value as Any)
        }
        

        // 3. EL CHIVATAZO: Registramos el cambio para el Tren de Vuelta a Harbour
        SwDispatcher.shared.recordChange(id: id, property: property, value: value as Any)
    }

    @MainActor static func create(_ params: [String: Any]) async {
        // El Proxy de Harbour suele envolver el primer argumento en "p1"
        let data = (params["p1"] as? [String: Any]) ?? params
        
        let id = (data["id"] as? String) ?? (params["id"] as? String) ?? ""
        let typeId = (data["typeid"] as? Int) ?? (params["typeid"] as? Int) ?? 0
        let parentId = (data["parentid"] as? String) ?? (params["parentid"] as? String) ?? ""
        
        // Convertimos los datos finales a JSON para el Factory 
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
           let jsonStr = String(data: jsonData, encoding: .utf8) {
            
            print("SwFactory: Petición de creación procesada para ID \(id) [Tipo \(typeId)]")
            sw_component_create_internal(id: id, typeId: typeId, jsonStr: jsonStr, parentId: parentId)
        }
    }
}
