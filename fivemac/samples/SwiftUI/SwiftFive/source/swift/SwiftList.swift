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
                    if let id = val, let index = state.items.firstIndex(where: { $0.id == id }) {
                        state.onClick?(index + 1)
                    }
                }
            }
        )) {
            ForEach(Array(state.items.enumerated()), id: \.element.id) { index, item in
                 RecursiveItemView(item: item, onClick: { clickedIndex in
                     state.selectedId = item.id
                     state.onClick?(clickedIndex)
                 }, onAction: state.onAction, index: index, remoteIndex: index + 1, selectedIndex: state.selectedIndex)
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
             // Reuse SwiftVStackState as it has the same structure (items, colors, etc)
             let state = SwiftVStackState()
             state.onClick = callback
             
             // Register directly into SwiftVStackLoader's dictionary
             SwiftVStackLoader.states[index] = state
             
             let view = SwiftListView(state: state)
             
             if let intIndex = Int(index) {
                 ViewRegistry.register(view, for: intIndex)
             }

             let hostingView = NSHostingView(rootView: view)
             // hostingView.translatesAutoresizingMaskIntoConstraints = false // Removed to allow setFrame/autoresizingMask
             return hostingView
         } else {
             return NSView()
         }
    }
    @objc(selectIndex:index:)
    public static func selectIndex(_ id: String, index: Int) {
         print("DEBUG: selectIndex called for ID: \(id), Index: \(index)")
         if #available(OSX 10.15, *) {
             if let state = SwiftVStackLoader.states[id] {
                 DispatchQueue.main.async {
                     print("DEBUG: Inside main thread, item count: \(state.items.count)")
                     if index > 0 && index <= state.items.count {
                         let item = state.items[index - 1]
                         state.selectedId = item.id
                         print("DEBUG: Selected item ID: \(item.id)")
                         // Trigger callback to match user expectation of "Selection"
                         state.onClick?(index)
                     } else {
                         print("DEBUG: Index out of bounds or invalid")
                     }
                 }
             } else {
                 print("DEBUG: State not found for ID: \(id)")
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
