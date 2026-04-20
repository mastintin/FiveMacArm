import Foundation
import AppKit
import UniformTypeIdentifiers

internal struct SystemCommands {
    static func register(in sd: SwDispatcher) {
        // Registro de los comandos en el despacho universal (Ahora con retorno)
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
        sd.register("beep")     { _ in NSSound.beep(); return nil }
        
        // --- NOTIFICACIONES Y ESTADOS ASÍNCRONOS ---
        sd.register("alertasync")  { params in await SystemCommands.alertAsync(params) ; return nil }
        sd.register("statusshow")   { params in return await SystemCommands.statusShow(params) }
        sd.register("statusclose")  { params in await SystemCommands.statusClose(params) ; return nil }
        sd.register("doevents")     { _ in await SystemCommands.doEvents() ; return nil }
        sd.register("timer")        { params in await SystemCommands.timer(params) ; return nil }
        
        // --- NUEVOS COMANDOS DE CONSULTA (QUERY) ---
        sd.register("isrunning")    { _ in return ["result": await NSApp.isRunning] }
    }

    // MARK: - Temporizador Asíncrono
    @MainActor static func timer(_ params: [String: Any]) async {
        let ms = (params["ms"] as? Double) ?? (params["p1"] as? Double) ?? 1000
        let tag = (params["tag"] as? String) ?? (params["p2"] as? String) ?? ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (ms / 1000.0)) {
            let cmd: [String: Any] = ["_COMMAND": ["name": "SwTimerDone", "p1": tag]]
            if let data = try? JSONSerialization.data(withJSONObject: cmd),
               let json = String(data: data, encoding: .utf8) {
                Harbour.call("SW_PIPELINE_SYNC", json)
            }
        }
    }

    @MainActor static func doEvents() async {
        let end = Date(timeIntervalSinceNow: 0.005)
        while let event = NSApp.nextEvent(matching: .any, until: end, inMode: .default, dequeue: true) {
            NSApp.sendEvent(event)
        }
    }

    @MainActor static func alertAsync(_ params: [String: Any]) async {
        let text    = (params["text"] as? String) ?? (params["p1"] as? String) ?? "Sin mensaje"
        let title   = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Aviso"
        let type    = (params["type"] as? Int) ?? (params["p3"] as? Int) ?? 1
        let seconds = (params["seconds"] as? Double) ?? (params["p4"] as? Double) ?? 5.0
        
        let randomId = "alert_\(UUID().uuidString.prefix(8))"
        SwNotificationCenter.shared.show(id: randomId, text: text, title: title, type: type, seconds: seconds)
    }

    @MainActor static func statusShow(_ params: [String: Any]) async -> [String: Any]? {
        var id      = (params["id"] as? String) ?? (params["p1"] as? String) ?? ""
        let text    = (params["text"] as? String) ?? (params["p2"] as? String) ?? "Procesando..."
        let title   = (params["title"] as? String) ?? (params["p3"] as? String) ?? "Estado"
        let type    = (params["type"] as? Int) ?? (params["p4"] as? Int) ?? 1
        
        if id.isEmpty { id = "status_\(UUID().uuidString.prefix(8))" }
        SwNotificationCenter.shared.show(id: id, text: text, title: title, type: type, seconds: 0)
        
        return ["result": id]
    }

    @MainActor static func statusClose(_ params: [String: Any]) async {
        let id = (params["id"] as? String) ?? (params["p1"] as? String) ?? ""
        if !id.isEmpty {
            SwNotificationCenter.shared.dismiss(id: id)
        }
    }

    @MainActor static func saveFile(_ params: [String: Any]) async -> [String: Any]? {
        let title    = (params["title"] as? String) ?? (params["p1"] as? String) ?? "Guardar como"
        let name     = (params["name"] as? String) ?? (params["p2"] as? String) ?? ""
        
        let panel = NSSavePanel()
        panel.title = title
        panel.nameFieldStringValue = name
        
        if panel.runModal() == .OK {
            return ["result": panel.url?.path ?? ""]
        }
        return ["result": ""]
    }

    @MainActor static func getFile(_ params: [String: Any], onlyDirs: Bool = false) async -> [String: Any]? {
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
        
        if panel.runModal() == .OK {
            return ["result": panel.url?.path ?? ""]
        }
        return ["result": ""]
    }

    @MainActor static func alert(_ params: [String: Any], style: NSAlert.Style = .informational) async -> [String: Any]? {
        let text     = (params["text"] as? String) ?? (params["p1"] as? String) ?? "Sin mensaje"
        let title    = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Atención"
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = style
        alert.addButton(withTitle: "OK")
        
        alert.runModal()
        return ["result": true]
    }

    @MainActor static func msgGet(_ params: [String: Any]) async -> [String: Any]? {
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
                if clickedTitle == "yes" || clickedTitle == "si" || clickedTitle == "sí" { response = true }
                else if clickedTitle == "no" { response = false }
                else { response = buttons[index] }
            }
        } else {
            response = modalResponse == .alertFirstButtonReturn
        }
        
        return ["result": response]
    }

    @MainActor static func msgList(_ params: [String: Any]) async -> [String: Any]? {
        let items    = (params["items"] as? [String]) ?? (params["p1"] as? [String]) ?? []
        let title    = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Seleccionar"
        
        let response = await withCheckedContinuation { continuation in
            SwSelectionManager.shared.show(title: title, items: items, isSync: true) { result in
                let nIdx = (result as? Int) ?? -1
                let finalResult = (nIdx >= 0) ? (nIdx + 1) : 0
                continuation.resume(returning: finalResult)
            }
        }
        return ["result": response]
    }

    @MainActor static func msgGetMulti(_ params: [String: Any]) async -> [String: Any]? {
        let text     = (params["text"] as? String)  ?? (params["p1"] as? String) ?? ""
        let title    = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Instrucciones"
        
        let response = await withCheckedContinuation { continuation in
            SwSelectionManager.shared.show(title: title, text: text, mode: .multiline, isSync: true) { result in
                let response = (result as? String) ?? ""
                continuation.resume(returning: response)
            }
        }
        return ["result": response]
    }
}
