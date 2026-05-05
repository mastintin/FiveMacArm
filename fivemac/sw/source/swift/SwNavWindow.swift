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
    public var selectedContentId: String? = nil
    public var sidebarItems: [SidebarItemData] = []
    public var path = NavigationPath()
    
    public override init(id: String) {
        super.init(id: id)
    }

    public override func apply(property: String, value: Any) {
        let prop = property.lowercased()
        if prop == "selectedid" || prop == "value" {
            self.selectedId = String(describing: value)
            self.selectedContentId = nil
            self.path = NavigationPath() // Reset path when switching sidebar item
        } else if prop == "selectedcontentid" {
            self.selectedContentId = String(describing: value)
        } else if prop == "clearcontent" {
            self.selectedContentId = nil
        } else if prop == "push" {
            if let targetId = value as? String {
                self.path.append(targetId)
            }
        } else if prop == "pop" {
            if !self.path.isEmpty {
                self.path.removeLast()
            }
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
            let navTitle = state.title ?? "Navegación"
            List(selection: $state.selectedId) {
                let itemsBySection = Dictionary(grouping: state.sidebarItems, by: { $0.section })
                let sectionKeys = itemsBySection.keys.sorted()
                
                ForEach(sectionKeys, id: \.self) { section in
                    Section(section.isEmpty ? "Menú" : section) {
                        renderSectionItems(itemsBySection[section] ?? [])
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle(navTitle)
            .onChange(of: state.selectedId) { old, new in
                if let val = new {
                    SwiftBridge.onEvent(id, event: "change", value: val)
                }
            }
        } content: {
            // Columna Central: Contenido secundario (Listas, etc.)
            ZStack {
                Color(NSColor.windowBackgroundColor)
                
                if let sel = state.selectedId,
                   let item = state.items.first(where: { $0.id.lowercased() == sel.lowercased() }) {
                    SwRecursiveItemView(item: item)
                } else {
                    ContentUnavailableView("Seleccione un módulo", systemImage: "sidebar.left")
                }
            }
        } detail: {
            // Columna de Detalle: Tercer estadio
            NavigationStack(path: $state.path) {
                if let selDetail = state.selectedContentId,
                   let item = state.items.first(where: { $0.id.lowercased() == selDetail.lowercased() }) {
                    SwRecursiveItemView(item: item)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else {
                    renderDefaultView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(NSColor.windowBackgroundColor))
                }
            }
            .background(Color(NSColor.windowBackgroundColor))
            .navigationDestination(for: String.self) { destinationId in
                if let item = state.items.first(where: { $0.id.lowercased() == destinationId.lowercased() }) {
                    SwRecursiveItemView(item: item)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Vista no encontrada: \(destinationId)")
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: state.selectedId) { 
            state.selectedContentId = nil
            state.path = NavigationPath()
        }
        .frame(minWidth: 800, minHeight: 600)
    }

    @ViewBuilder
    private func renderSectionItems(_ items: [SidebarItemData]) -> some View {
        ForEach(items) { item in
            Label(item.label, systemImage: item.icon)
                .tag(item.id)
        }
    }

    @ViewBuilder
    private func renderDefaultView() -> some View {
        VStack(spacing: 20) {
            if let sel = state.selectedContentId,
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
                    Image(systemName: "square.dashed")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("Seleccione un elemento para ver el detalle")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
