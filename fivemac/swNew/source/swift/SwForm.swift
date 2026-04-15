import SwiftUI
import AppKit
import Observation
import HarbourMacro

// Memory storage to keep delegates alive
private var windowDelegates: [String: NSWindowDelegate] = [:]

@HarbourDirect
public func sw_form_create(title: String, width: Double, height: Double, id: String) -> Int64 {
    print("DEBUG: sw_form_create START - ID: \(id)")
    
    // Aseguramos que la App existe
    print("DEBUG: sw_form_create - Initing NSApplication")
    _ = NSApplication.shared
    
    print("DEBUG: sw_form_create - Creating SwFormState")
    let state = SwFormState()
    SwRegistry.register(state, for: id)

    class WindowDelegate: NSObject, NSWindowDelegate {
        func windowWillClose(_ notification: Notification) {
            print("DEBUG: WindowDelegate - windowWillClose")
            NSApp.terminate(nil)
        }
    }

    var windowPtr: Int64 = 0

    let block = {
        print("DEBUG: sw_form_create block START")
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        print("DEBUG: sw_form_create - Window created: \(window)")
        
        let delegate = WindowDelegate()
        windowDelegates[id] = delegate
        window.delegate = delegate
        
        print("DEBUG: sw_form_create - Creating hosting view")
        let root = SwFormView(state: state)
        let hosting = NSHostingView(rootView: root)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView = window.contentView!
        contentView.addSubview(hosting)
        
        NSLayoutConstraint.activate([
            hosting.topAnchor.constraint(equalTo: contentView.topAnchor),
            hosting.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hosting.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        window.center()
        
        let opaque = Unmanaged.passRetained(window).toOpaque()
        windowPtr = Int64(Int(bitPattern: opaque))
        
        SwFormRegistry.register(window, for: id)
        print("DEBUG: sw_form_create - Window registered in Registry")
    }
    
    print("DEBUG: sw_form_create - Dispatching to main thread")
    if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
    
    print("DEBUG: sw_form_create END - Ptr: \(windowPtr)")
    return windowPtr
}

@HarbourDirect
public func sw_form_show(id: String) {
    print("DEBUG: sw_form_show START - ID: \(id)")
    let block = {
        if let window = SwFormRegistry.get(id) as? NSWindow {
            print("DEBUG: sw_form_show - Making window Key and Order Front")
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            print("DEBUG: sw_form_show - Window should be visible now")
        } else {
            print("DEBUG: sw_form_show - ERROR: Window not found in Registry for ID: \(id)")
        }
    }
    if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
}

@HarbourDirect
public func sw_app_run() {
    print("DEBUG: sw_app_run START")
    let block = {
        if !NSApp.isRunning {
             print("DEBUG: sw_app_run - Executing NSApp.run()")
             NSApp.setActivationPolicy(.regular)
             NSApp.run()
             print("DEBUG: sw_app_run - NSApp.run() returned control!")
        } else {
             print("DEBUG: sw_app_run - NSApp is already running")
        }
    }
    if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
    print("DEBUG: sw_app_run END")
}

// MARK: - Root View for Forms
struct SwFormView: View {
    let state: SwFormState
    var body: some View {
        ZStack {
            Color.clear // Base para que el ZStack ocupe todo
            
            ForEach(0..<state.items.count, id: \.self) { index in
                SwRecursiveItemView(item: state.items[index], index: index)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
