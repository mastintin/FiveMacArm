import SwiftUI

/// A specialized recursive renderer for the Sw (Swift-Native) architecture experiment.
/// It separates absolute positioning (ZStack) from the standard FiveMac VStack layout.
public struct SwRecursiveItemView: View {
    @Bindable var item: StackItem
    let onAction: ((String) -> Void)?
    let index: Int
    
    @State private var isPressed = false
    
    public var body: some View {
        Group {
            switch item.type {
            case .button:
                if let state = ViewRegistry.getState(for: item.id) as? ButtonState {
                    SwiftButtonView(state: state, onAction: onAction)
                        .frame(width: CGFloat(item.itemWidth ?? 100), height: CGFloat(item.itemHeight ?? 40))
                }

            case .text:
                if let state = ViewRegistry.getState(for: item.id) as? LabelState {
                    SwiftLabelView(state: state)
                        .frame(width: CGFloat(item.itemWidth ?? 100), height: CGFloat(item.itemHeight ?? 20))
                }
                
            case .aichat:
                if let state = ViewRegistry.get(item.id) as? SwiftAIChatState {
                    SwiftAIChatView(state: state)
                        .frame(width: CGFloat(item.itemWidth ?? 400), height: CGFloat(item.itemHeight ?? 300))
                }

            case .toggle:
                if let state = ViewRegistry.getState(for: item.id) as? ToggleState {
                    SwiftToggleView(state: state)
                        .frame(width: CGFloat(item.itemWidth ?? 200), height: CGFloat(item.itemHeight ?? 30))
                }

            case .slider:
                if let state = ViewRegistry.getState(for: item.id) as? SliderState {
                    SwiftSliderView(state: state)
                        .frame(width: CGFloat(item.itemWidth ?? 200), height: CGFloat(item.itemHeight ?? 30))
                }

            default:
                EmptyView()
            }
        }
    }
}

/// Specialized View for SwWindow - Flat Absolute Positioning
public struct SwWindowView: View {
    @Bindable var state: SwiftVStackState
    let id: String
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            // Background is now handled by NSWindow
            ForEach(state.items) { item in
                SwRecursiveItemView(item: item, onAction: { itemId in
                    print("SwiftView: Enviando clic de \(itemId) a Harbour...")
                    Harbour.call("SW_FMH", itemId, 9) // 9 = WM_BTNCLICK
                }, index: 0)
                .position(
                    x: CGFloat((item.x ?? 0) + (item.itemWidth ?? 0) / 2),
                    y: CGFloat((item.y ?? 0) + (item.itemHeight ?? 0) / 2)
                )
            }
        }
        // .drawingGroup() // ELIMINADO: Impedía el renderizado de controles nativos como Toggle
        .frame(minWidth: 100, minHeight: 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
