import SwiftUI
import AppKit

/// Componente universal de renderizado recursivo
public struct SwRecursiveItemView: View {
    let item: StackItem
    let width: CGFloat
    let height: CGFloat
    
    public init(item: StackItem, width: CGFloat = 0, height: CGFloat = 0) {
        self.item = item
        self.width = width
        self.height = height
    }
    
    public var body: some View {
        let finalWidth = width > 0 ? width : CGFloat(item.itemWidth ?? 0)
        let finalHeight = height > 0 ? height : CGFloat(item.itemHeight ?? 0)
        
        Group {
            let content: AnyView = switch item.type {
            case .vstack, .hstack, .zstack:
                AnyView(renderStack())
            case .list:
                AnyView(renderList())
            case .button:
                AnyView(renderButton())
            case .text:
                AnyView(renderText())
            case .image:
                AnyView(renderImage())
            case .webview:
                AnyView(renderWebView())
            case .get:
                AnyView(renderGet())
            case .slider:
                AnyView(renderSlider())
            case .toggle:
                AnyView(renderToggle())
            case .progress:
                AnyView(renderProgress())
            default:
                AnyView(EmptyView())
            }
            
            content
                .modifier(FlexibleFrameModifier(width: finalWidth, height: finalHeight))
        }
    }
    
    @ViewBuilder
    private func renderStack() -> some View {
        if let state = ViewRegistry.getState(for: item.id) as? SwiftVStackState {
            SwStackContent(state: state, type: item.type)
        }
    }

    @ViewBuilder
    private func renderList() -> some View {
        if let state = ViewRegistry.getState(for: item.id) as? ListState {
            SwiftListView(state: state)
        }
    }
    
    @ViewBuilder
    private func renderButton() -> some View {
        if let state = ViewRegistry.getState(for: item.id) as? ButtonState {
            SwiftButtonView(state: state)
        }
    }
    
    @ViewBuilder
    private func renderText() -> some View {
        if let state = ViewRegistry.getState(for: item.id) as? LabelState {
            Text(state.text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func renderImage() -> some View {
        if let state = ViewRegistry.getState(for: item.id) as? ImageState {
            SwiftImageView(state: state)
        }
    }
    
    @ViewBuilder
    private func renderWebView() -> some View {
        if let state = ViewRegistry.getState(for: item.id) as? WebViewState {
            SwiftWebView(state: state)
        }
    }
    
    @ViewBuilder
    private func renderGet() -> some View {
        if let state = ViewRegistry.getState(for: item.id) as? GetState {
            SwiftGetView(state: state)
        }
    }

    @ViewBuilder
    private func renderSlider() -> some View {
        if let state = ViewRegistry.getState(for: item.id) as? SliderState {
            SwiftSliderView(state: state)
        }
    }

    @ViewBuilder
    private func renderToggle() -> some View {
        if let state = ViewRegistry.getState(for: item.id) as? ToggleState {
            SwiftToggleView(state: state)
        }
    }

    @ViewBuilder
    private func renderProgress() -> some View {
        if let state = ViewRegistry.getState(for: item.id) as? ProgressState {
            SwiftProgressView(state: state)
        }
    }
}

/// Motor de observación reactiva para Stacks
struct SwStackContent: View {
    var state: SwiftVStackState
    let type: StackItem.ItemType
    
    var body: some View {
        let content = ForEach(state.items) { subItem in
            SwRecursiveItemView(item: subItem)
        }
        
        Group {
            if type == .vstack {
                VStack(spacing: 0) { content }
            } else if type == .hstack {
                HStack(spacing: 0) { content }
            } else {
                ZStack { content }
            }
        }
    }
}

struct FlexibleFrameModifier: ViewModifier {
    let width: CGFloat
    let height: CGFloat
    
    func body(content: Content) -> some View {
        if width > 0 && height > 0 {
            content.frame(width: width, height: height)
        } else if width > 0 {
            content.frame(width: width)
        } else if height > 0 {
            content.frame(height: height)
        } else {
            content
        }
    }
}

/// Vista Especializada para SwWindow
public struct SwWindowView: View {
    var state: SwiftWindowState
    let id: String
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            Color(NSColor.windowBackgroundColor)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { proxy in
                ZStack(alignment: .topLeading) {
                    ForEach(state.items) { item in
                        let geometry = calculateGeometry(for: item, in: proxy.size)
                        
                        SwRecursiveItemView(
                            item: item, 
                            width: geometry.width,
                            height: geometry.height
                        )
                        .position(
                            x: geometry.x + geometry.width / 2,
                            y: geometry.y + geometry.height / 2
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .disabled(!state.isInteractive)
        .onAppear {
            print("🏝️ [Swift-Window] onAppear detectado para \(id). Programando evento 'init'...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let json = "{\"\(id)\":{\"event\":\"init\"}}"
                Harbour.call("SW_PIPELINE_SYNC", json)
            }
        }
    }
    
    private func calculateGeometry(for item: StackItem, in currentSize: CGSize) -> (x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let initialX = CGFloat(item.x ?? 0)
        let initialY = CGFloat(item.y ?? 0)
        let initialW = CGFloat(item.itemWidth ?? 100)
        let initialH = CGFloat(item.itemHeight ?? 30)
        
        if let initialParent = item.initialParentSize, item.resizemask != 0 {
            let diffW = currentSize.width - initialParent.width
            let diffH = currentSize.height - initialParent.height
            
            var finalX = initialX
            var finalY = initialY
            var finalW = initialW
            var finalH = initialH
            
            let mask = item.resizemask
            if (mask & 2) != 0 { finalW += diffW } 
            else if (mask & 1) != 0 { finalX += diffW }
            if (mask & 16) != 0 { finalH += diffH } 
            else if (mask & 32) != 0 { finalY += diffH }
            
            return (finalX, finalY, finalW, finalH)
        }
        return (initialX, initialY, initialW, initialH)
    }
}
