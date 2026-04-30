import SwiftUI

@Observable
public class SwiftSidebarState: SwiftVStackState {
    public var id: String = ""
    public var selection: String = ""
    public var width: CGFloat = 200
    
    public init(id: String) {
        super.init()
        self.id = id
    }
    
    public override func apply(property: String, value: Any) {
        super.apply(property: property, value: value)
        
        let prop = property.lowercased()
        if prop == "selection" {
            if let v = value as? String { self.selection = v }
        } else if prop == "width" {
            if let n = value as? NSNumber { self.width = CGFloat(truncating: n) }
        }
    }
}

public struct SwSidebarView: View {
    var state: SwiftSidebarState
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Renderizamos los hijos dentro de un ScrollView con estilo de sidebar
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    SwStackContent(state: state, type: .vstack)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
            }
        }
        .frame(width: state.width)
        .frame(maxHeight: .infinity)
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow))
    }

    @MainActor
    public static func create(id: String, initial: GenericInit) -> StackItem {
        let state = SwiftSidebarState(id: id)
        ViewRegistry.register(state, for: id)
        let item = StackItem(type: .sidebar, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

// Auxiliar para el efecto de material nativo de macOS
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
