import SwiftUI
import AppKit

@available(OSX 10.15, *)
public struct ViewRegistry {
    public static var views: [Int: AnyView] = [:]
    
    public static func register(_ view: some View, for index: Int) {
        views[index] = AnyView(view)
    }
    
    public static func clean(index: Int) {
        views.removeValue(forKey: index)
    }
}

@available(OSX 10.15, *)
struct SwiftTabView: View {
    var tabData: [(id: Int, title: String, icon: String)]
    
    var body: some View {
        if #available(OSX 11.0, *) {
            TabView {
                ForEach(tabData, id: \.id) { item in
                    if let view = ViewRegistry.views[item.id] {
                        view
                            .tabItem {
                                Label(item.title, systemImage: item.icon)
                            }
                    } else {
                        Text("View \(item.id) not found")
                            .tabItem {
                                Text(item.title)
                            }
                    }
                }
            }
            .padding()
        } else {
            Text("TabView requires macOS 11.0+")
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
            // Clear tabs for next usage? Or keep? 
            // Better design: makeTabView takes the array. But passing arrays from ObjC complex.
            // Using static accumulator for this generic bridging.
            // tabs.removeAll() // Should clear after creation
            return hosting
        }
        return NSView()
    }
    
    @objc public static func clearTabs() {
        tabs.removeAll()
    }
}
