import UniformTypeIdentifiers
import AppKit

internal struct FilesCommands {
    static func register(in sd: SwDispatcher) {
        sd.register("filewrite") { params in return await FilesCommands.write(params) }
        sd.register("getfile")   { params in return await FilesCommands.getFile(params) }
        sd.register("getdir")    { params in return await FilesCommands.getDir(params) }
        sd.register("savefile")  { params in return await FilesCommands.saveFile(params) }
    }

    @MainActor static func getFile(_ params: [String: Any]) async -> [String: Any]? {
        let title  = (params["title"] as? String) ?? (params["p1"] as? String) ?? "Seleccione un archivo"
        let types  = (params["types"] as? String) ?? (params["p2"] as? String) ?? ""
        let prompt = (params["prompt"] as? String) ?? (params["p3"] as? String) ?? "Aceptar"
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.title = title
        panel.message = title
        panel.prompt = prompt

        if !types.isEmpty {
            let extensions = types.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }

            if !extensions.isEmpty {
                let utTypes = extensions.compactMap { UTType(filenameExtension: $0) }
                panel.allowedContentTypes = utTypes
            }
        }

        if panel.runModal() == .OK {
            return ["result": panel.url?.path ?? ""]
        }
        return ["result": ""]
    }

    @MainActor static func getDir(_ params: [String: Any]) async -> [String: Any]? {
        let title  = (params["title"] as? String) ?? (params["p1"] as? String) ?? "Seleccione una carpeta"
        let prompt = (params["prompt"] as? String) ?? (params["p2"] as? String) ?? "Aceptar"

        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.title = title
        panel.message = title
        panel.prompt = prompt

        if panel.runModal() == .OK {
            return ["result": panel.url?.path ?? ""]
        }
        return ["result": ""]
    }

    @MainActor static func saveFile(_ params: [String: Any]) async -> [String: Any]? {
        let title       = (params["title"] as? String) ?? (params["p1"] as? String) ?? "Guardar como"
        let defaultName = (params["name"] as? String) ?? (params["p2"] as? String) ?? ""
        let prompt      = (params["prompt"] as? String) ?? (params["p3"] as? String) ?? "Guardar"

        let panel = NSSavePanel()
        panel.title = title
        panel.message = title
        panel.prompt = prompt
        panel.nameFieldStringValue = defaultName

        if panel.runModal() == .OK {
            return ["result": panel.url?.path ?? ""]
        }
        return ["result": ""]
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
