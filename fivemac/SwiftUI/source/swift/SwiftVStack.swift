import SwiftUI
import Cocoa
import Observation
import HarbourMacro



@Observable
public class SwiftVStackState: StackStateProtocol {
    public var items: [StackItem] = []
    public var scrollable: Bool = false
    public var red: Double = 0.5
    public var green: Double = 0.5
    public var blue: Double = 0.5
    public var alpha: Double = 0.5
    public var useInvertedColor: Bool = false
    public var fgRed: Double = 0.0
    public var fgGreen: Double = 0.0
    public var fgBlue: Double = 0.0
    public var fgAlpha: Double = 1.0
    public var spacing: Double = 12.0
    public var alignment: Int = 0
    public var lastItem: StackItem? = nil
    
    public var gridColumns: [GridItemSpec]? = nil
    public var onAction: ((String) -> Void)?
    
    public var selectedIndex: Int? = nil
    public var selectedId: String? = nil

    public init() {}
}



struct SwiftVStackView: View {
    var state: SwiftVStackState
    var rootId: String

    var body: some View {
        Group {
            if state.scrollable {
                ScrollView {
                    content
                }
            } else {
                content
            }
        }
        .modify { view in
            if #available(macOS 26.0, *) {
                view.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 8))
            } else {
                view
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
        .foregroundColor(
            Color(red: state.fgRed, green: state.fgGreen, blue: state.fgBlue, opacity: state.fgAlpha)
        )
        .onAppear {
            SwiftBridge.onAppear(rootId)
        }
        .onDisappear {
            SwiftBridge.onDisappear(rootId)
        }
    }

    var content: some View {
        let align: HorizontalAlignment
        switch state.alignment {
        case 1: align = .leading
        case 2: align = .trailing
        default: align = .center
        }

        return VStack(alignment: align, spacing: CGFloat(state.spacing)) {
            ForEach(0..<state.items.count, id: \.self) { index in
                 let item = state.items[index]
                 RecursiveItemView(item: item, onAction: state.onAction, index: index)
            }
        }
        .padding()
        // Forces the VStack to fill the available width, responding to alignment
        .frame(maxWidth: .infinity, alignment: Alignment(horizontal: align, vertical: .center))
    }
}

@objc(SwiftVStackLoader)
public class SwiftVStackLoader: NSObject {

    // Dictionary to store states by ID - now using shared registry
    static var states: [String: StackStateProtocol] {
        get { SwiftStackRegistry.sharedStates }
        set { SwiftStackRegistry.sharedStates = newValue }
    }

    // Legacy support
    public static var lastCreatedState: Any? = nil
    static weak var lastCreatedItem: StackItem? = nil

    @objc(makeVStackWithIndex:)
    public static func makeVStack(id: String) -> NSView {
         let finalId = id.isEmpty ? UUID().uuidString : id
         let state = SwiftVStackState()
         
         // Register in dictionary
         states[finalId] = state 
         SwiftStackRegistry.sharedStates[finalId] = state 
         
         // Restore legacy global state for compatibility
         lastCreatedState = state
         lastCreatedItem = nil

         let view = SwiftVStackView(state: state, rootId: finalId)
         ViewRegistry.register(view, for: finalId)

         let hostingView = NSHostingView(rootView: view)
         hostingView.sizingOptions = []
         hostingView.translatesAutoresizingMaskIntoConstraints = false
         hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
         return hostingView
    }

    // --- NEW METHODS (With RootID) ---

    @objc(setActionCallbackWithRootId:callback:)
    public static func setActionCallback(rootId: String, callback: @escaping (String) -> Void) {
        if let state = SwiftStackRegistry.sharedStates[rootId] {
            state.onAction = callback
        }
    }

