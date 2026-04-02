import SwiftUI
import Cocoa
import Observation
import HarbourMacro

@Observable
public class SwiftListState: StackStateProtocol {
    public var items: [StackItem] = []
    public var onAction: ((String) -> Void)?
    public var lastItem: StackItem? = nil
    
    public var selectedId: String? = nil
    
    // Background colors
    public var red: Double = 1.0
    public var green: Double = 1.0
    public var blue: Double = 1.0
    public var alpha: Double = 1.0
    public var useInvertedColor: Bool = false

    public init() {}
}

struct SwiftListView: View {
    var state: SwiftListState
    
    var body: some View {
        List {
            ForEach(state.items) { item in
                 RecursiveItemView(item: item, onAction: state.onAction, index: 0, isInsideList: true)
                     .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                     .contentShape(Rectangle())
                     .onTapGesture {
                         state.selectedId = item.id
                         state.onAction?(item.id)
                     }
                     .listRowBackground(state.selectedId == item.id ? Color.accentColor.opacity(0.2) : Color.clear)
                     .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(PlainListStyle())
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
    
    public static var states: [String: SwiftListState] = [:]
    public static var lastCreatedState: SwiftListState? = nil

    @objc(makeListWithIndex:)
    public static func makeList(id: String) -> NSView {
         let finalId = id.isEmpty ? UUID().uuidString : id
         let state = SwiftListState()
         
         states[finalId] = state
         lastCreatedState = state
         SwiftStackRegistry.sharedStates[finalId] = state
         
         let view = SwiftListView(state: state)
         ViewRegistry.register(view, for: finalId)

         let hostingView = NSHostingView(rootView: view)
         hostingView.sizingOptions = []
         hostingView.translatesAutoresizingMaskIntoConstraints = false
         hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
         return hostingView
    }

    @objc(setActionCallbackWithRootId:callback:)
    public static func setActionCallback(rootId: String, callback: @escaping (String) -> Void) {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftListState {
            state.onAction = callback
        }
    }

    // Legacy support
    @objc(selectIndex:index:)
    public static func selectIndex(_ id: String, index: Int) {
         if let state = SwiftStackRegistry.sharedStates[id] as? SwiftListState {
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
         DispatchQueue.main.async {
              if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftListState {
                  state.red = red
                  state.green = green
                  state.blue = blue
                  state.alpha = alpha
              }
         }
    }

    public static func findItemRecursive(id: String, in items: [StackItem]) -> StackItem? {
        for item in items {
            if item.id == id { return item }
            if !item.children.isEmpty {
                if let found = findItemRecursive(id: id, in: item.children) {
                    return found
                }
            }
        }
        return nil
    }

    public static func addListRow(rootId: String) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .hstackContainer, content: "")
             newItemId = newItem.id
             if let state = SwiftStackRegistry.sharedStates[rootId] {
                  state.items.append(newItem)
                  state.lastItem = newItem
             }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }

    @objc(setItemLayout:id:w:h:s:)
    public static func setItemLayout(rootId: String, id: String, w: String, h: String, s: String) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftListState,
               let item = findItemRecursive(id: id, in: state.items) {
                if let valW = Double(w), valW > 0 { item.itemWidth = valW }
                if let valH = Double(h), valH > 0 { item.itemHeight = valH }
                if let valS = Double(s), valS >= 0 { item.spacing = valS }
            }
        }
    }

    @objc(setItemFont:id:size:isBold:)
    public static func setItemFont(rootId: String, id: String, size: String, isBold: Bool) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftListState,
               let item = findItemRecursive(id: id, in: state.items) {
                if let valSize = Double(size), valSize > 0 { item.fontSize = valSize }
                item.isBold = isBold
            }
        }
    }

    @objc(setItemColor:id:hex:)
    public static func setItemColor(rootId: String, id: String, hex: String) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftListState,
               let item = findItemRecursive(id: id, in: state.items) {
                if let parsed = Color.parseHexRGBA(hex) {
                    item.fgColor = parsed
                }
            }
        }
    }

    @objc(setItemBgColor:id:hex:)
    public static func setItemBgColor(rootId: String, id: String, hex: String) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftListState,
               let item = findItemRecursive(id: id, in: state.items) {
                if let parsed = Color.parseHexRGBA(hex) {
                    item.bgColor = parsed
                }
            }
        }
    }

    @objc(setItemText:id:text:)
    public static func setItemText(rootId: String, id: String, text: String) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftListState,
               let item = findItemRecursive(id: id, in: state.items) {
                item.content = text
            }
        }
    }

    @objc(setItemRadius:id:radius:)
    public static func setItemRadius(rootId: String, id: String, radius: Double) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftListState,
               let item = findItemRecursive(id: id, in: state.items) {
                item.cornerRadius = radius
            }
        }
    }
}

