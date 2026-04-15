import Foundation

internal struct FilesCommands {
    static func register(in sd: SwDispatcher) {
        sd.register("filewrite") { params in await FilesCommands.write(params) }
    }

    static func write(_ params: [String: Any]) async {
        let path = (params["path"] as? String) ?? (params["p1"] as? String)
        guard let p = path else { return }
        let fullPath = (p as NSString).expandingTildeInPath
        let key = (params["contextKey"] as? String) ?? (params["p2"] as? String) ?? "last_response"
        let content = (params["content"] as? String) ?? (params["p2"] as? String) ?? 
                      (SwWorkflowContext.shared.get(key) as? String) ?? ""
        try? content.write(toFile: fullPath, atomically: true, encoding: .utf8)
    }
}