    @objc(removeAllItems:)
    public static func removeAllItems(_ rootId: String) {
        let block = {
            if let state = SwiftStackRegistry.sharedStates[rootId] {
                state.items.removeAll()
                state.lastItem = nil
            }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
    }

    @objc(addItem:content:)
    @discardableResult
    public static func addItem(_ rootId: String, content: String) -> String {
        var newItemId = ""
        let block = {
                if let state = SwiftStackRegistry.sharedStates[rootId] {
                    let newItem = StackItem(type: .text, content: content)
                    newItemId = newItem.id
                    state.items.append(newItem)
                    state.lastItem = newItem
                }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }
    
     @objc(addTextItem:content:parentId:)
     @discardableResult
     public static func addTextItem(_ rootId: String, content: String, parentId: String?) -> String {
         var newItemId = ""
         let block = {
                if let state = SwiftStackRegistry.sharedStates[rootId] {
                    let newItem = StackItem(type: .text, content: content)
                    newItemId = newItem.id
                    
                    if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                        parent.children.append(newItem)
                    } else {
                        state.items.append(newItem)
                    }
                    
                    state.lastItem = newItem
                }
         }
         if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
         return newItemId
     }
  
     @objc(addSpacerItem:parentId:)
     @discardableResult
     public static func addSpacerItem(_ rootId: String, parentId: String?) -> String {
         var newItemId = ""
         let block = {
                if let state = SwiftStackRegistry.sharedStates[rootId] {
                    let newItem = StackItem(type: .spacer, content: "")
                    newItemId = newItem.id
                    
                    if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                        parent.children.append(newItem)
                    } else {
                        state.items.append(newItem)
                    }
                    
                    state.lastItem = newItem
                }
         }
         if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
         return newItemId
     }
  
     @objc(addSystemImage:systemName:)
     @discardableResult
     public static func addSystemImage(_ rootId: String, systemName: String) -> String {
         return addSystemImageItem(rootId, systemName: systemName, parentId: nil)
     }
  
