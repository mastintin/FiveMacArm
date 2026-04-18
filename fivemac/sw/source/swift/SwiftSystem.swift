import Foundation
import AppKit
import UniformTypeIdentifiers

internal struct SystemCommands {
    static func register(in sd: SwDispatcher) {
        // Registro de los comandos en el despacho universal
        sd.register("alert")    { params in await SystemCommands.alert(params) }
        sd.register("msginfo")  { params in await SystemCommands.alert(params) }
        sd.register("msgstop")  { params in await SystemCommands.alert(params, style: .critical) }
        sd.register("msgalert") { params in await SystemCommands.alert(params, style: .warning) }
        sd.register("msgnoob")  { params in await SystemCommands.alert(params, style: .informational) }
        sd.register("msgget")   { params in await SystemCommands.msgGet(params) }
        sd.register("msggetmulti") { params in await SystemCommands.msgGetMulti(params) }
        sd.register("msglist")  { params in await SystemCommands.msgList(params) }
        sd.register("msgselect") { params in await SystemCommands.msgList(params) }
        sd.register("getfile")  { params in await SystemCommands.getFile(params) }
        sd.register("getdir")   { params in await SystemCommands.getFile(params, onlyDirs: true) }
        sd.register("savefile") { params in await SystemCommands.saveFile(params) }
        
        // --- NOTIFICACIONES Y ESTADOS ASÍNCRONOS ---
        sd.register("alertasync")  { params in await SystemCommands.alertAsync(params) }
        sd.register("statusshow")   { params in await SystemCommands.statusShow(params) }
        sd.register("statusclose")  { params in await SystemCommands.statusClose(params) }
        sd.register("doevents")     { _ in await SystemCommands.doEvents() }
        sd.register("timer")        { params in await SystemCommands.timer(params) }
    }

    // MARK: - Temporizador Asíncrono
    @MainActor static func timer(_ params: [String: Any]) async {
        let ms = (params["ms"] as? Double) ?? (params["p1"] as? Double) ?? 1000
        let tag = (params["tag"] as? String) ?? (params["p2"] as? String) ?? ""
        
        // Ejecución retardada sin bloquear el hilo principal
        DispatchQueue.main.asyncAfter(deadline: .now() + (ms / 1000.0)) {
            let cmd: [String: Any] = [
                "_COMMAND": [
                    "name": "SwTimerDone",
                    "p1": tag
                ]
            ]
            if let data = try? JSONSerialization.data(withJSONObject: cmd),
               let json = String(data: data, encoding: .utf8) {
                Harbour.call("SW_PIPELINE_SYNC", json)
            }
        }
    }

    // MARK: - Refresco de Eventos (Evita Pelota de Playa)
    @MainActor static func doEvents() async {
        let end = Date(timeIntervalSinceNow: 0.005)
        while let event = NSApp.nextEvent(matching: .any, until: end, inMode: .default, dequeue: true) {
            NSApp.sendEvent(event)
        }
    }

    // MARK: - Notificación Simple (Fire & Forget)
    @MainActor static func alertAsync(_ params: [String: Any]) async {
        let text    = (params["text"] as? String) ?? (params["p1"] as? String) ?? "Sin mensaje"
        let title   = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Aviso"
        let type    = (params["type"] as? Int) ?? (params["p3"] as? Int) ?? 1
        let seconds = (params["seconds"] as? Double) ?? (params["p4"] as? Double) ?? 5.0
        
        let randomId = "alert_\(UUID().uuidString.prefix(8))"
        SwNotificationCenter.shared.show(id: randomId, text: text, title: title, type: type, seconds: seconds)
    }

    // MARK: - Mensajes de Estado (Lifecycle Manual)
    @MainActor static func statusShow(_ params: [String: Any]) async {
        var id      = (params["id"] as? String) ?? (params["p1"] as? String) ?? ""
        let text    = (params["text"] as? String) ?? (params["p2"] as? String) ?? "Procesando..."
        let title   = (params["title"] as? String) ?? (params["p3"] as? String) ?? "Estado"
        let type    = (params["type"] as? Int) ?? (params["p4"] as? Int) ?? 1
        
        if id.isEmpty {
            id = "status_\(UUID().uuidString.prefix(8))"
        }
        
        SwNotificationCenter.shared.show(id: id, text: text, title: title, type: type, seconds: 0)
        
        // Devolvemos el ID a Harbour (importante para llamadas síncronas SDS)
        SwWorkflowContext.shared.set(id, for: "last_sync_result")
    }

