import SwiftUI
import Cocoa

@available(OSX 10.15, *)
struct SwiftGridView: View {
    @ObservedObject var state: SwiftVStackState
    
    var body: some View {
        Group {
            if #available(OSX 11.0, *) {
                ScrollView {
                    LazyVGrid(columns: mapSpecsToGridItems(state.gridColumns ?? []), spacing: CGFloat(state.spacing)) {
                        ForEach(Array(state.items.enumerated()), id: \.element.id) { index, item in
                             RecursiveItemView(item: item, onClick: state.onClick, onAction: state.onAction, index: index)
                        }
                    }
                    .padding()
                }
            } else {
                Text("Grid requires macOS 11.0+")
            }
        }
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

@objc(SwiftGridLoader)
public class SwiftGridLoader: NSObject {
    
    @objc(makeGridWithIndex:columnsJson:callback:actionCallback:)
    public static func makeGrid(index: Int, columnsJson: String, callback: @escaping (Int) -> Void, actionCallback: @escaping (String) -> Void) -> NSView {
         if #available(OSX 10.15, *) {
             print("SWIFT_PRINT: makeGrid called. Index: \(index)")
             let state = SwiftVStackState()
             state.onClick = callback
             state.onAction = actionCallback
             
             // Decode Columns
             if let data = columnsJson.data(using: .utf8),
                let specs = try? JSONDecoder().decode([GridItemSpec].self, from: data) {
                 state.gridColumns = specs
             }
             
             SwiftVStackLoader.lastCreatedState = state 
             
             let view = SwiftGridView(state: state)
             
             ViewRegistry.register(view, for: index)

             let hostingView = NSHostingView(rootView: view)
             return hostingView
         } else {
             return NSView()
         }
    }
}