     @objc(addSystemImageItem:systemName:parentId:)
     @discardableResult
     public static func addSystemImageItem(_ rootId: String, systemName: String, parentId: String?) -> String {
         var newItemId = ""
         let block = {
             let newItem = StackItem(type: .systemImage, content: systemName, secondaryContent: nil)
             newItemId = newItem.id
             
                if let state = SwiftStackRegistry.sharedStates[rootId] {
                     if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                         parent.children.append(newItem)
                     } else {
                         state.items.append(newItem)
                     }
                     state.lastItem = newItem
                }
         }
         if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
         return newItemId
     }
 
    @objc(addHStackItem:text:systemName:)
    @discardableResult
    public static func addHStackItem(_ rootId: String, text: String, systemName: String) -> String {
        var newItemId = ""
        let block = {
                if let state = SwiftStackRegistry.sharedStates[rootId] {
                    let newItem = StackItem(type: .hstack, content: text, secondaryContent: systemName)
                    newItemId = newItem.id
                    state.items.append(newItem)
                    state.lastItem = newItem
                }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }

    @objc(setScrollable:scrollable:)
    public static func setScrollable(_ rootId: String, scrollable: Bool) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftVStackState {
                state.scrollable = scrollable
            }
        }
    }

    @objc(setBackgroundColorRed:red:green:blue:alpha:)
    public static func setBackgroundColor(rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
         DispatchQueue.main.async {
              if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftVStackState {
                  state.red = red
                  state.green = green
                  state.blue = blue
                  state.alpha = alpha
              }
         }
    }
    
    @objc(setForegroundColorRed:red:green:blue:alpha:)
    public static func setForegroundColor(rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
         DispatchQueue.main.async {
             if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftVStackState {
                 state.fgRed = red
                 state.fgGreen = green
                 state.fgBlue = blue
                 state.fgAlpha = alpha
             }
         }
    }

    @objc(setSpacing:spacing:)
    public static func setSpacing(_ rootId: String, spacing: Double) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftVStackState {
                state.spacing = spacing
            }
        }
    }

    @objc(setAlignment:alignment:)
    public static func setAlignment(_ rootId: String, alignment: Int) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftVStackState {
                state.alignment = alignment
            }
        }
    }

    @objc(setInvertedColor:useInverted:)
    public static func setInvertedColor(_ rootId: String, useInverted: Bool) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftVStackState {
                state.useInvertedColor = useInverted
            }
        }
    }

    @objc(setBackgroundColorHex:hex:)
    public static func setBackgroundColorHex(rootId: String, hex: String) {
        let color = Color(hex: hex)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        NSColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        setBackgroundColor(rootId: rootId, red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
    }

    @objc(setForegroundColorHex:hex:)
    public static func setForegroundColorHex(rootId: String, hex: String) {
        let color = Color(hex: hex)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        NSColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        setForegroundColor(rootId: rootId, red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
    }
    
    @objc(setLastItemId:id:)
    public static func setLastItemId(_ rootId: String, id: String) {
         DispatchQueue.main.async {
             if let state = SwiftStackRegistry.sharedStates[rootId], let item = state.lastItem {
                 item.id = id
             }
         }
    }

    @objc(getLastItemId:)
    public static func getLastItemId(_ rootId: String) -> String {
        var result = ""
        let block = {
             if let state = SwiftStackRegistry.sharedStates[rootId], let item = state.lastItem {
                 result = item.id
             }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return result
    }

    // Recursive Find
    private static func findItem(id: String, in items: [StackItem]) -> StackItem? {
        for item in items {
            if item.id == id {
                return item
            }
            if let found = findItem(id: id, in: item.children) {
                return found
            }
        }
        return nil
    }

    @objc(addStackItem:dummy:parentId:)
    @discardableResult
    public static func addStackItem(_ rootId: String, dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .vstack, content: "")
             newItemId = newItem.id
             
             if let state = SwiftStackRegistry.sharedStates[rootId] {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }

    @objc(addHStackContainer:dummy:parentId:)
    @discardableResult
    public static func addHStackContainer(_ rootId: String, dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .hstackContainer, content: "")
             newItemId = newItem.id
             
             if let state = SwiftStackRegistry.sharedStates[rootId] {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      print("DEBUG: [Swift] Adding HStackContainer to parent \(pId)")
                      parent.children.append(newItem)
                  } else {
                      // print("DEBUG: [Swift] Adding HStackContainer to ROOT")
                      state.items.append(newItem)
                  }
             }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }

    @objc(addLazyVGrid:parentId:columnsJson:)
    @discardableResult
    public static func addLazyVGrid(_ rootId: String, parentId: String?, columnsJson: String) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .lazyVGrid, content: "")
             // Decode Columns
             if let data = columnsJson.data(using: .utf8),
                let specs = try? JSONDecoder().decode([GridItemSpec].self, from: data) {
                 newItem.gridColumns = specs
             }
             newItemId = newItem.id

             if let state = SwiftStackRegistry.sharedStates[rootId] {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }

        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }

    @objc(addList:dummy:parentId:)
    @discardableResult
    public static func addList(_ rootId: String, dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .list, content: "")
             newItemId = newItem.id
             
             if let state = SwiftStackRegistry.sharedStates[rootId] {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }
        
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }

    @objc(addTextItem:text:parentId:)
    @discardableResult
    public static func addTextItem(_ rootId: String, text: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .text, content: text)
             newItemId = newItem.id
             
             if let state = SwiftStackRegistry.sharedStates[rootId] {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }
        
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }
    
    @objc(addSpacer:dummy:parentId:)
    @discardableResult
    public static func addSpacer(_ rootId: String, dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .spacer, content: "")
             newItemId = newItem.id
             if let state = SwiftStackRegistry.sharedStates[rootId] {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }

    @objc(addDivider:dummy:parentId:)
    @discardableResult
    public static func addDivider(_ rootId: String, dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .divider, content: "")
             newItemId = newItem.id
             if let state = SwiftStackRegistry.sharedStates[rootId] {
                 state.lastItem = newItem
                 if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                     parent.children.append(newItem)
                 } else {
                     state.items.append(newItem)
                 }
             }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }

    @objc(addButtonItem:text:parentId:)
    @discardableResult
    public static func addButtonItem(_ rootId: String, text: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .button, content: text)
             newItemId = newItem.id
             
             if let state = SwiftStackRegistry.sharedStates[rootId] {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }

        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }

    @objc(setItemText:id:text:)
    public static func setItemText(_ rootId: String, id: String, text: String) {
         DispatchQueue.main.async {
             if let state = SwiftStackRegistry.sharedStates[rootId], let item = findItem(id: id, in: state.items) {
                 item.content = text
             }
         }
    }

    @objc(setItem:id:red:green:blue:alpha:)
    public static func setItemBackgroundColor(rootId: String, id: String, red: Double, green: Double, blue: Double, alpha: Double) {
         DispatchQueue.main.async {
             if let state = SwiftStackRegistry.sharedStates[rootId] {
                 if let item = findItem(id: id, in: state.items) {
                     item.bgColor = (red, green, blue, alpha)
                 }
             }
         }
    }

    @objc(setItemLayout:id:w:h:s:)
    public static func setItemLayout(rootId: String, id: String, w: Double, h: Double, s: Double) {
         DispatchQueue.main.async {
             if let state = SwiftStackRegistry.sharedStates[rootId], let item = findItem(id: id, in: state.items) {
                 if w > 0 { item.itemWidth = w }
                 if h > 0 { item.itemHeight = h }
                 if s >= 0 { item.spacing = s }
             }
         }
    }

    @objc(addBatch:parentId:json:)
    @discardableResult
    public static func addBatch(_ rootId: String, parentId: String?, json: String) -> String {
        
        struct BatchInput: Codable {
            let type: Int
            let content: String
            let secondaryContent: String?
            let bg: ColorRGBA?
            let fg: ColorRGBA?
        }
        
        let decoder = JSONDecoder()
        guard let data = json.data(using: .utf8),
              let batchItems = try? decoder.decode([BatchInput].self, from: data) else {
            return "[]"
        }
        
        var newIds: [String] = []
        
        let block = {
            guard let state = SwiftStackRegistry.sharedStates[rootId] else { return }
            
            let parentItem = (parentId != nil) ? findItem(id: parentId!, in: state.items) : nil
            
            for itemIn in batchItems {
                let newItemType = StackItem.ItemType(rawValue: itemIn.type) ?? .text
                let newItem = StackItem(type: newItemType, content: itemIn.content, secondaryContent: itemIn.secondaryContent)
                
                // Color mapping
                if let bg = itemIn.bg { newItem.bgColor = (bg.r, bg.g, bg.b, bg.a) }
                if let fg = itemIn.fg { newItem.fgColor = (fg.r, fg.g, fg.b, fg.a) }
                
                newIds.append(newItem.id)
                state.lastItem = newItem 
                
                if let p = parentItem {
                    p.children.append(newItem) 
                } else {
                    state.items.append(newItem)
                }
            }
        }
        
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync { block() }
        }
        
        if let encoded = try? JSONEncoder().encode(newIds), let jsonString = String(data: encoded, encoding: .utf8) {
            return jsonString
        }
        return "[]"
    }

    // --- LEGACY METHODS Support (Compatible with SwiftGrid, SwiftZStack) ---

    @objc(setActionCallback:)
    public static func setActionCallback(callback: @escaping (String) -> Void) {
         if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
             state.onAction = callback
         }
    }

    @objc(addItem:)
    public static func addItem(_ text: String) {
        DispatchQueue.main.async {
            if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                state.items.append(StackItem(type: .text, content: text, secondaryContent: nil))
            }
        }
    }

    @objc(addSystemImage:)
    public static func addSystemImageLegacy(_ systemName: String) {
        addSystemImageItemLegacy(systemName, parentId: nil)
    }

    @objc(addSystemImageItem:parentId:)
    public static func addSystemImageItemLegacy(_ systemName: String, parentId: String?) {
        DispatchQueue.main.async {
            let newItem = StackItem(type: .systemImage, content: systemName, secondaryContent: nil)
            
            if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                 if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                     parent.children.append(newItem)
                 } else {
                     state.items.append(newItem)
                 }
            }
        }
    }

    @objc(addHStackItem:systemName:)
    public static func addHStackItemLegacy(_ text: String, systemName: String) {
        DispatchQueue.main.async {
            if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                let newItem = StackItem(type: .hstack, content: text, secondaryContent: systemName)
                state.items.append(newItem)
                lastCreatedItem = newItem
            }
        }
    }

    @objc(setScrollable:)
    public static func setScrollableLegacy(_ scrollable: Bool) {
        DispatchQueue.main.async {
            if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                state.scrollable = scrollable
            }
        }
    }

    @objc(setBackgroundColorRed:green:blue:alpha:)
    public static func setBackgroundColorLegacy(red: Double, green: Double, blue: Double, alpha: Double) {
         DispatchQueue.main.async {
              // If we have a last item, set ITS background color
              if let item = lastCreatedItem {
                  item.bgColor = (r: red, g: green, b: blue, a: alpha)
              } 
         }
    }

    @objc(setSpacing:)
    public static func setSpacingLegacy(_ spacing: Double) {
        DispatchQueue.main.async {
            if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                state.spacing = spacing
            }
        }
    }

    @objc(setAlignment:)
    public static func setAlignmentLegacy(_ alignment: Int) {
        DispatchQueue.main.async {
            if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                state.alignment = alignment
            }
        }
    }

    @objc(setInvertedColor:)
    public static func setInvertedColorLegacy(_ useInverted: Bool) {
        DispatchQueue.main.async {
            if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                state.useInvertedColor = useInverted
            }
        }
    }
    
    @objc(setLastItemId:)
    public static func setLastItemIdLegacy(_ id: String) {
         DispatchQueue.main.async {
             if let item = lastCreatedItem {
                 item.id = id
             }
         }
    }

    @objc(addStackItem:parentId:)
    public static func addStackItemLegacy(_ dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .vstack, content: "")
             newItemId = newItem.id
             lastCreatedItem = newItem

             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }

        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
        return newItemId
    }

    @objc(addHStackContainer:parentId:)
    public static func addHStackContainerLegacy(_ dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .hstackContainer, content: "")
             newItemId = newItem.id
             lastCreatedItem = newItem

             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }

        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
        return newItemId
    }

    @objc(addLazyVGrid:columnsJson:)
    public static func addLazyVGridLegacy(parentId: String?, columnsJson: String) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .lazyVGrid, content: "")
             lastCreatedItem = newItem

             // Decode Columns
             if let data = columnsJson.data(using: .utf8),
                let specs = try? JSONDecoder().decode([GridItemSpec].self, from: data) {
                 newItem.gridColumns = specs
             }

             newItemId = newItem.id

             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }

        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
        return newItemId
    }

    @objc(addList:parentId:)
    public static func addListLegacy(_ dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .list, content: "")
             newItemId = newItem.id
             lastCreatedItem = newItem
             
             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }
        
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
        return newItemId
    }

    @objc(addTextItem:parentId:)
    public static func addTextItemLegacy(_ text: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .text, content: text)
             newItemId = newItem.id
             lastCreatedItem = newItem

             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }
        
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
        return newItemId
    }
    
    @objc(addSpacer:parentId:)
    public static func addSpacerLegacy(_ dummy: String, parentId: String?) {
        DispatchQueue.main.async {
             let newItem = StackItem(type: .spacer, content: "")
             lastCreatedItem = newItem
             
             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }
    }

    @objc(addDivider:parentId:)
    public static func addDividerLegacy(_ dummy: String, parentId: String?) {
         let block = {
             let newItem = StackItem(type: .divider, content: "")
             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                 if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                     parent.children.append(newItem)
                 } else {
                     state.items.append(newItem)
                 }
             }
         }
         
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }

    @objc(addButtonItem:parentId:)
    public static func addButtonItemLegacy(_ text: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .button, content: text)
             newItemId = newItem.id
             lastCreatedItem = newItem
             
             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }

         if Thread.isMainThread {
             block()
         } else {
             DispatchQueue.main.sync {
                 block()
             }
         }
        return newItemId
    }

    @objc(setItem:backgroundColorRed:green:blue:alpha:)
    public static func setItemBackgroundColorLegacy(id: String, red: Double, green: Double, blue: Double, alpha: Double) {
         DispatchQueue.main.async {
             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                 if let item = findItem(id: id, in: state.items) {
                     item.bgColor = (red, green, blue, alpha)
                 }
             }
         }
    }

    @objc(addBatchToParent:json:)
    public static func addBatchLegacy(parentId: String?, json: String) -> String {
        struct BatchInput: Codable {
            let type: Int
            let content: String
            let secondaryContent: String?
            let bg: ColorRGBA?
            let fg: ColorRGBA?
        }
        
        let decoder = JSONDecoder()
        guard let data = json.data(using: .utf8),
              let batchItems = try? decoder.decode([BatchInput].self, from: data) else {
            return "[]"
        }
        
        var newIds: [String] = []
        
        DispatchQueue.main.sync {
            guard let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState else { return }
            
            let parentItem = (parentId != nil) ? findItem(id: parentId!, in: state.items) : nil
            
            for itemIn in batchItems {
                let newItemType = StackItem.ItemType(rawValue: itemIn.type) ?? .text
                let newItem = StackItem(type: newItemType, content: itemIn.content, secondaryContent: itemIn.secondaryContent)
                
                // Color mapping
                if let bg = itemIn.bg { newItem.bgColor = (bg.r, bg.g, bg.b, bg.a) }
                if let fg = itemIn.fg { newItem.fgColor = (fg.r, fg.g, fg.b, fg.a) }
                
                newIds.append(newItem.id)
                lastCreatedItem = newItem 
                
                if let p = parentItem {
                    p.children.append(newItem) 
                } else {
                    state.items.append(newItem)
                }
            }
        }
        
        if let encoded = try? JSONEncoder().encode(newIds), let jsonString = String(data: encoded, encoding: .utf8) {
            return jsonString
        }
        return "[]"
    }

    @objc public static func setItemText(rootId: String, id: String, text: String) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId], let item = findItem(id: id, in: state.items) {
                item.content = text
            }
        }
    }
    
    @objc public static func setItemColor(rootId: String, id: String, r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId], let item = findItem(id: id, in: state.items) {
                item.fgColor = (r: Double(r), g: Double(g), b: Double(b), a: Double(a))
            }
        }
    }
    
    @objc public static func setItemFont(rootId: String, id: String, size: CGFloat, isBold: Bool) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId], let item = findItem(id: id, in: state.items) {
                item.fontSize = size > 0 ? Double(size) : nil
                item.isBold = isBold
            }
        }
    }
    @objc public static func setItemRadius(rootId: String, id: String, radius: CGFloat) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId], let item = findItem(id: id, in: state.items) {
                item.cornerRadius = Double(radius)
            }
        }
    }

    @objc(setItemColor:id:hex:)
    public static func setItemColor(rootId: String, id: String, hex: String) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId], let item = findItem(id: id, in: state.items) {
                let color = Color(hex: hex)
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                NSColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
                item.fgColor = (r: Double(r), g: Double(g), b: Double(b), a: Double(a))
            }
        }
    }

    @objc(setItemBgColor:id:hex:)
    public static func setItemBgColor(rootId: String, id: String, hex: String) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId], let item = findItem(id: id, in: state.items) {
                let color = Color(hex: hex)
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                NSColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
                item.bgColor = (r: Double(r), g: Double(g), b: Double(b), a: Double(a))
            }
        }
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourDirect
public func vstk_set_scroll(rootId: String, scrollable: Bool) {
    SwiftVStackLoader.setScrollable(rootId, scrollable: scrollable)
}

