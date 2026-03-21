import AppKit
import Foundation
import UniformTypeIdentifiers
import HarbourMacro

// MARK: - Swift Native API (Usable internamente en FiveMac)

public struct SystemUtils {
    
    public static func getFile(title: String? = nil, types: String? = nil, prompt: String? = nil) -> String? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false

        if let title = title {
            panel.message = title
            panel.title = title
        }
        
        if let prompt = prompt {
            panel.prompt = prompt
        }

        if let types = types {
            let extensions = types.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }

            if !extensions.isEmpty {
                let utTypes = extensions.compactMap { UTType(filenameExtension: $0) }
                panel.allowedContentTypes = utTypes
            }
        }

        return panel.runModal() == .OK ? panel.url?.path : nil
    }

    public static func getDir(title: String? = nil, prompt: String? = nil) -> String? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        if let title = title {
            panel.message = title
            panel.title = title
        }
        
        if let prompt = prompt {
            panel.prompt = prompt
        }

        return panel.runModal() == .OK ? panel.url?.path : nil
    }

    public static func alert(msg: String, title: String = "Attention", type: Int = 0) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = msg
        
        switch type {
        case 1: alert.alertStyle = .warning
        case 2: alert.alertStyle = .critical
        default: alert.alertStyle = .informational
        }
        
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    public static func msgYesNo(msg: String, title: String = "Select") -> Bool {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = msg
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        return alert.runModal() == .alertFirstButtonReturn
    }

    public static func getColor() -> Int {
        let panel = NSColorPanel.shared
        panel.makeKeyAndOrderFront(nil)
        
        let session = NSApplication.shared.beginModalSession(for: panel)
        while NSApplication.shared.runModalSession(session) == .continue {
            if !panel.isVisible { break }
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1))
        }
        NSApplication.shared.endModalSession(session)
        
        let color = panel.color.usingColorSpace(.deviceRGB) ?? .black
        let r = Int(color.redComponent * 255)
        let g = Int(color.greenComponent * 255)
        let b = Int(color.blueComponent * 255)
        
        return (b << 16) | (g << 8) | r
    }


   
    public static func getImageFile(
        title: String? = nil, 
        prompt: String? = nil, 
        allowMultiple: Bool = false
    ) -> String? {
        let panel = NSOpenPanel()
        
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = allowMultiple
        panel.allowedContentTypes = [.image]
        
        if let title = title {
            panel.title = title
            panel.message = title
        }
        if let prompt = prompt {
            panel.prompt = prompt
        }
        
        NSApp.activate(ignoringOtherApps: true)
        
        if panel.runModal() == .OK {
            // Obtenemos las rutas limpias de macOS 15
            let paths = panel.urls.map { $0.path(percentEncoded: false) }
            
            // Si hay 1, devuelve el String directo. Si hay más, los une con |.
            return paths.isEmpty ? nil : paths.joined(separator: "|")
        }
        
        return nil
    }

    public static var appPath: String {
        return Bundle.main.bundlePath
    }

    public static var path: String {
        return (Bundle.main.bundlePath as NSString).deletingLastPathComponent
    }

    public static var resPath: String {
        return Bundle.main.resourcePath ?? Bundle.main.bundlePath
    }
}

// MARK: - Capa de Automatización con Macros (Solo funciones de String)

@HarbourDirect
public func sw_get_file(title: String?, types: String?, prompt: String?) -> String? {
    return SystemUtils.getFile(title: title, types: types, prompt: prompt)
}

@HarbourDirect
public func sw_get_dir(title: String?, prompt: String?) -> String? {
    return SystemUtils.getDir(title: title, prompt: prompt)
}

@HarbourDirect
public func sw_get_image(title: String?, prompt: String?) -> String? {
    return SystemUtils.getImageFile(title: title, prompt: prompt)
}

@HarbourDirect
public func sw_get_path() -> String {
    return SystemUtils.path
}

@HarbourDirect
public func sw_get_app_path() -> String {
    return SystemUtils.appPath
}

@HarbourDirect
public func sw_get_res_path() -> String {
    return SystemUtils.resPath
}

// MARK: - Capa de puente manual (Funciones con tipos Int, Bool, etc.)

@HarbourDirect
public func sw_alert(msg: String?, title: String?, type: Int) {
    let m = msg ?? ""
    let t = title ?? "Attention"
    SystemUtils.alert(msg: m, title: t, type: type)
}

@HarbourDirect
public func sw_msg_yes_no(msg: String?, title: String?) -> Bool {
    let m = msg ?? ""
    let t = title ?? "Select"
    return SystemUtils.msgYesNo(msg: m, title: t)
}

@HarbourDirect
public func sw_get_color() -> Int {
    return SystemUtils.getColor()
}
