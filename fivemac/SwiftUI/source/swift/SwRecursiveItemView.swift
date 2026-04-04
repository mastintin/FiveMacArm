import SwiftUI

/// A specialized recursive renderer for the Sw (Swift-Native) architecture experiment.
/// It separates absolute positioning (ZStack) from the standard FiveMac VStack layout.
public struct SwRecursiveItemView: View {
    @Bindable var item: StackItem
    let onAction: ((String) -> Void)?
    let index: Int
    
    public var body: some View {
        Group {
            switch item.type {
            case .button:
                Button(action: {
                    onAction?(item.id)
                }) {
                    Text(item.content)
                        .padding(5)
                }
                .buttonStyle(.borderedProminent)
                .frame(width: CGFloat(item.itemWidth ?? 150), height: CGFloat(item.itemHeight ?? 40))

            case .text:
                Text(item.content)
                    .foregroundStyle(Color(red: item.fgColor?.r ?? 0, green: item.fgColor?.g ?? 0, blue: item.fgColor?.b ?? 0))
                
            default:
                EmptyView()
            }
        }
    }
}

/// Specialized View for SwWindow - Flat Absolute Positioning
public struct SwWindowView: View {
    var state: SwiftVStackState
    let id: String
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            // Invisible layer to force the ZStack to fill the whole window
            Color.clear
            
            ForEach(state.items.indices, id: \.self) { index in
                let item = state.items[index]
                SwRecursiveItemView(item: item, onAction: { itemId in
                    // NEW: Our private Sw-only bridge!
                    // This calls SW_FMH( id, msg ) in Harbour
                    DispatchQueue.main.async {
                        "SW_FMH".withCString { cStr in
                            if let ds = hb_dynsymFindName(cStr) {
                                if let sym = hb_dynsymSymbol(ds) {
                                    hb_vmPushSymbol(sym)
                                    hb_vmPushNil()
                                    hb_vmPushString(itemId)
                                    hb_vmPushNumber(9, 0) // WM_BTNCLICK
                                    hb_vmDo(2) // Only 2 parameters: ID and MSG
                                }
                            }
                        }
                    }
                }, index: index)
                .offset(x: CGFloat(item.x ?? 0), y: CGFloat(item.y ?? 0))
            }
        }
        .frame(minWidth: 100, minHeight: 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
