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
        renderContent()
    }
    
    @ViewBuilder
    private func renderContent() -> some View {
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
            case .spacer:
                AnyView(Spacer())
            case .divider:
                AnyView(Divider())
            case .datepicker:
                AnyView(renderDatePicker())
            case .grid:
                AnyView(renderGrid())
            case .picker:
                AnyView(renderPicker())
            case .card:
                AnyView(renderCard())
            case .panel:
                AnyView(renderPanel())
            case .sidebar:
                AnyView(renderSidebar())
            case .sidebaritem:
                AnyView(renderSidebarItem())
            case .tabview:
                if let state = ViewRegistry.getState(for: item.id) as? SwiftTabViewState {
                    AnyView(SwiftTabView(state: state))
                } else {
                    AnyView(EmptyView())
                }
            case .menu:
                AnyView(renderMenu())
            case .menuitem:
                AnyView(renderMenuItem())
            case .browse:
                if let state = ViewRegistry.getState(for: item.id) as? BrowseState {
                    AnyView(SwiftBrowseView(state: state))
                } else {
                    AnyView(EmptyView())
                }
            case .quicklook:
                AnyView(renderQuickLook())
            case .map:
                AnyView(renderMap())
            case .stepper:
                AnyView(renderStepper())
            case .colorpicker:
                AnyView(renderColorPicker())
            case .gauge:
                AnyView(renderGauge())
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
        if let buttonState = ViewRegistry.get(item.id) as? SwiftButtonState {
            SwiftButtonView(state: buttonState)
        }
    }
    
    @ViewBuilder
    private func renderText() -> some View {
        if let labelState = ViewRegistry.get(item.id) as? SwiftLabelState {
            SwiftLabelView(state: labelState)
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
        if let state = ViewRegistry.getState(for: item.id) as? SwiftGetState {
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
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? ProgressState {
                SwiftProgressView(state: state)
            } else { EmptyView() }
        }
    }
    
    private func renderDatePicker() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? DatePickerState {
                SwiftDatePickerView(state: state)
            } else { EmptyView() }
        }
    }

    private func renderGrid() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? GridState {
                SwiftGridView(state: state)
            } else { EmptyView() }
        }
    }

    private func renderPicker() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? SwiftPickerState {
                SwiftPickerView(state: state)
            } else { EmptyView() }
        }
    }

    private func renderCard() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? SwiftCardState {
                SwiftCardView(state: state)
            } else { EmptyView() }
        }
    }

    private func renderPanel() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? SwiftPanelState {
                SwiftPanelView(state: state)
            } else { EmptyView() }
        }
    }

    private func renderSidebar() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? SwiftSidebarState {
                SwSidebarView(state: state)
            } else { EmptyView() }
        }
    }

    private func renderSidebarItem() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? SwiftSidebarItemState {
                SwSidebarItemView(state: state)
            } else { EmptyView() }
        }
    }

    private func renderMenu() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? SwiftMenuState {
                SwiftMenuView(state: state)
            } else { EmptyView() }
        }
    }

    private func renderMenuItem() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? SwiftMenuItemState {
                SwiftMenuItemView(state: state)
            } else { EmptyView() }
        }
    }

    private func renderQuickLook() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? SwiftQuickLookState {
                SwiftQuickLookView(state: state)
            } else { EmptyView() }
        }
    }

    private func renderMap() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? SwiftMapState {
                SwiftMapView(state: state)
            } else { EmptyView() }
        }
    }

    private func renderStepper() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? StepperState {
                SwiftStepperView(state: state)
            } else { EmptyView() }
        }
    }

    private func renderColorPicker() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? ColorPickerState {
                SwiftColorPickerView(state: state)
            } else { EmptyView() }
        }
    }

    private func renderGauge() -> some View {
        Group {
            if let state = ViewRegistry.getState(for: item.id) as? GaugeState {
                SwiftGaugeView(state: state)
            } else { EmptyView() }
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
                let align: HorizontalAlignment = {
                    switch state.alignment {
                    case 1: return .leading
                    case 2: return .trailing
                    default: return .center
                    }
                }()
                VStack(alignment: align, spacing: state.spacing) { content }
            } else if type == .hstack {
                let align: VerticalAlignment = {
                    switch state.alignment {
                    case 1: return .top
                    case 2: return .bottom
                    default: return .center
                    }
                }()
                HStack(alignment: align, spacing: state.spacing) { content }
            } else {
                let align: Alignment = {
                    switch state.alignment {
                    case 1: return .topLeading
                    case 2: return .top
                    case 3: return .topTrailing
                    case 4: return .leading
                    case 5: return .trailing
                    case 6: return .bottomLeading
                    case 7: return .bottom
                    case 8: return .bottomTrailing
                    default: return .center
                    }
                }()
                ZStack(alignment: align) { content }
            }
        }
        .background(state.backgroundColor ?? AnyShapeStyle(Color.clear))
        .cornerRadius(state.cornerRadius)
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
        mainContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .disabled(!state.isInteractive)
            .onAppear {
            print("🏝️ [Swift-Window] onAppear detectado para \(id).")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let json = "{\"\(id)\":{\"event\":\"init\"}}"
                Harbour.call("SW_UPDATE_HB", json)
            }
        }
    }
    
    @ViewBuilder
    private var sidebarContent: some View {
        let sidebars = state.items.filter { $0.type == .sidebar }
        ZStack {
            ForEach(sidebars) { item in
                SwRecursiveItemView(item: item)
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        let details = state.items
        
        ZStack(alignment: .topLeading) {
            if let bg = state.backgroundColor {
                Rectangle().fill(bg)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color(NSColor.windowBackgroundColor)
                    .edgesIgnoringSafeArea(.all)
            }
            
            GeometryReader { proxy in
                ZStack(alignment: .topLeading) {
                    ForEach(details) { item in
                        let geometry = calculateGeometry(for: item, in: proxy.size)
                        SwRecursiveItemView(
                            item: item, 
                            width: geometry.width,
                            height: geometry.height
                        )
                        .offset(x: geometry.x, y: geometry.y)
                    }
                }
            }
        }
    }
    
    private func calculateGeometry(for item: StackItem, in currentSize: CGSize) -> (x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let initialX = CGFloat(item.x ?? 0)
        let initialY = CGFloat(item.y ?? 0)
        let initialW = CGFloat(item.itemWidth ?? 100)
        let initialH = CGFloat(item.itemHeight ?? 30)
        let mask = item.resizemask
        if mask == 0 { return (initialX, initialY, initialW, initialH) }
        let parentW = (item.initialParentSize?.width ?? 0) > 10 ? item.initialParentSize!.width : 800
        let parentH = (item.initialParentSize?.height ?? 0) > 10 ? item.initialParentSize!.height : 600
        let diffW = currentSize.width - parentW
        let diffH = currentSize.height - parentH
        var finalX = initialX
        var finalY = initialY
        var finalW = initialW
        var finalH = initialH
        if (mask & 2) != 0 { finalW += diffW } else if (mask & 1) != 0 { finalX += diffW }
        if (mask & 16) != 0 { finalH += diffH } else if (mask & 32) != 0 { finalY += diffH }
        return (finalX, finalY, finalW, finalH)
    }
}
