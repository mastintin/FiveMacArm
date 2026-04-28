import SwiftUI

@Observable
public class SwiftPanelState: SwiftVStackState {
    public var id: String = ""
    public var title: String = ""
    public var borderWidth: CGFloat = 0
    public var borderColor: Color = .clear
    public var shadowRadius: CGFloat = 0
    public var padding: CGFloat = 10
    
    public init(id: String) {
        super.init()
        self.id = id
    }
    
    public override func apply(property: String, value: Any) {
        // Primero dejamos que la clase base procese (backcolor, corner, etc)
        super.apply(property: property, value: value)
        
        let prop = property.lowercased()
        if prop == "title" {
            if let v = value as? String { self.title = v }
        } else if prop == "borderwidth" {
            if let n = value as? NSNumber { self.borderWidth = CGFloat(truncating: n) }
        } else if prop == "bordercolor" {
            if let s = value as? String { self.borderColor = s.hasPrefix(".") ? mapBaseColor(s) : Color(hex: s) }
        } else if prop == "shadow" {
            if let n = value as? NSNumber { self.shadowRadius = CGFloat(truncating: n) }
        } else if prop == "padding" {
            if let n = value as? NSNumber { self.padding = CGFloat(truncating: n) }
        }
    }
}

public struct SwPanelView: View {
    var state: SwiftPanelState
    let type: StackItem.ItemType
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !state.title.isEmpty {
                Text(state.title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
            }
            
            // Reutilizamos SwStackContent para los hijos
            SwStackContent(state: state, type: .vstack)
                .padding(state.padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(state.backgroundColor ?? AnyShapeStyle(Color.clear))
        .cornerRadius(state.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: state.cornerRadius)
                .stroke(state.borderColor, lineWidth: state.borderWidth)
        )
        .shadow(radius: state.shadowRadius)
    }

    @MainActor
    public static func create(id: String, initial: GenericInit) -> StackItem {
        let state = SwiftPanelState(id: id)
        state.title = initial.title ?? ""
        ViewRegistry.register(state, for: id)
        let item = StackItem(type: .panel, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}
