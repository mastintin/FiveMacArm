import SwiftUI
import Cocoa
import Observation
import HarbourMacro

@Observable
class SwiftZStackState: StackStateProtocol {
    var items: [StackItem] = [] 
    var alignment: Int = 0 
    
    var backgroundColor: Color = Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.5)
    var foregroundColor: Color = .primary

    var lastItem: StackItem? = nil
    var onAction: ((String) -> Void)? = nil
}

struct SwiftZStackView: View {
    var state: SwiftZStackState
    
    var body: some View {
        let align: Alignment
        switch state.alignment {
        case 1: align = .topLeading
        case 2: align = .top
        case 3: align = .topTrailing
        case 4: align = .leading
        case 5: align = .trailing
        case 6: align = .bottomLeading
        case 7: align = .bottom
        case 8: align = .bottomTrailing
        default: align = .center
        }
        
        return ZStack(alignment: align) {
              ForEach(0..<state.items.count, id: \.self) { index in
                   let item = state.items[index]
                   RecursiveItemView(item: item, onAction: state.onAction, index: index)
              }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) 
        .background(state.backgroundColor)
        .cornerRadius(10)
    }
}

@objc(SwiftZStackLoader)
public class SwiftZStackLoader: NSObject {
    
    @objc(makeZStackWithIndex:)
    public static func makeZStack(id: String) -> NSView {
         let finalId = id.isEmpty ? UUID().uuidString : id
         let state = SwiftZStackState()
         
         // Register in central registry
         SwiftStackRegistry.sharedStates[finalId] = state
         
         let view = SwiftZStackView(state: state)
         ViewRegistry.register(view, for: finalId)
         
         let hostingView = NSHostingView(rootView: view)
         hostingView.sizingOptions = []
         hostingView.translatesAutoresizingMaskIntoConstraints = false
         hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
         return hostingView
    }

