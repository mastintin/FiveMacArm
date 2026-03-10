import SwiftUI
import Cocoa
import Observation
import HarbourMacro

struct SwiftListView: View {
    var state: SwiftVStackState
    
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
            ForEach(state.items) { item in
                 RecursiveItemView(item: item, onAction: state.onAction, index: 0, isInsideList: true)
                 .tag(item.id as String?)
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
        content.scrollContentBackground(.hidden)
    }
}

@objc(SwiftListLoader)
public class SwiftListLoader: NSObject {
    
    @objc(makeListWithIndex:)
    public static func makeList(index: String) -> NSView {
         // Reuse SwiftVStackState
         let state = SwiftVStackState()
         
         // Register directly into SwiftVStackLoader's dictionary
         SwiftVStackLoader.states[index] = state
         SwiftVStackLoader.lastCreatedState = state
         
         let view = SwiftListView(state: state)
         
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

    // Legacy support
    @objc(selectIndex:index:)
    public static func selectIndex(_ id: String, index: Int) {
         if let state = SwiftVStackLoader.states[id] as? SwiftVStackState {
             DispatchQueue.main.async {
                 if index > 0 && index <= state.items.count {
                     state.selectedId = state.items[index - 1].id
                 } else {
                     state.selectedId = nil
                 }
             }
         }
    }

    @objc(setBackgroundColorRed:red:green:blue:alpha:)
    public static func setBackgroundColor(rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
         SwiftVStackLoader.setBackgroundColor(rootId: rootId, red: red, green: green, blue: blue, alpha: alpha)
    }
}

@HarbourBridge
public func lst_set_selection(rootId: String, indexStr: String) {
     if let index = Int(indexStr) {
         SwiftListLoader.selectIndex(rootId, index: index)
     }
}

@HarbourBridge
public func lst_set_bgcolor(rootId: String, r: String, g: String, b: String, a: String) {
    if let rd = Double(r), let gr = Double(g), let bl = Double(b), let al = Double(a) {
        SwiftListLoader.setBackgroundColor(rootId: rootId, red: rd, green: gr, blue: bl, alpha: al)
    }
}

@HarbourBridge
public func lst_set_bgcolor_hex(rootId: String, hex: String) {
    SwiftVStackLoader.setBackgroundColorHex(rootId: rootId, hex: hex)
}

@HarbourBridge
public func lst_remove_all(rootId: String) {
    SwiftVStackLoader.removeAllItems(rootId)
}
