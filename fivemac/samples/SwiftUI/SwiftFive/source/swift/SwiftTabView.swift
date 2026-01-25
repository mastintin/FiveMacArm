import SwiftUI
import AppKit

@available(OSX 10.15, *)
@objc(ViewRegistry)
public class ViewRegistry: NSObject {
    private static var views: [Int: AnyView] = [:]
    private static var objects: [Int: Any] = [:]
    
    @objc(registerObject:forIndex:) 
    public static func registerObject(_ object: Any, for index: NSInteger) {
        let idx = Int(index)
        print("DEBUG: [Swift] ViewRegistry registering object for index \(idx)")
        objects[idx] = object
    }
    
    @objc(getObject:) 
    public static func getObject(for index: NSInteger) -> Any? {
        let idx = Int(index)
        // print("DEBUG: [Swift] ViewRegistry getting object for index \(idx)")
        return objects[idx]
    }
    
    public static func register<T: View>(_ view: T, for index: Int) {
        views[index] = AnyView(view)
    }
    
    public static func getView(for index: Int) -> AnyView? {
        return views[index]
    }
    
    @objc(clean:) 
    public static func clean(index: NSInteger) {
        views.removeValue(forKey: Int(index))
        objects.removeValue(forKey: Int(index))
    }

    @objc(registerNSView:forIndex:)
    public static func registerNSView(_ view: NSView, for index: NSInteger) {
        let idx = Int(index)
        let wrapper = GenericNSViewWrapper(view: view)
        views[idx] = AnyView(wrapper)
    }
}

struct GenericNSViewWrapper: NSViewRepresentable {
    let view: NSView
    
    func makeNSView(context: Context) -> NSView {
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
    }
}

@available(OSX 10.15, *)
@available(OSX 10.15, *)
struct SwiftTabView: View {
    var tabData: [(id: Int, title: String, icon: String)]
    @State private var selectedTab: Int
    
    init(tabData: [(id: Int, title: String, icon: String)]) {
        self.tabData = tabData
        _selectedTab = State(initialValue: tabData.first?.id ?? 0)
    }
    
    var body: some View {
        if #available(OSX 11.0, *) {
            VStack(spacing: 0) {
                // Top Segmented Control using Picker
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
                
                // Content Area
                ZStack {
                    ForEach(tabData, id: \.id) { item in
                        if selectedTab == item.id {
                             if let view = ViewRegistry.getView(for: item.id) {
                                view
                            } else {
                                Text("View \(item.id) not found")
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            Text("Modern TabView requires macOS 11.0+")
        }
    }
}

@objc(SwiftTabViewLoader)
public class SwiftTabViewLoader: NSObject {
    static var tabs: [(id: Int, title: String, icon: String)] = []
    
    @objc public static func addTab(index: Int, title: String, icon: String) {
        tabs.append((id: index, title: title, icon: icon))
    }
    
    @objc public static func makeTabView() -> NSView {
        if #available(OSX 10.15, *) {
            let view = SwiftTabView(tabData: tabs)
            let hosting = NSHostingView(rootView: view)
            hosting.translatesAutoresizingMaskIntoConstraints = false
            return hosting
        }
        return NSView()
    }
    
    @objc public static func clearTabs() {
        tabs.removeAll()
    }
}