    @objc(setActionCallbackWithRootId:callback:)
    public static func setActionCallback(rootId: String, callback: @escaping (String) -> Void) {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            state.onAction = callback
        }
    }
    
    public static func addItem(_ rootId: String, text: String) -> String {
        var newItemId = ""
        let block = {
              if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                  let newItem = StackItem(type: .text, content: text, secondaryContent: nil)
                  newItemId = newItem.id
                  state.items.append(newItem)
                  state.lastItem = newItem
              }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }
    
    public static func addSystemImage(_ rootId: String, systemName: String) -> String {
        var newItemId = ""
        let block = {
              if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                 let newItem = StackItem(type: .systemImage, content: systemName, secondaryContent: nil)
                 newItemId = newItem.id
                 state.items.append(newItem)
                 state.lastItem = newItem
              }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }

    public static func addFileImage(_ rootId: String, filePath: String) -> String {
        var newItemId = ""
        let block = {
              if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                 let newItem = StackItem(type: .imageFile, content: filePath, secondaryContent: nil)
                 newItemId = newItem.id
                 state.items.append(newItem)
                 state.lastItem = newItem
              }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }
    
    public static func removeAllItems(_ rootId: String) {
        let block = {
              if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                  state.items.removeAll()
                  state.lastItem = nil
              }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
    }

    public static func addBatch(_ rootId: String, parentId: String?, json: String) -> String {
        struct BatchInput: Codable {
            let type: Int
            let content: String
            let secondaryContent: String?
            let bgHex: String?
            let fgHex: String?
        }
        
        let decoder = JSONDecoder()
        guard let data = json.data(using: .utf8),
              let batchItems = try? decoder.decode([BatchInput].self, from: data) else {
            return "[]"
        }
        
        var createdIds: [String] = []
        
        let block = {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                let parentItem = (parentId != nil && parentId != "nil" && !parentId!.isEmpty) ? 
                                 findItem(in: state.items, id: parentId!) : nil

                for item in batchItems {
                    let newItem = StackItem(type: StackItem.ItemType(rawValue: item.type) ?? .text,
                                           content: item.content,
                                           secondaryContent: item.secondaryContent)
                    
                    if let bgHex = item.bgHex {
                        let color = Color(hex: bgHex)
                        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                        NSColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
                        newItem.bgColor = (Double(r), Double(g), Double(b), Double(a))
                    }
                    if let fgHex = item.fgHex {
                        let color = Color(hex: fgHex)
                        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                        NSColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
                        newItem.fgColor = (Double(r), Double(g), Double(b), Double(a))
                    }

                    if let parent = parentItem {
                        parent.children.append(newItem)
                    } else {
                        state.items.append(newItem)
                    }
                    createdIds.append(newItem.id)
                }
            }
        }
        
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        
        let encoder = JSONEncoder()
        if let idData = try? encoder.encode(createdIds),
           let idString = String(data: idData, encoding: .utf8) {
            return idString
        }
        
        return "[]"
    }

    // Legacy support
    public static func setAlignment(_ rootId: String, alignment: Int) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                state.alignment = alignment
            }
        }
    }
    
    public static func setBackgroundColor(_ rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
         DispatchQueue.main.async {
             if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                 state.backgroundColor = Color(red: red, green: green, blue: blue, opacity: alpha)
             }
         }
    }
    
    public static func setForegroundColor(_ rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
         DispatchQueue.main.async {
             if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                 state.foregroundColor = Color(red: red, green: green, blue: blue, opacity: alpha)
             }
         }
    }

    public static func setItemColor(rootId: String, id: String, hex: String) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState,
               let item = findItem(in: state.items, id: id) {
                let color = Color(hex: hex)
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                NSColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
                item.fgColor = (r: Double(r), g: Double(g), b: Double(b), a: Double(a))
            }
        }
    }

    public static func setItemBgColor(rootId: String, id: String, hex: String) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState,
               let item = findItem(in: state.items, id: id) {
                let color = Color(hex: hex)
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                NSColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
                item.bgColor = (r: Double(r), g: Double(g), b: Double(b), a: Double(a))
            }
        }
    }
    public static func setItemRadius(rootId: String, id: String, radius: CGFloat) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState,
               let item = findItem(in: state.items, id: id) {
                item.cornerRadius = Double(radius)
            }
        }
    }

    public static func setItemLayout(rootId: String, id: String, w: Double, h: Double, s: Double) {
         DispatchQueue.main.async {
             if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState,
                let item = findItem(in: state.items, id: id) {
                 if w > 0 { item.itemWidth = w }
                 if h > 0 { item.itemHeight = h }
                 if s >= 0 { item.spacing = s }
             }
         }
    }

    public static func setItemFont(rootId: String, id: String, size: CGFloat, isBold: Bool) {
         DispatchQueue.main.async {
             if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState,
                let item = findItem(in: state.items, id: id) {
                 if size > 0 { item.fontSize = Double(size) }
                 item.isBold = isBold
             }
         }
    }

    public static func setItemText(rootId: String, id: String, text: String) {
         DispatchQueue.main.async {
             if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState,
                let item = findItem(in: state.items, id: id) {
                 item.content = text
             }
         }
    }
}

// --- HARBOUR DIRECT BRIDGES ---

@HarbourDirect
public func swift_zstack_create(
    top: Double, 
    left: Double, 
    width: Double, 
    height: Double,
    parentPtr: Int64,
    id: String
) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        var finalId = id
        let zStackView = SwiftZStackLoader.makeZStack(id: id)
        finalId = zStackView.identifier?.rawValue ?? id
        
        let callback: (String) -> Void = { itemId in
             let sendToHarbour = {
                if let pDynSym = hb_dynsymFindName("SWIFTONACTION") {
                    hb_vmPushSymbol(hb_dynsymSymbol(pDynSym))
                    hb_vmPushNil()
                    hb_vmPushNumber(0, 0) // dummy index
                    hb_vmPushString(itemId)
                    hb_vmDo(2)
                }
            }
            if Thread.isMainThread {
                sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }
        
        SwiftZStackLoader.setActionCallback(rootId: finalId, callback: callback)
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: zStackView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(zStackView).toOpaque()
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
public func zstk_set_alignment(rootId: String, alignment: Int) {
    if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
        DispatchQueue.main.async {
            state.alignment = alignment
        }
    }
}

@HarbourDirect
public func zstk_set_bgcolor_hex(rootId: String, hex: String) {
    if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
        DispatchQueue.main.async {
            state.backgroundColor = Color(hex: hex)
        }
    }
}

@HarbourDirect
public func zstk_set_fgcolor_hex(rootId: String, hex: String) {
    if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
        DispatchQueue.main.async {
            state.foregroundColor = Color(hex: hex)
        }
    }
}

@HarbourDirect
public func zstk_set_item_color_hex(rootId: String, id: String, hex: String) {
    SwiftZStackLoader.setItemColor(rootId: rootId, id: id, hex: hex)
}

