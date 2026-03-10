import SwiftUI
import Cocoa
import Observation
import HarbourMacro

@Observable
class SwiftZStackState: StackStateProtocol {
    var items: [VStackItem] = [] 
    var alignment: Int = 0 
    
    var backgroundColor: Color = Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.5)
    var foregroundColor: Color = .primary

    var lastItem: VStackItem? = nil
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

@HarbourBridge
@objc(SwiftZStackLoader)
public class SwiftZStackLoader: NSObject {
    
    @objc(makeZStackWithIndex:)
    public static func makeZStack(index: String) -> NSView {
         let state = SwiftZStackState()
         
         // Register in central registry
         SwiftStackRegistry.sharedStates[index] = state
         
         let view = SwiftZStackView(state: state)
         
         let hostingView = NSHostingView(rootView: view)
         return hostingView
    }

    @objc(setActionCallbackWithRootId:callback:)
    public static func setActionCallback(rootId: String, callback: @escaping (String) -> Void) {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            state.onAction = callback
        }
    }
    
    @objc(addItem:content:)
    public static func addItem(_ rootId: String, text: String) -> String {
        var newItemId = ""
        let block = {
              if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                  let newItem = VStackItem(type: .text, content: text, secondaryContent: nil)
                  newItemId = newItem.id
                  state.items.append(newItem)
                  state.lastItem = newItem
              }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }
    
    @objc(addSystemImage:systemName:)
    public static func addSystemImage(_ rootId: String, systemName: String) -> String {
        var newItemId = ""
        let block = {
              if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                 let newItem = VStackItem(type: .systemImage, content: systemName, secondaryContent: nil)
                 newItemId = newItem.id
                 state.items.append(newItem)
                 state.lastItem = newItem
              }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }

    @objc(addFileImage:filePath:)
    public static func addFileImage(_ rootId: String, filePath: String) -> String {
        var newItemId = ""
        let block = {
              if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                 let newItem = VStackItem(type: .imageFile, content: filePath, secondaryContent: nil)
                 newItemId = newItem.id
                 state.items.append(newItem)
                 state.lastItem = newItem
              }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }
    
    @objc(removeAllItems:)
    public static func removeAllItems(_ rootId: String) {
        let block = {
              if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                  state.items.removeAll()
                  state.lastItem = nil
              }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
    }

    @objc(addBatch:parentId:json:)
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
                                 findVStackItem(in: state.items, id: parentId!) : nil

                for item in batchItems {
                    let newItem = VStackItem(type: VStackItem.ItemType(rawValue: item.type) ?? .text,
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
    @objc(setAlignment:alignment:)
    public static func setAlignment(_ rootId: String, alignment: Int) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                state.alignment = alignment
            }
        }
    }
    
    @objc(setBackgroundColor:red:green:blue:alpha:)
    public static func setBackgroundColor(_ rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
         DispatchQueue.main.async {
             if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                 state.backgroundColor = Color(red: red, green: green, blue: blue, opacity: alpha)
             }
         }
    }
    
    @objc(setForegroundColor:red:green:blue:alpha:)
    public static func setForegroundColor(_ rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
         DispatchQueue.main.async {
             if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
                 state.foregroundColor = Color(red: red, green: green, blue: blue, opacity: alpha)
             }
         }
    }

    @objc(setItemColor:id:hex:)
    public static func setItemColor(rootId: String, id: String, hex: String) {
        DispatchQueue.main.async {
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState,
               let item = findVStackItem(in: state.items, id: id) {
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
            if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState,
               let item = findVStackItem(in: state.items, id: id) {
                let color = Color(hex: hex)
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                NSColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
                item.bgColor = (r: Double(r), g: Double(g), b: Double(b), a: Double(a))
            }
        }
    }
}

@HarbourBridge
public func zstk_set_alignment(rootId: String, alignStr: String) {
    if let nAlign = Int(alignStr), let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
        DispatchQueue.main.async {
            state.alignment = nAlign
        }
    }
}

@HarbourBridge
public func zstk_set_bgcolor_hex(rootId: String, hex: String) {
    if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
        DispatchQueue.main.async {
            state.backgroundColor = Color(hex: hex)
        }
    }
}

@HarbourBridge
public func zstk_set_fgcolor_hex(rootId: String, hex: String) {
    if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
        DispatchQueue.main.async {
            state.foregroundColor = Color(hex: hex)
        }
    }
}

@HarbourBridge
public func zstk_set_item_color_hex(rootId: String, id: String, hex: String) {
    SwiftZStackLoader.setItemColor(rootId: rootId, id: id, hex: hex)
}

@HarbourBridge
public func zstk_set_item_bgcolor_hex(rootId: String, id: String, hex: String) {
    SwiftZStackLoader.setItemBgColor(rootId: rootId, id: id, hex: hex)
}

@HarbourBridge
public func zstk_remove_all(rootId: String) {
    SwiftZStackLoader.removeAllItems(rootId)
}

@HarbourBridge
public func zstk_add_item(rootId: String, content: String) -> String {
    return SwiftZStackLoader.addItem(rootId, text: content)
}

@HarbourBridge
public func zstk_add_file_image(rootId: String, filePath: String) -> String {
    return SwiftZStackLoader.addFileImage(rootId, filePath: filePath)
}

@HarbourBridge
public func zstk_add_text_to(rootId: String, content: String, parentId: String?) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = VStackItem(type: .text, content: content)
            newItemId = newItem.id
            if let pId = parentId, let parent = findVStackItem(in: state.items, id: pId) {
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

@HarbourBridge
public func zstk_add_system_image_to(rootId: String, systemName: String, parentId: String?) -> String {
    return SwiftZStackLoader.addSystemImage(rootId, systemName: systemName) // Simplifying as per VStack logic
}

@HarbourBridge
public func zstk_add_button_to(rootId: String, text: String, parentId: String?) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = VStackItem(type: .button, content: text)
            newItemId = newItem.id
            if let pId = parentId, let parent = findVStackItem(in: state.items, id: pId) {
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

@HarbourBridge
public func zstk_add_spacer(rootId: String, parentId: String?) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = VStackItem(type: .spacer, content: "")
            newItemId = newItem.id
            if let pId = parentId, let parent = findVStackItem(in: state.items, id: pId) {
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

@HarbourBridge
public func zstk_add_divider(rootId: String, parentId: String?) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = VStackItem(type: .divider, content: "")
            newItemId = newItem.id
            if let pId = parentId, let parent = findVStackItem(in: state.items, id: pId) {
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

@HarbourBridge
public func zstk_add_batch(rootId: String, json: String, parentId: String?) -> String {
    return SwiftZStackLoader.addBatch(rootId, parentId: parentId, json: json)
}

@HarbourBridge
public func zstk_add_list(rootId: String, parentId: String?) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = VStackItem(type: .list, content: "")
            newItemId = newItem.id
            if let pId = parentId, let parent = findVStackItem(in: state.items, id: pId) {
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

@HarbourBridge
public func zstk_add_lazyvgrid(rootId: String, parentId: String?, columnsJson: String) -> String {
    var newItemId = ""
    let block = {
        if let state = SwiftStackRegistry.sharedStates[rootId] as? SwiftZStackState {
            let newItem = VStackItem(type: .lazyVGrid, content: "")
            if let data = columnsJson.data(using: .utf8),
               let specs = try? JSONDecoder().decode([GridItemSpec].self, from: data) {
                newItem.gridColumns = specs
            }
            newItemId = newItem.id
            if let pId = parentId, let parent = findVStackItem(in: state.items, id: pId) {
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