@HarbourDirect
public func vstk_set_bgcolor_hex(rootId: String, hex: String) {
    SwiftVStackLoader.setBackgroundColorHex(rootId: rootId, hex: hex)
}

@HarbourDirect
public func vstk_set_fgcolor_hex(rootId: String, hex: String) {
    SwiftVStackLoader.setForegroundColorHex(rootId: rootId, hex: hex)
}

@HarbourDirect
public func vstk_set_inverted_color(rootId: String, inverted: Bool) {
    SwiftVStackLoader.setInvertedColor(rootId, useInverted: inverted)
}

@HarbourDirect
public func vstk_set_spacing(rootId: String, spacing: Double) {
    SwiftVStackLoader.setSpacing(rootId, spacing: spacing)
}

@HarbourDirect
public func vstk_set_alignment(rootId: String, alignment: Int) {
    SwiftVStackLoader.setAlignment(rootId, alignment: alignment)
}

@HarbourDirect
public func vstk_set_item_text(rootId: String, id: String, text: String) {
    SwiftVStackLoader.setItemText(rootId, id: id, text: text)
}

@HarbourDirect
public func vstk_set_item_color_hex(rootId: String, id: String, hex: String) {
    SwiftVStackLoader.setItemColor(rootId: rootId, id: id, hex: hex)
}

