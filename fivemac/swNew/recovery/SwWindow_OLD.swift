import SwiftUI
import AppKit
import Observation
import HarbourMacro

// MARK: - Native Window Bridge for SwiftUI

@HarbourDirect
public func swift_button_create_state(id: String, caption: String) {
    let finalId = id.isEmpty ? UUID().uuidString : id
    let state = ButtonState(caption: caption)
    ViewRegistry.register(state, for: finalId)
}

// Storage to keep delegates alive
private var windowDelegates: [String: NSWindowDelegate] = [:]

@_cdecl("HB_FUN_SW_CREATEWINDOW")
public func sw_create_window_hb(_ p: UnsafeMutableRawPointer?) {
    let title = hb_parc(1).map { String(cString: $0) } ?? "Swift Window"
    let w = hb_parnd(2)
    let h = hb_parnd(3)
    let id = hb_parc(4).map { String(cString: $0) } ?? UUID().uuidString
    
    // Create a special state for this window
    // Use SwiftVStackState as generic container for items
    let state = SwiftVStackState()
    state.scrollable = false
    
    // Root base is a ZStack for absolute positioning
    state.items = [StackItem(type: .zstack, content: "root", id: "root_" + id)]
    
    ViewRegistry.register(state, for: id)

    var windowPtr: UnsafeMutableRawPointer? = nil

    class WindowDelegate: NSObject, NSWindowDelegate {
        func windowWillClose(_ notification: Notification) {
            NSApp.terminate(nil)
        }
    }

    let block = {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: w, height: h),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.identifier = NSUserInterfaceItemIdentifier(id)
        
        let delegate = WindowDelegate()
        windowDelegates[id] = delegate
        window.delegate = delegate
        
        // Use our NEW isolated SwWindowView engine
        let root = SwWindowView(state: state, id: id)
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
        window.makeKeyAndOrderFront(nil)
        
        windowPtr = Unmanaged.passRetained(window).toOpaque()
    }
    
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.sync { block() }
    }
    
    if let ptr = windowPtr {
        hb_retnll(Int64(Int(bitPattern: ptr)))
    } else {
        hb_retnll(0)
    }
}

@_cdecl("HB_FUN_SW_APPRUN")
public func sw_app_run_hb(_ p: UnsafeMutableRawPointer?) {
    let block = {
        NSApp.run()
    }
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.sync { block() }
    }
}

@_cdecl("HB_FUN_SW_ADD_WINDOW_ITEM")
public func sw_add_window_item(_ p: UnsafeMutableRawPointer?) {
    guard let windowId = hb_parc(1).map({ String(cString: $0) }),
          let state = ViewRegistry.get(windowId) as? SwiftVStackState else {
        print("SW_ADD_WINDOW_ITEM: Window ID '\(hb_parc(1).map({ String(cString: $0) }) ?? "nil")' not found in Registry")
        return 
    }
    
    guard let content = hb_parc(3).map({ String(cString: $0) }) else { return }
    let typeInt = Int(hb_parni(2))
    guard let type = StackItem.ItemType(rawValue: typeInt) else { 
        print("SW_ADD_WINDOW_ITEM: Invalid type \(typeInt)")
        return 
    }
    
    let x = hb_parnd(4)
    let y = hb_parnd(5)
    let w = hb_parnd(6)
    let h = hb_parnd(7)
    let itemId = hb_parc(8).map({ String(cString: $0) }) ?? UUID().uuidString

    let item = StackItem(type: type, content: content, id: itemId)
    item.x = x
    item.y = y
    item.itemWidth = w
    item.itemHeight = h
    
    let block = {
        // Add DIRECTLY to the state's main items array
        state.items.append(item)
        state.lastItem = item
        
        // This re-assignment is what triggers the @Observable refresh
        let copy = state.items
        state.items = copy
    }
    
    if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
}
