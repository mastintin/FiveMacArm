import SwiftUI
import AppKit

public struct SidebarItemData: Identifiable, Hashable {
    public let id: String
    public let label: String
    public let icon: String
    public let section: String
}

/// Estado especializado para la ventana de navegación que soporta selección nativa
@Observable
public class SwiftNavWindowState: SwiftWindowState {
    public var selectedId: String? = nil
    public var sidebarItems: [SidebarItemData] = []
    
    public override init(id: String) {
        super.init(id: id)
    }

    public override func apply(property: String, value: Any) {
        let prop = property.lowercased()
        if prop == "selectedid" || prop == "value" {
            self.selectedId = String(describing: value)
        } else if prop == "additem" {
            if let dict = value as? [String: Any],
               let id = dict["id"] as? String,
               let label = dict["label"] as? String {
                let icon = dict["icon"] as? String ?? "circle"
                let section = dict["section"] as? String ?? ""
                let newItem = SidebarItemData(id: id, label: label, icon: icon, section: section)
                if !self.sidebarItems.contains(newItem) {
                    self.sidebarItems.append(newItem)
                }
            }
        } else {
            super.apply(property: property, value: value)
        }
    }
}

private var strongWindowStorage: [String: NSWindow] = [:]

@MainActor
public func sw_createnavwindow_hb_internal(title: String,
                                           width: Double,
                                           height: Double,
                                           id: String) {

    // 1. Estado
    let windowState = SwiftNavWindowState(id: id)
    ViewRegistry.register(windowState, for: id)
    
    // 2. Ventana (Respetando el tamaño de Harbour)
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)),
        styleMask: [.titled, .closable, .miniaturizable, .resizable],
        backing: .buffered,
        defer: false
    )
    window.title = title
    window.backgroundColor = .windowBackgroundColor
    window.center()

    // 3. Delegado
    let delegate = SwWindowDelegate(windowId: id)
    window.delegate = delegate
    ViewRegistry.register(delegate, for: "Delegate_\(id)")

    // 4. Inyección de NavigationSplitView nativo
    let windowView = SwNavWindowView(state: windowState, id: id)
    let hostingView = NSHostingView(rootView: windowView)
    hostingView.frame = NSRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
    hostingView.autoresizingMask = [.width, .height]
    window.contentView = hostingView
    
    // 5. Registro y Retención
    ViewRegistry.register(window, for: "NSWindow_\(id)")
    strongWindowStorage[id] = window 
    
    print("🚀 [NavWindow] Navegación Nativa activada para ID: \(id)")
}

public struct SwNavWindowView: View {
    @Bindable var state: SwiftNavWindowState
    let id: String
    
    public var body: some View {
        NavigationSplitView {
            List(selection: $state.selectedId) {
                let itemsBySection = Dictionary(grouping: state.sidebarItems, by: { $0.section })
                let sectionKeys = itemsBySection.keys.sorted()
                
                ForEach(sectionKeys, id: \.self) { section in
                    Section(section.isEmpty ? "Menú" : section) {
                        let sectionItems = itemsBySection[section] ?? []
                        ForEach(sectionItems) { item in
                            NavigationLink(value: item.id) {
                                Label(item.label, systemImage: item.icon)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Navegación")
            .listStyle(.sidebar)
        } detail: {
            ZStack {
                Color(NSColor.windowBackgroundColor)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    if let sel = state.selectedId,
                       let item = state.sidebarItems.first(where: { $0.id == sel }) {
                        
                        Image(systemName: item.icon)
                            .font(.system(size: 80))
                            .foregroundColor(.accentColor)
                        
                        Text(item.label)
                            .font(.system(size: 40, weight: .bold))
                        
                        Text("ID: \(item.id)")
                            .foregroundColor(.secondary)
                        
                    } else {
                        VStack(spacing: 15) {
                            Image(systemName: "sidebar.left")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("Selecciona una opción")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}
