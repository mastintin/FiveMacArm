import Foundation
import SwiftUI
import AppKit

// MARK: - Selection State
class SelectionState: ObservableObject {
    @Published var items: [String] = []
    @Published var searchText: String = ""
    @Published var editText: String = ""
    @Published var selectedIndex: Int? = nil
    @Published var title: String = ""
    @Published var isPresented: Bool = false
    @Published var mode: SelectionMode = .list
    
    enum SelectionMode {
        case list
        case multiline
    }
    
    var filteredItems: [(Int, String)] {
        let enumerated = items.enumerated().map { ($0, $1) }
        if searchText.isEmpty {
            return enumerated
        } else {
            return enumerated.filter { $0.1.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

// MARK: - Selection View (Premium UI)
struct SwSelectionView: View {
    @ObservedObject var state: SelectionState
    var onSelect: (Int?) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Premium
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(state.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if state.mode == .list {
                        Text("\(state.items.count) opciones")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Button(action: { onSelect(nil) }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.primary.opacity(0.03))
            
            Divider().opacity(0.3)
            
            // Content
            if state.mode == .list {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Buscar...", text: $state.searchText)
                        .textFieldStyle(.plain).font(.system(size: 13))
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
                .padding(.horizontal, 20).padding(.vertical, 12)
                
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(state.filteredItems, id: \.0) { index, item in
                            Button(action: { onSelect(index) }) {
                                HStack {
                                    Text(item).font(.system(size: 13, weight: .medium))
                                        .foregroundColor(state.selectedIndex == index ? .white : .primary)
                                    Spacer()
                                    if state.selectedIndex == index {
                                        Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
                                    }
                                }
                                .padding(.horizontal, 14).padding(.vertical, 10)
                                .background(state.selectedIndex == index ? Color.accentColor : Color.primary.opacity(0.02))
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }.padding(.horizontal, 16).padding(.bottom, 16)
                }
                .frame(minHeight: 250, maxHeight: 450)
            } else {
                TextEditor(text: $state.editText)
                    .font(.system(size: 13, design: .monospaced))
                    .frame(minHeight: 250, maxHeight: 450)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.04)))
                    .padding(20)
            }
            
            Divider().opacity(0.3)
            
            // Footer
            HStack(spacing: 12) {
                Spacer()
                Button("Cancelar") { onSelect(nil) }
                    .buttonStyle(.bordered).keyboardShortcut(.cancelAction)
                
                if state.mode == .multiline {
                    Button("Aceptar") { onSelect(-1) }
                        .buttonStyle(.borderedProminent).keyboardShortcut(.defaultAction)
                }
            }
            .padding(.horizontal, 20).padding(.vertical, 16)
            .background(Color.primary.opacity(0.03))
        }
        .frame(width: 420)
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow).ignoresSafeArea())
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

// MARK: - Panel Host y Delegado
class SelectionPanel: NSPanel {
    var onClosing: (() -> Void)?
    
    init(view: AnyView, title: String) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 420, height: 600),
                   styleMask: [.titled, .closable, .fullSizeContentView],
                   backing: .buffered, defer: false)
        
        self.isFloatingPanel = true
        self.level = .floating
        self.title = title
        self.titleVisibility = .visible
        self.titlebarAppearsTransparent = true
        self.backgroundColor = .clear
        self.isMovableByWindowBackground = true
        self.hasShadow = true
        self.delegate = self // IMPORTANTE
        
        let hostingController = NSHostingController(rootView: view)
        self.contentView = hostingController.view
        self.center()
    }
}

extension SelectionPanel: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // Si la ventana se cierra (botón rojo), avisamos al manager
        self.onClosing?()
    }
}

// MARK: - Manager Global de Selección
public class SwSelectionManager {
    static let shared = SwSelectionManager()
    private var currentPanel: SelectionPanel?
    private var isHandlingModal = false
    
    @MainActor
    func show(title: String, items: [String] = [], text: String = "", mode: SelectionState.SelectionMode = .list, isSync: Bool = false, callback: @escaping (Any?) -> Void) {
        let state = SelectionState()
        state.title = title
        state.items = items
        state.editText = text
        state.mode = mode
        
        var completed = false
        
        // Función auxiliar para cerrar todo de forma segura
        let cleanup: (Any?) -> Void = { result in
            guard !completed else { return }
            completed = true
            
            callback(result)
            
            if isSync && self.isHandlingModal {
                self.isHandlingModal = false
                NSApp.stopModal()
            }
            
            self.currentPanel?.onClosing = nil // Evitamos recursión
            self.currentPanel?.close()
            self.currentPanel = nil
        }
        
        let view = SwSelectionView(state: state) { index in
            if mode == .multiline {
                cleanup(index == nil ? nil : state.editText)
            } else {
                cleanup(index)
            }
        }
        
        let panel = SelectionPanel(view: AnyView(view), title: title)
        panel.onClosing = {
            cleanup(nil) // Si se cierra por el botón rojo, devolvemos nulo
        }
        
        self.currentPanel = panel
        NSApp.activate(ignoringOtherApps: true)
        
        if isSync {
            self.isHandlingModal = true
            panel.makeKeyAndOrderFront(nil)
            NSApp.runModal(for: panel)
        } else {
            panel.makeKeyAndOrderFront(nil)
        }
    }
}
