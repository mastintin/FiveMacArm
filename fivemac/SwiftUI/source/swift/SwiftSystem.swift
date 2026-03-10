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

    public static func getImageFile(title: String? = nil, prompt: String? = nil) -> String? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        
        if let title = title {
            panel.message = title
            panel.title = title
        }
        
        if let prompt = prompt {
            panel.prompt = prompt
        }

        panel.allowedContentTypes = [.image]

        return panel.runModal() == .OK ? panel.url?.path : nil
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

@HarbourBridge
public func swift_get_file(title: String?, types: String?, prompt: String?) -> String? {
    return SystemUtils.getFile(title: title, types: types, prompt: prompt)
}

@HarbourBridge
public func swift_get_dir(title: String?, prompt: String?) -> String? {
    return SystemUtils.getDir(title: title, prompt: prompt)
}

@HarbourBridge
public func swift_get_image(title: String?, prompt: String?) -> String? {
    return SystemUtils.getImageFile(title: title, prompt: prompt)
}

@HarbourBridge
public func swift_get_path() -> String {
    return SystemUtils.path
}

@HarbourBridge
public func swift_get_app_path() -> String {
    return SystemUtils.appPath
}

@HarbourBridge
public func swift_get_res_path() -> String {
    return SystemUtils.resPath
}

// MARK: - Capa de puente manual (Funciones con tipos Int, Bool, etc.)

@_cdecl("swift_alert")
public func swift_alert(msg: UnsafePointer<Int8>?, title: UnsafePointer<Int8>?, type: Int) {
    let m = msg != nil ? String(cString: msg!) : ""
    let t = title != nil ? String(cString: title!) : "Attention"
    SystemUtils.alert(msg: m, title: t, type: type)
}

@_cdecl("swift_msg_yes_no")
public func swift_msg_yes_no(msg: UnsafePointer<Int8>?, title: UnsafePointer<Int8>?) -> Bool {
    let m = msg != nil ? String(cString: msg!) : ""
    let t = title != nil ? String(cString: title!) : "Select"
    return SystemUtils.msgYesNo(msg: m, title: t)
}

@_cdecl("swift_get_color")
public func swift_get_color() -> Int {
    return SystemUtils.getColor()
}
