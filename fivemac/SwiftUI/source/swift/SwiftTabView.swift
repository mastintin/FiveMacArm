import SwiftUI
import AppKit
import HarbourMacro


struct GenericNSViewWrapper: NSViewRepresentable {
    let view: NSView
    
    func makeNSView(context: Context) -> NSView {
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
    }
}

struct SwiftTabView: View {
    var tabData: [(id: String, title: String, icon: String)]
    @State private var selectedTab: String
    
    init(tabData: [(id: String, title: String, icon: String)]) {
        self.tabData = tabData
        _selectedTab = State(initialValue: tabData.first?.id ?? "")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if !tabData.isEmpty {
                Picker("", selection: $selectedTab) {
                    ForEach(tabData, id: \.id) { item in
                        Text(item.title).tag(item.id)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            
            ZStack {
                ForEach(tabData, id: \.id) { item in
                    if selectedTab == item.id {
                         if let nsView = ViewRegistry.get(item.id) as? NSView {
                            GenericNSViewWrapper(view: nsView)
                        } else {
                            Text("View \(item.id) not found")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

@objc(SwiftTabViewLoader)
public class SwiftTabViewLoader: NSObject {
    static var tabs: [(id: String, title: String, icon: String)] = []
    
    @objc(addTabWithIndex:title:icon:)
    public static func addTab(index: Int, title: String, icon: String) {
        addTab(id: String(index), title: title, icon: icon)
    }

    public static func addTab(id: String, title: String, icon: String) {
        tabs.append((id: id, title: title, icon: icon))
    }
    
    @objc(makeTabView)
    public static func makeTabView() -> NSView {
        let view = SwiftTabView(tabData: tabs)
        let hosting = NSHostingView(rootView: view)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        return hosting
    }
    
    @objc(clearTabs)
    public static func clearTabs() {
        tabs.removeAll()
    }
}

// --- HARBOUR DIRECT BRIDGES ---

@HarbourDirect
public func tab_clear() {
    SwiftTabViewLoader.clearTabs()
}

@HarbourDirect
public func tab_add(id: String, title: String, icon: String) {
    SwiftTabViewLoader.addTab(id: id, title: title, icon: icon)
}

@HarbourDirect
public func swift_tabview_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    parentPtr: Int64
) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        
        let tabView = SwiftTabViewLoader.makeTabView()
        
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
public func tab_destroy(viewPtr: Int64) {
    if viewPtr != 0 {
        if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
            _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
        }
    }
}
