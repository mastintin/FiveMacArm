import Foundation
import AppKit
import UniformTypeIdentifiers

internal struct SystemCommands {
    static func register(in sd: SwDispatcher) {
        // Registro de los comandos en el despacho
        sd.register("alert")    { params in await SystemCommands.alert(params) }
        sd.register("msginfo")  { params in await SystemCommands.alert(params) }
        sd.register("msgstop")  { params in await SystemCommands.alert(params, style: .critical) }
        sd.register("msgalert") { params in await SystemCommands.alert(params, style: .warning) }
        sd.register("msgnoob")  { params in await SystemCommands.alert(params, style: .informational) }
        sd.register("msgget")   { params in await SystemCommands.msgGet(params) }
        sd.register("msgwait")  { params in await SystemCommands.msgWait(params) }
        sd.register("getfile")  { params in await SystemCommands.getFile(params) }
        sd.register("getdir")   { params in await SystemCommands.getFile(params, onlyDirs: true) }
        sd.register("savefile") { params in await SystemCommands.saveFile(params) }

        // Mapeo para Harbour
        SwCapabilities.shared.register(
            control: "system",
            commands: [
                "SWALERT":   "alert",
                "SWMSGINFO": "msginfo",
                "SWMSGSTOP": "msgstop",
                "SWMSGALERT":"msgalert",
                "SWMSGGET":  "msgget",
                "SWMSGWAIT": "msgwait",
                "SWGETFILE": "getfile",
                "SWGETDIR":  "getdir",
                "SWSAVEFILE":"savefile"
            ],
            fields: [:]
        )
    }

    // MARK: - Diálogos de Archivos
    
    @MainActor static func saveFile(_ params: [String: Any]) async {
        let title = (params["title"] as? String) ?? (params["p1"] as? String) ?? "Guardar como"
        let name  = (params["name"] as? String) ?? (params["p2"] as? String) ?? ""
        
        let panel = NSSavePanel()
        panel.title = title
        panel.nameFieldStringValue = name
        
        var result = ""
        if panel.runModal() == .OK {
            result = panel.url?.path ?? ""
        }
        
        SwWorkflowContext.shared.set(result, for: "last_sync_result")
    }

    @MainActor static func getFile(_ params: [String: Any], onlyDirs: Bool = false) async {
        let title  = (params["title"] as? String) ?? (params["p1"] as? String) ?? "Seleccionar"
        let types  = (params["types"] as? String) ?? (params["p2"] as? String) ?? ""
        
        let panel = NSOpenPanel()
        panel.title = title
        panel.canChooseFiles = !onlyDirs
        panel.canChooseDirectories = onlyDirs
        panel.allowsMultipleSelection = false
        
        if !types.isEmpty {
            panel.allowedContentTypes = types.components(separatedBy: ",").compactMap { UTType(filenameExtension: $0) }
        }
        
        var result = ""
        if panel.runModal() == .OK {
            result = panel.url?.path ?? ""
        }
        
        SwWorkflowContext.shared.set(result, for: "last_sync_result")
    }

    // MARK: - Alertas Estándar
    
    @MainActor static func alert(_ params: [String: Any], style: NSAlert.Style = .informational) async {
        let text  = (params["text"] as? String) ?? (params["p1"] as? String) ?? "Sin mensaje"
        let title = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Atención"
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = style
        alert.addButton(withTitle: "OK")
        
        // runModal bloquea el hilo principal pero permite que el despacho siga gestionando tareas
        alert.runModal()
    }

    // MARK: - Preguntas (Yes/No)
    
    @MainActor static func msgGet(_ params: [String: Any]) async {
        let text  = (params["text"] as? String) ?? (params["p1"] as? String) ?? "¿Desea continuar?"
        let title = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Confirmación"
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        
        let response = alert.runModal() == .alertFirstButtonReturn
        
        // Guardamos el resultado en el contexto para uso síncrono o asíncrono
        SwWorkflowContext.shared.set(response, for: "last_sync_result")
        SwWorkflowContext.shared.set(response, for: "msg_get_result")
    }

    // MARK: - Avisos Temporales (Futura expansión para HUDs)
    
    @MainActor static func msgWait(_ params: [String: Any]) async {
        // Por ahora lo resolvemos como un MsgInfo, pero la estructura está lista
        let text  = (params["text"] as? String) ?? (params["p1"] as? String) ?? "Espere por favor..."
        print("HUD: \(text)")
        // Aquí podríamos implementar un UNNotification o una vista flotante (Toast)
    }
}
