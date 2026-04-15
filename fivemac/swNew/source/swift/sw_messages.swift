import SwiftUI
import AppKit
import HarbourMacro

// MARK: - Independent Native Messages for 'sw'
@HarbourDirect
public func sw_msginfo(msg: String, title: String) {
    let block = {
        let alert = NSAlert()
        alert.messageText = title.isEmpty ? "FiveMac SwiftUI Alert" : title
        alert.informativeText = msg
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
}

// Helper para depurar desde Swift directamente
public func sw_debug(_ msg: String) {
    print("[SW-DEBUG] \(msg)")
    // También podemos lanzar un log en la consola de macOS si fuera necesario
}
