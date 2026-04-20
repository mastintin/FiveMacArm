import Foundation

internal struct FilesCommands {
    static func register(in sd: SwDispatcher) {
        sd.register("filewrite") { params in return await FilesCommands.write(params) }
    }

    static func write(_ params: [String: Any]) async -> [String: Any]? {
        let path = (params["path"] as? String) ?? (params["p1"] as? String)
        guard let p = path else { return ["status": "error", "message": "Missing path"] }
        let fullPath = (p as NSString).expandingTildeInPath
        let key = (params["contextKey"] as? String) ?? (params["p2"] as? String) ?? "last_response"
        let content = (params["content"] as? String) ?? (params["p3"] as? String) ?? 
                      (SwWorkflowContext.shared.get(key) as? String) ?? ""
        do {
            try content.write(toFile: fullPath, atomically: true, encoding: .utf8)
            return ["status": "ok", "path": fullPath]
        } catch {
            return ["status": "error", "message": error.localizedDescription]
        }
    }
}