    @MainActor static func statusClose(_ params: [String: Any]) async {
        let id = (params["id"] as? String) ?? (params["p1"] as? String) ?? ""
        if !id.isEmpty {
            SwNotificationCenter.shared.dismiss(id: id)
        }
        SwWorkflowContext.shared.set(true, for: "last_sync_result")
    }

    // MARK: - Diálogos de Archivos
    
    @MainActor static func saveFile(_ params: [String: Any]) async {
        let title    = (params["title"] as? String) ?? (params["p1"] as? String) ?? "Guardar como"
        let name     = (params["name"] as? String) ?? (params["p2"] as? String) ?? ""
        
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
        let title    = (params["title"] as? String) ?? (params["p1"] as? String) ?? "Seleccionar"
        let types    = (params["types"] as? String) ?? (params["p2"] as? String) ?? ""
        
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

    // MARK: - Alertas Estándar (Modales Clásicas)
    
    @MainActor static func alert(_ params: [String: Any], style: NSAlert.Style = .informational) async {
        let text     = (params["text"] as? String) ?? (params["p1"] as? String) ?? "Sin mensaje"
        let title    = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Atención"
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = style
        alert.addButton(withTitle: "OK")
        
        alert.runModal()
        
        SwWorkflowContext.shared.set(true, for: "last_sync_result")
    }

    // MARK: - Preguntas (Yes/No)
    @MainActor static func msgGet(_ params: [String: Any]) async {
        let text     = (params["text"] as? String) ?? (params["p1"] as? String) ?? "¿Desea continuar?"
        let title    = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Confirmación"
        let customButtons = params["buttons"] as? [String]
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = .informational
        
        if let buttons = customButtons {
            buttons.forEach { alert.addButton(withTitle: $0) }
        } else {
            alert.addButton(withTitle: "Yes")
            alert.addButton(withTitle: "No")
        }
        
        let modalResponse = alert.runModal()
        var response: Any = false 
        
        if let buttons = customButtons {
            let index = Int(modalResponse.rawValue) - 1000 
            if index >= 0 && index < buttons.count {
                let clickedTitle = buttons[index].lowercased()
                if clickedTitle == "yes" || clickedTitle == "si" || clickedTitle == "sí" {
                    response = true
                } else if clickedTitle == "no" {
                    response = false
                } else {
                    response = buttons[index]
                }
            }
        } else {
            response = modalResponse == .alertFirstButtonReturn
        }
        
        SwWorkflowContext.shared.set(response, for: "last_sync_result")
    }

    @MainActor static func msgList(_ params: [String: Any]) async {
        let items    = (params["items"] as? [String]) ?? (params["p1"] as? [String]) ?? []
        let title    = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Seleccionar"
        
        await withCheckedContinuation { continuation in
            SwSelectionManager.shared.show(title: title, items: items, isSync: true) { result in
                let nIdx = (result as? Int) ?? -1
                let finalResult: Any = (nIdx >= 0) ? (nIdx + 1) : 0
                SwWorkflowContext.shared.set(finalResult, for: "last_sync_result")
                continuation.resume()
            }
        }
    }

    @MainActor static func msgGetMulti(_ params: [String: Any]) async {
        let text     = (params["text"] as? String)  ?? (params["p1"] as? String) ?? ""
        let title    = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Instrucciones"
        
        await withCheckedContinuation { continuation in
            SwSelectionManager.shared.show(title: title, text: text, mode: .multiline, isSync: true) { result in
                let response = (result as? String) ?? ""
                SwWorkflowContext.shared.set(response, for: "last_sync_result")
                continuation.resume()
            }
        }
    }
}
