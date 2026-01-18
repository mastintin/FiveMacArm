import SwiftUI
import Cocoa

@available(OSX 10.15, *)
struct SwiftListView: View {
    @ObservedObject var state: SwiftVStackState
    
    var body: some View {
        List {
            ForEach(Array(state.items.enumerated()), id: \.element.id) { index, item in
                 RecursiveItemView(item: item, onClick: state.onClick, onAction: state.onAction, index: index)
            }
        }
        .buttonStyle(PlainButtonStyle()) // Fix for Buttons in Lists
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
        .cornerRadius(10)
    }
}

@objc(SwiftListLoader)
public class SwiftListLoader: NSObject {
    
    @objc(makeListWithIndex:callback:)
    public static func makeList(index: Int, callback: @escaping (Int) -> Void) -> NSView {
         if #available(OSX 10.15, *) {
             // Reuse SwiftVStackState as it has the same structure (items, colors, etc)
             let state = SwiftVStackState()
             state.onClick = callback
             // Reset global state to this new list state so subsequent addItems work
             SwiftVStackLoader.lastCreatedState = state 
             
             let view = SwiftListView(state: state)
             
             ViewRegistry.register(view, for: index)

             let hostingView = NSHostingView(rootView: view)
             return hostingView
         } else {
             return NSView()
         }
    }
}
