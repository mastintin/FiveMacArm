import SwiftUI

/// A specialized recursive renderer for the Sw (Swift-Native) architecture experiment.
/// It separates absolute positioning (ZStack) from the standard FiveMac VStack layout.
public struct SwRecursiveItemView: View {
    @Bindable var item: StackItem
    let width: CGFloat
    let height: CGFloat
    let onAction: ((String) -> Void)?
    let index: Int
    
    @State private var isPressed = false
    
    public var body: some View {
        Group {
            switch item.type {
            case .button:
                if let state = ViewRegistry.getState(for: item.id) as? ButtonState {
                    SwiftButtonView(state: state, onAction: onAction)
                        .frame(width: width, height: height)
                }

            case .text:
                if let state = ViewRegistry.getState(for: item.id) as? LabelState {
                    SwiftLabelView(state: state)
                        .frame(width: width, height: height)
                }
                
            case .aichat:
                if let state = ViewRegistry.get(item.id) as? SwiftAIChatState {
                    SwiftAIChatView(state: state)
                        .frame(width: width, height: height)
                }

            case .toggle:
                if let state = ViewRegistry.getState(for: item.id) as? ToggleState {
                    SwiftToggleView(state: state)
                        .frame(width: width, height: height)
                }

            case .slider:
                if let state = ViewRegistry.getState(for: item.id) as? SliderState {
                    SwiftSliderView(state: state)
                        .frame(width: width, height: height)
                }

            case .webview:
                if let state = ViewRegistry.getState(for: item.id) as? WebViewState {
                    SwiftWebView(state: state)
                        .frame(width: width, height: height)
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
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                ForEach(state.items) { item in
                    let geometry = calculateGeometry(for: item, in: proxy.size)
                    
                    SwRecursiveItemView(
                        item: item, 
                        width: geometry.width,
                        height: geometry.height,
                        onAction: { itemId in
                            Harbour.call("SW_FMH", itemId, 9) // 9 = WM_BTNCLICK
                        }, 
                        index: 0
                    )
                    .position(
                        x: geometry.x + geometry.width / 2,
                        y: geometry.y + geometry.height / 2
                    )
                    .onAppear {
                        if item.initialParentSize == nil {
                            item.initialParentSize = proxy.size
                        }
                    }
                }
            }
        }
        .frame(minWidth: 100, minHeight: 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // Logic for Anchors (AppKit style)
    private func calculateGeometry(for item: StackItem, in currentSize: CGSize) -> (x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let initialX = CGFloat(item.x ?? 0)
        let initialY = CGFloat(item.y ?? 0)
        let initialW = CGFloat(item.itemWidth ?? 100)
        let initialH = CGFloat(item.itemHeight ?? 30)
        
        guard let initialParent = item.initialParentSize, item.resizemask != 0 else {
            return (initialX, initialY, initialW, initialH)
        }
        
        let diffW = currentSize.width - initialParent.width
        let diffH = currentSize.height - initialParent.height
        
        var finalX = initialX
        var finalY = initialY
        var finalW = initialW
        var finalH = initialH
        
        let mask = item.resizemask
        
        // Horizontal
        if (mask & 2) != 0 { // AnchoMovil
            finalW += diffW
        } else if (mask & 1) != 0 { // AnclaRight
            finalX += diffW
        }
        
        // Vertical
        if (mask & 16) != 0 { // AltoMovil
            finalH += diffH
        } else if (mask & 32) != 0 { // AnclaBottom
            finalY += diffH
        }
        
        // Return Train: Notify Harbour if geometry changed significantly
        if finalX != initialX || finalY != initialY || finalW != initialW || finalH != initialH {
             // We use a small optimization here: only sync if it really changed more than 1px
             // to avoid bridge flooding.
             DispatchQueue.main.async {
                 let json = "{\"\(item.id)\":{\"top\":\(Int(finalY)),\"left\":\(Int(finalX)),\"width\":\(Int(finalW)),\"height\":\(Int(finalH))}}"
                 Harbour.call("SW_PIPELINE_SYNC", json)
             }
        }
        
        return (finalX, finalY, finalW, finalH)
    }
}