@HarbourDirect
public func lst_set_item_layout(rootId: String, id: String, w: String, h: String, s: String) {
    SwiftListLoader.setItemLayout(rootId: rootId, id: id, w: w, h: h, s: s)
}

@HarbourDirect
public func lst_set_item_color_hex(rootId: String, id: String, hex: String) {
    SwiftListLoader.setItemColor(rootId: rootId, id: id, hex: hex)
}

@HarbourDirect
public func lst_set_item_font(rootId: String, id: String, size: String, isBold: Bool) {
    SwiftListLoader.setItemFont(rootId: rootId, id: id, size: size, isBold: isBold)
}

@HarbourDirect
public func lst_set_item_bgcolor_hex(rootId: String, id: String, hex: String) {
    SwiftListLoader.setItemBgColor(rootId: rootId, id: id, hex: hex)
}

@HarbourDirect
public func lst_set_item_text(rootId: String, id: String, text: String) {
    SwiftListLoader.setItemText(rootId: rootId, id: id, text: text)
}

@HarbourDirect
public func lst_set_item_radius(rootId: String, id: String, radius: Double) {
    SwiftListLoader.setItemRadius(rootId: rootId, id: id, radius: radius)
}

@HarbourDirect
public func lst_add_row(rootId: String) -> String {
    return SwiftListLoader.addListRow(rootId: rootId)
}

@HarbourDirect
public func lst_set_selection(rootId: String, indexStr: String) {
     if let index = Int(indexStr) {
         SwiftListLoader.selectIndex(rootId, index: index)
     }
}

@HarbourDirect
public func lst_set_bgcolor(rootId: String, r: String, g: String, b: String, a: String) {
    if let rd = Double(r), let gr = Double(g), let bl = Double(b), let al = Double(a) {
        SwiftListLoader.setBackgroundColor(rootId: rootId, red: rd, green: gr, blue: bl, alpha: al)
    }
}

@HarbourDirect
public func lst_set_bgcolor_hex(rootId: String, hex: String) {
    let color = Color(hex: hex)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    NSColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
    SwiftListLoader.setBackgroundColor(rootId: rootId, red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
}

@HarbourDirect
public func lst_remove_all(rootId: String) {
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftListState {
            state.items.removeAll()
            state.lastItem = nil
        }
    }
    if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
}

@HarbourDirect
public func lst_add_item(rootId: String, type: Int, content: String, secondary: String, parentId: String) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftListState {
            let itemType = StackItem.ItemType(rawValue: type) ?? .text
            let secContent = secondary.isEmpty ? nil : secondary
            let newItem = StackItem(type: itemType, content: content, secondaryContent: secContent)
            
            newItemId = newItem.id
            state.lastItem = newItem

            if !parentId.isEmpty {
                if let parent = SwiftListLoader.findItemRecursive(id: parentId, in: state.items) {
                    parent.children.append(newItem)
                } else {
                    state.items.append(newItem)
                }
            } else {
                state.items.append(newItem)
            }
        }
    }
    if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
    return newItemId
}

@HarbourDirect
public func lst_add_batch(rootId: String, json: String, parentId: String?) -> String {
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
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftListState {
            let parentItem = (parentId != nil && !parentId!.isEmpty) ? SwiftListLoader.findItemRecursive(id: parentId!, in: state.items) : nil
            
            for itemIn in batchItems {
                let newItemType = StackItem.ItemType(rawValue: itemIn.type) ?? .text
                let newItem = StackItem(type: newItemType, content: itemIn.content, secondaryContent: itemIn.secondaryContent)
                
                if let bg = itemIn.bg { newItem.bgColor = (bg.r, bg.g, bg.b, bg.a) }
                if let fg = itemIn.fg { newItem.fgColor = (fg.r, fg.g, fg.b, fg.a) }
                
                if let p = parentItem {
                    p.children.append(newItem)
                } else {
                    state.items.append(newItem)
                }
                state.lastItem = newItem
                newIds.append(newItem.id)
            }
        }
    }
    if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
    
    if let encoded = try? JSONEncoder().encode(newIds), let res = String(data: encoded, encoding: .utf8) {
        return res
    }
    return "[]"
}

@HarbourDirect
public func lst_get_last_item_id(rootId: String) -> String {
    return SwiftStackRegistry.sharedStates[rootId]?.lastItem?.id ?? ""
}

@HarbourDirect
public func swift_list_create(
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
        
        let listView = SwiftListLoader.makeList(id: finalId)
        
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
        
        SwiftListLoader.setActionCallback(rootId: finalId, callback: callback)
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: listView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(listView).toOpaque()
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
public func lst_destroy(id: String, viewPtr: Int64) {
    SwiftStackRegistry.sharedStates.removeValue(forKey: id)
    ViewRegistry.clean(id: id)
    
    if viewPtr != 0 {
        if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
            _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
        }
    }
}
