import SwiftUI
import Cocoa
import Observation
import HarbourMacro

struct SwiftGridView: View {
    var state: SwiftVStackState
    
    var body: some View {
        Group {
            ScrollView {
                LazyVGrid(columns: mapSpecsToGridItems(state.gridColumns ?? []), spacing: CGFloat(state.spacing)) {
                    ForEach(0..<state.items.count, id: \.self) { index in
                         let item = state.items[index]
                         RecursiveItemView(item: item, onAction: state.onAction, index: index)
                    }
                }
                .padding()
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

@HarbourBridge
@objc(SwiftGridLoader)
public class SwiftGridLoader: NSObject {
    
    @objc(makeGridWithIndex:columnsJson:)
    public static func makeGrid(index: String, columnsJson: String) -> NSView {
         let state = SwiftVStackState()
         
         // Decode Columns
         if let data = columnsJson.data(using: .utf8),
            let specs = try? JSONDecoder().decode([GridItemSpec].self, from: data) {
             state.gridColumns = specs
         }
         
         SwiftVStackLoader.lastCreatedState = state 
         
         // Register state for addItem/addBatch lookups
         SwiftVStackLoader.states[index] = state
         
         let view = SwiftGridView(state: state)
         
         if let intIndex = Int(index) {
             ViewRegistry.register(view, for: intIndex)
         }

         let hostingView = NSHostingView(rootView: view)
         return hostingView
    }

    @objc(setActionCallbackWithRootId:callback:)
    public static func setActionCallback(rootId: String, callback: @escaping (String) -> Void) {
        if let state = SwiftVStackLoader.states[rootId] as? SwiftVStackState {
            state.onAction = callback
        }
    }
}