@HarbourDirect
public func zstk_set_item_bgcolor_hex(rootId: String, id: String, hex: String) {
    SwiftZStackLoader.setItemBgColor(rootId: rootId, id: id, hex: hex)
}

@HarbourDirect
public func zstk_remove_all_items(rootId: String) {
    SwiftZStackLoader.removeAllItems(rootId)
}

@HarbourDirect
public func zstk_add_item(rootId: String, content: String) -> String {
    return SwiftZStackLoader.addItem(rootId, text: content)
}

@HarbourDirect
public func zstk_add_file_image(rootId: String, filePath: String) -> String {
    return SwiftZStackLoader.addFileImage(rootId, filePath: filePath)
}

@HarbourDirect
public func zstk_add_text_to(rootId: String, content: String, parentId: String?) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = StackItem(type: .text, content: content)
            newItemId = newItem.id
            if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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

@HarbourDirect
public func zstk_add_image(rootId: String, systemName: String) -> String {
    return SwiftZStackLoader.addSystemImage(rootId, systemName: systemName) 
}

@HarbourDirect
public func zstk_add_system_image_to(rootId: String, systemName: String, parentId: String?) -> String {
    return SwiftZStackLoader.addSystemImage(rootId, systemName: systemName) 
}

@HarbourDirect
public func zstk_add_button_to(rootId: String, text: String, parentId: String?) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = StackItem(type: .button, content: text)
            newItemId = newItem.id
            if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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

@HarbourDirect
public func zstk_add_spacer(rootId: String, parentId: String?) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = StackItem(type: .spacer, content: "")
            newItemId = newItem.id
            if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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

@HarbourDirect
public func zstk_add_divider(rootId: String, parentId: String?) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = StackItem(type: .divider, content: "")
            newItemId = newItem.id
            if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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

@HarbourDirect
public func zstk_add_batch(rootId: String, json: String, parentId: String?) -> String {
    return SwiftZStackLoader.addBatch(rootId, parentId: parentId, json: json)
}

@HarbourDirect
public func zstk_add_list(rootId: String, parentId: String?) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = StackItem(type: .list, content: "")
            newItemId = newItem.id
            if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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

@HarbourDirect
public func zstk_add_lazyvgrid(rootId: String, parentId: String?, columnsJson: String) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = StackItem(type: .lazyVGrid, content: "")
            if let data = columnsJson.data(using: .utf8),
               let specs = try? JSONDecoder().decode([GridItemSpec].self, from: data) {
                newItem.gridColumns = specs
            }
            newItemId = newItem.id
            if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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

@HarbourDirect
public func zstk_set_item_layout(rootId: String, id: String, w: Double, h: Double, s: Double) {
    SwiftZStackLoader.setItemLayout(rootId: rootId, id: id, w: w, h: h, s: s)
}

@HarbourDirect
public func zstk_set_item_font(rootId: String, id: String, size: Double, isBold: Bool) {
    SwiftZStackLoader.setItemFont(rootId: rootId, id: id, size: CGFloat(size), isBold: isBold)
}

@HarbourDirect
public func zstk_set_item_radius(rootId: String, id: String, radius: Double) {
    SwiftZStackLoader.setItemRadius(rootId: rootId, id: id, radius: CGFloat(radius))
}

@HarbourDirect
public func zstk_set_item_text(rootId: String, id: String, text: String) {
    SwiftZStackLoader.setItemText(rootId: rootId, id: id, text: text)
}

@HarbourDirect
public func zstk_set_last_item_id(rootId: String, id: String) {
    DispatchQueue.main.async {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState,
           let item = state.lastItem {
            item.id = id
        }
    }
}

@HarbourDirect
public func zstk_get_last_item_id(rootId: String) -> String {
    if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
        return state.lastItem?.id ?? ""
    }
    return ""
}

@HarbourDirect
public func zstk_add_vstack(rootId: String, parentId: String?) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = StackItem(type: .vstack, content: "")
            newItemId = newItem.id
            if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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

@HarbourDirect
public func zstk_add_hstack(rootId: String, parentId: String?) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = StackItem(type: .hstackContainer, content: "")
            newItemId = newItem.id
            if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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

@HarbourDirect
public func zstk_destroy(id: String, viewPtr: Int64) {
    SwiftStackRegistry.sharedStates.removeValue(forKey: id)
    ViewRegistry.clean(id: id)
    
    if viewPtr != 0 {
        if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
            _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
        }
    }
}

