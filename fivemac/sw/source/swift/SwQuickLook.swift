import SwiftUI
import Quartz

// MARK: - Estructura de Inicialización
struct QuickLookInit: Codable, GeometryProtocol {
    var filename: String?; var width: Double?; var height: Double?; var top: Double?; var left: Double?
    var resizemask: Int?; var parentwidth: Double?; var parentheight: Double?
}

// MARK: - Estado y Lógica
@Observable
public class SwiftQuickLookState: SwApplyable {
    public var fileURL: URL?
    public var isVisible: Bool = true
    public var isEnabled: Bool = true
    public var scale: Double = 1.0
    public var cornerRadius: CGFloat = 8
    public var placeholderTitle: String = "Vista Previa"
    public var placeholderDescription: String = "Seleccione un archivo"

    public init() {}

    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "filename":
            if let path = value as? String, !path.isEmpty {
                self.fileURL = URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
            } else { self.fileURL = nil }
        case "visible": self.isVisible = SwUtils.toBool(value)
        case "enabled": self.isEnabled = SwUtils.toBool(value)
        case "scale", "zoom": if let n = SwUtils.toDouble(value) { self.scale = n }
        case "corner", "cornerradius": if let n = SwUtils.toDouble(value) { self.cornerRadius = CGFloat(n) }
        default: break
        }
    }
}

// MARK: - Vista Principal
public struct SwiftQuickLookView: View {
    @Bindable var state: SwiftQuickLookState
    
    public var body: some View {
        if state.isVisible {
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    // Volvemos al ScrollView de SwiftUI que es más compatible con tu Layout
                    ScrollView([.horizontal, .vertical]) {
                        ZStack(alignment: .topLeading) {
                            if let url = state.fileURL {
                                QuickLookNSView(url: url)
                                    .frame(
                                        width: geometry.size.width * state.scale,
                                        height: geometry.size.height * state.scale
                                    )
                                    // El ID fuerza a que el visor se recree y cargue al cambiar URL
                                    .id(url.path) 
                            } else {
                                ContentUnavailableView(state.placeholderTitle, systemImage: "eye.slash")
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            }
                        }
                    }
                }
                
                // Toolbar minimalista
                HStack {
                    Button(action: { state.scale += 0.25 }) { Image(systemName: "plus.magnifyingglass") }
                    Button(action: { state.scale = max(0.5, state.scale - 0.25) }) { Image(systemName: "minus.magnifyingglass") }
                    Button("100%") { state.scale = 1.0 }.buttonStyle(.link)
                    Spacer()
                    if let name = state.fileURL?.lastPathComponent {
                        Text(name).font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(8).background(.ultraThinMaterial).buttonStyle(.plain)
            }
            .clipShape(RoundedRectangle(cornerRadius: state.cornerRadius))
            .opacity(state.isEnabled ? 1.0 : 0.5)
        }
    }
}

// MARK: - El Visor Nativo (Tu código original optimizado)
struct QuickLookNSView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> QLPreviewView {
        // Creamos el visor exactamente como en tu HB_FUNC
        let preview = QLPreviewView(frame: .zero, style: .normal) ?? QLPreviewView()
        preview.autostarts = true
        preview.autoresizingMask = [.width, .height]
        
        // Carga inmediata forzada
        preview.previewItem = url as QLPreviewItem
        preview.refreshPreviewItem()
        
        return preview
    }

    func updateNSView(_ nsView: QLPreviewView, context: Context) {
        // Actualizamos solo si la URL cambia
        if nsView.previewItem?.previewItemURL != url {
            nsView.previewItem = url as QLPreviewItem
            nsView.refreshPreviewItem()
        }
    }
}

// MARK: - Factory
extension SwiftQuickLookView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(QuickLookInit.self, from: jsonData)
        let state = SwiftQuickLookState()
        if let fname = initial.filename { state.apply(property: "filename", value: fname) }
        ViewRegistry.register(state, for: id)
        let item = StackItem(type: .quicklook, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}