@HarbourDirect
public func vstk_set_item_bgcolor_hex(rootId: String, id: String, hex: String) {
    SwiftVStackLoader.setItemBgColor(rootId: rootId, id: id, hex: hex)
}

@HarbourDirect
public func vstk_set_item_layout(rootId: String, id: String, w: Double, h: Double, s: Double) {
    SwiftVStackLoader.setItemLayout(rootId: rootId, id: id, w: w, h: h, s: s)
}

@HarbourDirect
public func vstk_set_item_font(rootId: String, id: String, size: Double, isBold: Bool) {
    SwiftVStackLoader.setItemFont(rootId: rootId, id: id, size: CGFloat(size), isBold: isBold)
}

@HarbourDirect
public func vstk_set_item_radius(rootId: String, id: String, radius: Double) {
    SwiftVStackLoader.setItemRadius(rootId: rootId, id: id, radius: CGFloat(radius))
}

@HarbourDirect
public func vstk_remove_all_items(rootId: String) {
    SwiftVStackLoader.removeAllItems(rootId)
}

@HarbourDirect
public func vstk_add_item(rootId: String, content: String) -> String {
    return SwiftVStackLoader.addItem(rootId, content: content)
}

@HarbourDirect
public func vstk_add_text_to(rootId: String, content: String, parentId: String?) -> String {
    return SwiftVStackLoader.addTextItem(rootId, content: content, parentId: parentId)
}

