import SwiftUI
import Cocoa

@available(OSX 10.15, *)
struct SwiftListView: View {
    @ObservedObject var state: SwiftVStackState
    
    var body: some View {
        List(selection: Binding<String?>(
            get: { state.selectedId },
            set: { val in
                if val != state.selectedId {
                    state.selectedId = val
                    if let id = val {
                        state.onAction?(id)
                    }
                }
            }
        )) {
            ForEach(Array(state.items.enumerated()), id: \.element.id) { index, item in
                 RecursiveItemView(item: item, onAction: state.onAction, index: index, remoteIndex: index + 1, selectedIndex: state.selectedIndex, isInsideList: true)
                 .tag(item.id)
                 .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Group {
                if state.useInvertedColor {
                    Color.primary.colorInvert().opacity(state.alpha)
                } else {
                    Color(red: state.red, green: state.green, blue: state.blue, opacity: state.alpha)
                }
            }
        )
        .modifier(ListBackgroundModifier())
    }
}

struct ListBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(OSX 13.0, *) {
            content.scrollContentBackground(.hidden)
        } else {
            content
        }
    }
}

@objc(SwiftListLoader)
public class SwiftListLoader: NSObject {
    
    @objc(makeListWithIndex:callback:)
    public static func makeList(index: String, callback: @escaping (Int) -> Void) -> NSView {
         if #available(OSX 10.15, *) {
             // Reuse SwiftVStackState
             let state = SwiftVStackState()
             
             // Register directly into SwiftVStackLoader's dictionary
             SwiftVStackLoader.states[index] = state
             
             let view = SwiftListView(state: state)
             
             if let intIndex = Int(index) {
                 ViewRegistry.register(view, for: intIndex)
             }

             let hostingView = NSHostingView(rootView: view)
             return hostingView
         } else {
             return NSView()
         }
    }
    
    @objc(selectIndex:index:)
    public static func selectIndex(_ id: String, index: Int) {
         if #available(OSX 10.15, *) {
             if let state = SwiftVStackLoader.states[id] {
                 DispatchQueue.main.async {
                     if index > 0 && index <= state.items.count {
                         let item = state.items[index - 1]
                         state.selectedId = item.id
                         state.onAction?(item.id)
                     }
                 }
             }
         }
    }

    @objc(setBackgroundColorRed:red:green:blue:alpha:)
    public static func setBackgroundColor(rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
         if #available(OSX 10.15, *) {
             DispatchQueue.main.async {
                 if let state = SwiftVStackLoader.states[rootId] {
                     state.red = red
                     state.green = green
                     state.blue = blue
                     state.alpha = alpha
                     state.objectWillChange.send()
                 }
             }
         }
    }
}
