import SwiftUI
import AppKit
import Observation
import HarbourMacro

// MARK: - State Management

@Observable
public class SwiftTabViewState {
    public struct TabItem: Identifiable {
        public let id: String
        public let title: String
        public let icon: String
    }
    
    public var tabs: [TabItem] = []
    public var selectedTabId: String = ""
    
    public init() {}
}

// MARK: - Views

struct GenericNSViewWrapper: NSViewRepresentable {
    let view: NSView
    
    func makeNSView(context: Context) -> NSView {
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // No update needed as the view is managed by Harbour
    }
}

struct SwiftTabView: View {
    var state: SwiftTabViewState
    
    var body: some View {
        VStack(spacing: 0) {
            if !state.tabs.isEmpty {
                Picker("", selection: Bindable(state).selectedTabId) {
                    ForEach(state.tabs) { item in
                        HStack {
                            if !item.icon.isEmpty {
                                Image(systemName: item.icon)
                            }
                            Text(item.title)
                        }
                        .tag(item.id)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            
            ZStack {
                ForEach(state.tabs) { item in
                    if state.selectedTabId == item.id {
                        if let nsView = ViewRegistry.get(item.id) as? NSView {
                            GenericNSViewWrapper(view: nsView)
                        } else {
                            VStack {
                                Spacer()
                                Text("Content for '\(item.title)' (\(item.id)) not found")
                                    .foregroundColor(.secondary)
                                    .italic()
                                Spacer()
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Loader & Bridge

@objc(SwiftTabViewLoader)
public class SwiftTabViewLoader: NSObject {
    
    @objc(createState:)
    public static func createState(id: String) -> Any {
        let state = SwiftTabViewState()
        ViewRegistry.register(state, for: id)
        return state
    }

    @objc(addTab:id:title:icon:)
    public static func addTab(rootId: String, id: String, title: String, icon: String) {
        let block = {
            if let state = ViewRegistry.get(rootId) as? SwiftTabViewState {
                state.tabs.append(SwiftTabViewState.TabItem(id: id, title: title, icon: icon))
                if state.selectedTabId.isEmpty {
                    state.selectedTabId = id
                }
            }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    @objc(makeTabView:)
    public static func makeTabView(id: String) -> NSView {
        guard let state = ViewRegistry.get(id) as? SwiftTabViewState else {
            return NSView()
        }
        let view = SwiftTabView(state: state)
        let hosting = NSHostingView(rootView: view)
        ViewRegistry.register(hosting, for: id)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        return hosting
    }
}

// MARK: - Harbour Direct Bridges

@HarbourDirect
public func tab_create_state(id: String) {
    _ = SwiftTabViewLoader.createState(id: id)
}

@HarbourDirect
public func tab_add(rootId: String, id: String, title: String, icon: String) {
    SwiftTabViewLoader.addTab(rootId: rootId, id: id, title: title, icon: icon)
}

@HarbourDirect
public func swift_tabview_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    parentPtr: Int64,
    id: String
) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        
        let tabView = SwiftTabViewLoader.makeTabView(id: id)
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: tabView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(tabView).toOpaque()
            viewAddress = Int64(Int(bitPattern: viewPtr))
        }
        
        return viewAddress
    }

    if Thread.isMainThread {
        return executeCreation()
    } else {
        return DispatchQueue.main.sync {
            return executeCreation()
        }
    }
}

@HarbourDirect
public func tab_destroy(id: String, viewPtr: Int64) {
    ViewRegistry.clean(id: id)
    if viewPtr != 0 {
        if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
            _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
        }
    }
}