@HarbourDirect
public func vstk_add_spacer_to(rootId: String, parentId: String?) -> String {
    return SwiftVStackLoader.addSpacerItem(rootId, parentId: parentId)
}

@HarbourDirect
public func vstk_add_system_image_to(rootId: String, systemName: String, parentId: String?) -> String {
    return SwiftVStackLoader.addSystemImageItem(rootId, systemName: systemName, parentId: parentId)
}

@HarbourDirect
public func vstk_add_hstack(rootId: String, parentId: String?) -> String {
    return SwiftVStackLoader.addHStackContainer(rootId, dummy: "", parentId: parentId)
}

@HarbourDirect
public func vstk_add_vstack(rootId: String, parentId: String?) -> String {
    return SwiftVStackLoader.addStackItem(rootId, dummy: "", parentId: parentId)
}

@HarbourDirect
public func vstk_add_button_item(rootId: String, text: String, parentId: String?) -> String {
    return SwiftVStackLoader.addButtonItem(rootId, text: text, parentId: parentId)
}

@HarbourDirect
public func vstk_add_batch(rootId: String, json: String, parentId: String?) -> String {
    return SwiftVStackLoader.addBatch(rootId, parentId: parentId, json: json)
}

@HarbourDirect
public func vstk_add_list(rootId: String, parentId: String?) -> String {
    return SwiftVStackLoader.addList(rootId, dummy: "", parentId: parentId)
}

