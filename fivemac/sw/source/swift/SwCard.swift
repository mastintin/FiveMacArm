import SwiftUI
import Observation

@Observable
public class SwiftCardState: SwiftVStackState {
    public var title: String = ""
    public var symbol: String = ""
    public var accentColor: AnyShapeStyle? = nil
    public var iconColor: AnyShapeStyle? = nil
    public var titleColor: AnyShapeStyle? = nil
    public var accentSide: Int = 1 // 1: top, 2: bottom, 3: left, 4: right, 5: all, 0: none
    public var accentWidth: Double = 4
    public var shadowRadius: Double = 5
    public var borderColor: AnyShapeStyle? = nil
    public var borderWidth: Double = 0
    
    public override init() {
        super.init()
        self.cornerRadius = 12
    }
    
    public override func apply(property: String, value: Any) {
        let prop = property.lowercased()
        if prop == "title" {
            if let s = value as? String { self.title = s }
        } else if prop == "symbol" {
            if let s = value as? String { self.symbol = s }
        } else if prop == "accentcolor" {
            if let s = value as? String { self.accentColor = mapColorStyle(s) }
        } else if prop == "iconcolor" {
            if let s = value as? String { self.iconColor = mapColorStyle(s) }
        } else if prop == "titlecolor" {
            if let s = value as? String { self.titleColor = mapColorStyle(s) }
        } else if prop == "shadow" {
            if let n = SwUtils.toDouble(value) { self.shadowRadius = n }
        } else if prop == "accentside" {
            if let n = SwUtils.toInt(value) { self.accentSide = n }
        } else if prop == "accentwidth" {
            if let n = SwUtils.toDouble(value) { self.accentWidth = n }
        } else if prop == "bordercolor" {
            if let s = value as? String { self.borderColor = mapColorStyle(s) }
        } else if prop == "borderwidth" {
            if let n = SwUtils.toDouble(value) { self.borderWidth = n }
        } else {
            super.apply(property: property, value: value)
        }
    }
}

public struct SwiftCardView: View {
    var state: SwiftCardState
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top Accent Bar
            if state.accentSide == 1, let accent = state.accentColor {
                Rectangle().fill(accent).frame(height: CGFloat(state.accentWidth))
            }
            
            HStack(alignment: .top, spacing: 0) {
                // Left Accent Bar
                if state.accentSide == 3, let accent = state.accentColor {
                    Rectangle().fill(accent).frame(width: CGFloat(state.accentWidth))
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    if !state.title.isEmpty || !state.symbol.isEmpty {
                        HStack(alignment: .center, spacing: 10 ) {
                            if !state.symbol.isEmpty {
                                Image(systemName: state.symbol)
                                    .font(.system(size: 32))
                                    .foregroundStyle(state.iconColor ?? AnyShapeStyle(.secondary))
                            }
                            
                            Text(state.title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(state.titleColor ?? AnyShapeStyle(.primary))
                            
                            Spacer()
                        }
                        .padding(.bottom, 15)
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: state.spacing > 0 ? state.spacing : 8) {
                        ForEach(state.items) { subItem in
                            SwRecursiveItemView(item: subItem)
                        }
                    }
                    
                    Spacer(minLength: 0) // Empujamos todo hacia arriba
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.top, 25) // Valor equilibrado para el padding superior
                
                // Right Accent Bar
                if state.accentSide == 4, let accent = state.accentColor {
                    Rectangle().fill(accent).frame(width: CGFloat(state.accentWidth))
                }
            }
            
            // Bottom Accent Bar
            if state.accentSide == 2, let accent = state.accentColor {
                Rectangle().fill(accent).frame(height: CGFloat(state.accentWidth))
            }
        }
        .background(state.backgroundColor ?? AnyShapeStyle(Color(NSColor.controlBackgroundColor)))
        .cornerRadius(state.cornerRadius)
        .shadow(color: Color.black.opacity(0.15), radius: CGFloat(state.shadowRadius), x: 0, y: state.shadowRadius / 2)
        .overlay(
            RoundedRectangle(cornerRadius: state.cornerRadius)
                .stroke(state.borderColor ?? (state.accentSide == 5 ? state.accentColor : nil) ?? AnyShapeStyle(.clear), 
                        lineWidth: state.borderWidth > 0 ? state.borderWidth : (state.accentSide == 5 ? state.accentWidth : 0))
        )
        .clipShape(RoundedRectangle(cornerRadius: state.cornerRadius))
    }
    
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(CardInit.self, from: jsonData)
        
        let state = SwiftCardState()
        state.title = initial.title ?? ""
        state.symbol = initial.symbol ?? ""
        
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .card, id: id)
        item.itemWidth = initial.width
        item.itemHeight = initial.height
        item.x = initial.left
        item.y = initial.top
        item.resizemask = initial.resizemask ?? 0
        
        return item
    }
}

struct CardInit: Codable, GeometryProtocol {
    let title: String?
    let symbol: String?
    let width: Double?
    let height: Double?
    let top: Double?
    let left: Double?
    let resizemask: Int?
    let parentwidth: Double?
    let parentheight: Double?
}
