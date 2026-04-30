import Foundation
import AppKit

/// Delegado de la aplicación nativa macOS
class SwAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

private let appDelegate = SwAppDelegate()

/// Punto de entrada para arrancar el motor de UI de Swift desde Harbour
@_cdecl("hsw_swift_start")
public func hsw_swift_start() {
    let app = NSApplication.shared
    app.setActivationPolicy(.regular)
    app.delegate = appDelegate
    app.activate(ignoringOtherApps: true)
    app.run()
}