@HarbourDirect
public func vstk_add_lazyvgrid(rootId: String, parentId: String?, columnsJson: String) -> String {
    return SwiftVStackLoader.addLazyVGrid(rootId, parentId: parentId, columnsJson: columnsJson)
}

@HarbourDirect
public func vstk_add_divider_to(rootId: String, parentId: String?) -> String {
    return SwiftVStackLoader.addDivider(rootId, dummy: "", parentId: parentId)
}

@HarbourDirect
public func vstk_set_last_item_id(rootId: String, id: String) {
    SwiftVStackLoader.setLastItemId(rootId, id: id)
}

@HarbourDirect
public func vstk_get_last_item_id(rootId: String) -> String {
    return SwiftStackRegistry.sharedStates[rootId]?.lastItem?.id ?? ""
}
// --- HARBOUR DIRECT BRIDGES ---

@HarbourDirect
public func swift_vstack_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    parentPtr: Int64,
    id: String
) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        let finalId = id.isEmpty ? UUID().uuidString : id
        
        let vStackView = SwiftVStackLoader.makeVStack(id: finalId)
        
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
        
        SwiftVStackLoader.setActionCallback(rootId: finalId, callback: callback)
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: vStackView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(vStackView).toOpaque()
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

@HarbourDirect
public func vstk_destroy(id: String, viewPtr: Int64) {
    SwiftStackRegistry.sharedStates.removeValue(forKey: id)
    ViewRegistry.clean(id: id)
    
    if viewPtr != 0 {
        if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
            _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
        }
    }
}
