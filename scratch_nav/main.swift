import SwiftUI
import AppKit

struct PureNavApp: View {
    @State private var selection: String? = "dash"
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section("NATIVE SIDEBAR") {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                        .tag("dash")
                    Label("Reports", systemImage: "doc.fill")
                        .tag("rpt")
                    Label("Settings", systemImage: "gearshape.fill")
                        .tag("cfg")
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Menu")
        } detail: {
            ZStack {
                Color(NSColor.windowBackgroundColor)
                VStack(spacing: 20) {
                    if let selection = selection {
                        Image(systemName: selection == "dash" ? "chart.bar.fill" : (selection == "rpt" ? "doc.fill" : "gearshape.fill"))
                            .font(.system(size: 80))
                            .foregroundStyle(.blue.gradient)
                        Text("VISTA SELECCIONADA: \(selection.uppercased())")
                            .font(.title).bold()
                    } else {
                        Text("Seleccione una opción de la izquierda")
                            .font(.title).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Detail View")
        }
    }
}

// --- BOOTSTRAP PARA MAC SIN XCODE ---
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        window.center()
        window.title = "Swift Pure Navigation Test"
        
        let hostingView = NSHostingView(rootView: PureNavApp())
        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
