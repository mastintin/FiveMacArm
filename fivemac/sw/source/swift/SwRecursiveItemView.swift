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
                // Custom Capsule Button for maximum persistence during focus loss
                Text(item.content)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .frame(width: CGFloat(item.itemWidth ?? 150), height: CGFloat(item.itemHeight ?? 40))
                    .background {
                        Capsule()
                            .fill(
                                isPressed 
                                ? LinearGradient(colors: [Color.blue.opacity(0.8), Color.blue], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: .black.opacity(isPressed ? 0.1 : 0.2), radius: isPressed ? 1 : 3, x: 0, y: isPressed ? 1 : 2)
                    }
                    .scaleEffect(isPressed ? 0.96 : 1.0)
                    .contentShape(Capsule())
                    // Manual press gesture to avoid native Button optimizations that hide it
                    .onLongPressGesture(minimumDuration: 0.0, pressing: { pressing in
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            isPressed = pressing
                        }
                    }, perform: {
                        onAction?(item.id)
                    })

            case .text:
                Text(item.content)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(item.fgColor.map { Color(rgba: $0) } ?? .primary)
                
            case .aichat:
                if let state = ViewRegistry.get(item.id) as? SwiftAIChatState {
                    SwiftAIChatView(state: state)
                        .frame(width: CGFloat(item.itemWidth ?? 400), height: CGFloat(item.itemHeight ?? 300))
                } else {
                    Text("AIChat State not found: \(item.id)")
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
        .drawingGroup() // Flatten hierarchy to Metal texture for maximum persistence 
        .frame(minWidth: 100, minHeight: 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
