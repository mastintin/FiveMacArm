import Foundation
import AppKit

internal struct ViewsCommands {
    static func register(in sd: SwDispatcher) {
        sd.register("update") { params in await ViewsCommands.update(params) }
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
}
