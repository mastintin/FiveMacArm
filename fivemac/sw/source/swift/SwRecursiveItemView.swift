import SwiftUI
 
 /// A specialized recursive renderer for the Sw (Swift-Native) architecture experiment.
 /// It separates absolute positioning (ZStack) from the standard FiveMac VStack layout.
 public struct SwRecursiveItemView: View {
     @Bindable var item: StackItem
     var width: CGFloat = 0
     var height: CGFloat = 0
     var onAction: ((String) -> Void)? = nil
     var index: Int = 0
     
     @State private var isPressed = false
     
     public var body: some View {
         Group {
             let content = switch item.type {
             case .vstack, .hstack, .zstack:
                 AnyView(renderStack())
             case .list:
                 AnyView(renderList())
             case .button:
                 AnyView(renderButton())
             case .text:
                 AnyView(renderText())
             case .aichat:
                 AnyView(renderAIChat())
             case .toggle:
                 AnyView(renderToggle())
             case .slider:
                 AnyView(renderSlider())
             case .webview:
                 AnyView(renderWebView())
             case .image:
                 AnyView(renderImage())
             case .get:
                 AnyView(renderGet())
             default:
                 AnyView(EmptyView())
             }
             
             if item.hasscroll {
                 ScrollView {
                     content
                 }
                 .modifier(FlexibleFrameModifier(width: width, height: height))
             } else {
                 content
                     .modifier(FlexibleFrameModifier(width: width, height: height))
             }
         }
     }
     
     @ViewBuilder
     private func renderStack() -> some View {
         if let state = ViewRegistry.getState(for: item.id) as? SwiftVStackState {
             if item.type == .vstack {
                 VStack {
                     ForEach(state.items) { subItem in
                         SwRecursiveItemView(item: subItem)
                     }
                 }
                 .contentShape(Rectangle())
                 .conditionalOnTapGesture(item.isInteractive) {
                     sendClick(item.id)
                 }
             } else if item.type == .hstack {
                 HStack {
                     ForEach(state.items) { subItem in
                         SwRecursiveItemView(item: subItem)
                     }
                 }
                 .contentShape(Rectangle())
                 .conditionalOnTapGesture(item.isInteractive) {
                     sendClick(item.id)
                 }
             }
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
                 .conditionalOnTapGesture(item.isInteractive) {
                     sendClick(item.id)
                 }
         }
     }
 
     @ViewBuilder
     private func renderImage() -> some View {
         if let state = ViewRegistry.getState(for: item.id) as? ImageState {
             Group {
                 if !state.urlStr.isEmpty, let url = URL(string: state.urlStr) {
                     AsyncImage(url: url) { image in
                         image.resizable()
                             .aspectRatio(contentMode: state.contentMode == 1 ? .fill : .fit)
                     } placeholder: {
                         ProgressView().controlSize(.small)
                     }
                 } else if !state.filePath.isEmpty {
                     if let nsImg = NSImage(contentsOfFile: state.filePath) {
                         Image(nsImage: nsImg)
                             .resizable()
                             .aspectRatio(contentMode: state.contentMode == 1 ? .fill : .fit)
                     } else {
                         Image(systemName: "exclamationmark.triangle")
                     }
                 } else {
                     Image(systemName: state.systemName.isEmpty ? "photo" : state.systemName)
                         .resizable()
                         .aspectRatio(contentMode: state.contentMode == 1 ? .fill : .fit)
                 }
             }
             .foregroundColor(state.foregroundColor)
             .conditionalOnTapGesture(item.isInteractive) {
                 sendClick(item.id)
             }
         }
     }
     
     @ViewBuilder
     private func renderAIChat() -> some View {
         if let state = ViewRegistry.get(item.id) as? SwiftAIChatState {
             SwiftAIChatView(state: state)
         }
     }
     
     @ViewBuilder
     private func renderToggle() -> some View {
         if let state = ViewRegistry.getState(for: item.id) as? ToggleState {
             SwiftToggleView(state: state)
         }
     }
     
     @ViewBuilder
     private func renderSlider() -> some View {
         if let state = ViewRegistry.getState(for: item.id) as? SliderState {
             SwiftSliderView(state: state)
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
     
     private func sendClick(_ id: String) {
         let json = "{\"\(id)\":{\"event\":\"click\"}}"
         Harbour.call("SW_PIPELINE_SYNC", json)
     }
 }
 
 // MARK: - Conditional Tap Gesture Helper
 extension View {
     @ViewBuilder
     func conditionalOnTapGesture(_ condition: Bool, action: @escaping () -> Void) -> some View {
         if condition {
             self.onTapGesture(perform: action)
         } else {
             self
         }
     }
 }
 
 struct FlexibleFrameModifier: ViewModifier {
     let width: CGFloat
     let height: CGFloat
     
     func body(content: Content) -> some View {
         if width > 0 && height > 0 {
             content.frame(width: width, height: height)
         } else {
             content
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
                             // FILOSOFÍA ISLA: Notificamos el evento como un cambio de estado
                             let json = "{\"\(itemId)\":{\"event\":\"click\"}}"
                             Harbour.call("SW_PIPELINE_SYNC", json)
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
