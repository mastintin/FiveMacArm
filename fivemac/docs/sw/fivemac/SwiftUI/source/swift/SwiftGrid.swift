import SwiftUI
import Cocoa
import Observation
import HarbourMacro

struct SwiftGridView: View {
    var state: SwiftVStackState
    
    var body: some View {
        Group {
            ScrollView {
                let specs = state.gridColumns ?? []
                LazyVGrid(columns: mapSpecsToGridItems(specs), spacing: CGFloat(state.spacing)) {
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
                if state.useGlassEffect {
                    Color.clear.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 10))
                } else {
                    if state.useInvertedColor {
                        Color.primary.colorInvert()
                    } else {
                        state.backgroundColor
                    }
                }
            }
        )
        .cornerRadius(10)
    }
}

@objc(SwiftGridLoader)
public class SwiftGridLoader: NSObject {
    
    @objc(makeGridWithIndex:columnsJson:)
    public static func makeGrid(id: String, columnsJson: String) -> NSView {
         let finalId = id.isEmpty ? UUID().uuidString : id
         let state = SwiftVStackState()
         
         // Decode Columns
         if let data = columnsJson.data(using: .utf8),
            let specs = try? JSONDecoder().decode([GridItemSpec].self, from: data) {
             state.gridColumns = specs
         }
         
         // Register state in central registry
         ViewRegistry.register(state, for: finalId)
         
         let view = SwiftGridView(state: state)
         ViewRegistry.register(view, for: finalId)

         let hostingView = NSHostingView(rootView: view)
         hostingView.sizingOptions = []
         hostingView.translatesAutoresizingMaskIntoConstraints = false
         hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
         return hostingView
    }

    @objc(setActionCallbackWithRootId:callback:)
    public static func setActionCallback(rootId: String, callback: @escaping (String) -> Void) {
        if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
            state.onAction = callback
        }
    }
}

// --- HARBOUR DIRECT BRIDGES ---

@HarbourDirect
public func swift_grid_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    parentPtr: Int64,
    id: String,
    columnsJson: String
) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        let finalId = id.isEmpty ? UUID().uuidString : id
        
        let gridView = SwiftGridLoader.makeGrid(id: finalId, columnsJson: columnsJson)
        
        let callback: (String) -> Void = { itemId in
             let sendToHarbour = {
                SwiftBridge.onAction(finalId, itemId)
            }
            if Thread.isMainThread {
                sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }
        
        SwiftGridLoader.setActionCallback(rootId: finalId, callback: callback)
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: gridView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(gridView).toOpaque()
            viewAddress = Int64(Int(bitPattern: viewPtr))
        }
        
        return viewAddress
    }

    if Thread.isMainThread {
        return executeCreation()
    } else {
        return DispatchQueue.main.sync {
            return executeCreation()
        }
    }
}
