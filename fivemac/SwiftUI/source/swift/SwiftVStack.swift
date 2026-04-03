import SwiftUI
import Cocoa
import Observation
import HarbourMacro



@Observable
public class SwiftVStackState: StackStateProtocol, RGBAColorableState {
    public var items: [StackItem] = []
    public var scrollable: Bool = false
    public var useInvertedColor: Bool = false
    public var useGlassEffect: Bool = false
    public var spacing: Double = 12.0
    public var alignment: Int = 0
    public var lastItem: StackItem? = nil
    public var gridColumns: [GridItemSpec]? = nil
    public var onAction: ((String) -> Void)?
    
    // RGBA System Integration
    public var backgroundColor: Color = .clear
    public var textColor: Color = .primary

    public init() {}

    public func setAccentColorRGBA(color: Int, alpha: Int) {
        DispatchQueue.main.async {
            self.backgroundColor = Color(hbColor: color).opacity(Double(alpha) / 255.0)
        }
    }

    public func setTextColorRGBA(color: Int, alpha: Int) {
        DispatchQueue.main.async {
            self.textColor = Color(hbColor: color).opacity(Double(alpha) / 255.0)
        }
    }
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
        .foregroundColor(state.textColor)
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
        .frame(maxWidth: .infinity, alignment: Alignment(horizontal: align, vertical: .center))
    }
}

@objc(SwiftVStackLoader)
public class SwiftVStackLoader: NSObject {

    public static func makeVStack(id: String) -> NSView {
         let finalId = id.isEmpty ? UUID().uuidString : id
         let state = SwiftVStackState()
         
         // Register in central registry
         ViewRegistry.register(state, for: finalId)

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
        if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
            state.onAction = callback
        }
    }

    @objc(removeAllItems:)
    public static func removeAllItems(_ rootId: String) {
        let block = {
            if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
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
                if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
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
                if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
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
  
     @objc(addSpacerItem:parentId:)
     @discardableResult
     public static func addSpacerItem(_ rootId: String, parentId: String?) -> String {
         var newItemId = ""
         let block = {
                if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
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
             
                if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
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
 
    @objc(addHStackItem:text:systemName:)
    @discardableResult
    public static func addHStackItem(_ rootId: String, text: String, systemName: String) -> String {
        var newItemId = ""
        let block = {
                if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
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
            if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
                state.scrollable = scrollable
            }
        }
    }

    public static func setBackgroundColor(rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
         DispatchQueue.main.async {
              if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
                  state.backgroundColor = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
              }
         }
    }
    
    public static func setForegroundColor(rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
         DispatchQueue.main.async {
             if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
                 state.textColor = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
             }
         }
    }

    @objc(setSpacing:spacing:)
    public static func setSpacing(_ rootId: String, spacing: Double) {
        DispatchQueue.main.async {
            if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
                state.spacing = spacing
            }
        }
    }

    @objc(setAlignment:alignment:)
    public static func setAlignment(_ rootId: String, alignment: Int) {
        DispatchQueue.main.async {
            if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
                state.alignment = alignment
            }
        }
    }

    @objc(setInvertedColor:useInverted:)
    public static func setInvertedColor(_ rootId: String, useInverted: Bool) {
        DispatchQueue.main.async {
            if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
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
             if let state = (ViewRegistry.get(rootId) as? StackStateProtocol), let item = state.lastItem {
                 item.id = id
             }
         }
    }

    @objc(getLastItemId:)
    public static func getLastItemId(_ rootId: String) -> String {
        var result = ""
        let block = {
             if let state = (ViewRegistry.get(rootId) as? StackStateProtocol), let item = state.lastItem {
                 result = item.id
             }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return result
    }


    @objc(addStackItem:dummy:parentId:)
    @discardableResult
    public static func addStackItem(_ rootId: String, dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = StackItem(type: .vstack, content: "")
             newItemId = newItem.id
             
            if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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
             
            if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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

            if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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
             
            if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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
             
            if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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
            if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }
    @objc(addToggle:dummy:caption:initialValue:isSwitch:parentId:)
    @discardableResult
    public static func addToggle(_ rootId: String, dummy: String, caption: String, initialValue: Bool, isSwitch: Bool, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let finalId = dummy.isEmpty ? UUID().uuidString : dummy
             let state = ToggleState(isOn: initialValue, caption: caption, isSwitch: isSwitch, callback: nil)
             ViewRegistry.register(state, for: finalId)
             
             let newItem = StackItem(type: .toggle, content: caption, id: finalId)
             newItemId = newItem.id
             
             if let rootState = ViewRegistry.get(rootId) as? SwiftVStackState {
                  rootState.lastItem = newItem
                  if let pId = parentId, let parent = findItem(in: rootState.items, id: pId) {
                      parent.children.append(newItem)
                  } else {
                      rootState.items.append(newItem)
                  }
             }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        return newItemId
    }

    @objc(addSlider:id:value:min:max:glass:parentId:)
    @discardableResult
    public static func addSlider(_ rootId: String, id: String, value: Double, min: Double, max: Double, glass: Bool, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let finalId = id.isEmpty ? UUID().uuidString : id
             let state = SliderState(value: value, showValue: true, isGlass: glass, callback: nil)
             // SliderState currently doesn't support min/max properties, it's hardcoded to 0...100
             ViewRegistry.register(state, for: finalId)
             
             let newItem = StackItem(type: .slider, content: "", id: finalId)
             newItemId = newItem.id
             
             if let rootState = ViewRegistry.get(rootId) as? SwiftVStackState {
                  rootState.lastItem = newItem
                  if let pId = parentId, let parent = findItem(in: rootState.items, id: pId) {
                      parent.children.append(newItem)
                  } else {
                      rootState.items.append(newItem)
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
            if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
                 state.lastItem = newItem
                 if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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
             
            if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(in: state.items, id: pId) {
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
             if let state = (ViewRegistry.get(rootId) as? StackStateProtocol), let item = findItem(in: state.items, id: id) {
                 item.content = text
             }
         }
    }

    @objc(setItemColor:id:red:green:blue:alpha:)
    public static func setItemBackgroundColor(rootId: String, id: String, red: Double, green: Double, blue: Double, alpha: Double) {
        let block = {
            if let state = (ViewRegistry.get(rootId) as? StackStateProtocol) {
                if let item = findItem(in: state.items, id: id) {
                    item.bgColor = (red, green, blue, alpha)
                }
            }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public static func setItemColor(rootId: String, id: String, color: Int, alpha: Int) {
        let block = {
            if let state = (ViewRegistry.get(rootId) as? StackStateProtocol), let item = findItem(in: state.items, id: id) {
                item.fgColor = (Double(color & 0xFF)/255, Double((color >> 8)&0xFF)/255, Double((color >> 16)&0xFF)/255, Double(alpha)/255)
            }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
    }

    public static func setItemBgColor(rootId: String, id: String, color: Int, alpha: Int) {
        DispatchQueue.main.async {
            if let state = (ViewRegistry.get(rootId) as? StackStateProtocol), let item = SwiftFive.findItem(in: state.items, id: id) {
                item.bgColor = (Double(color & 0xFF)/255, Double((color >> 8)&0xFF)/255, Double((color >> 16)&0xFF)/255, Double(alpha)/255)
            }
        }
    }

    public static func setItemFont(rootId: String, id: String, size: CGFloat, isBold: Bool) {
        DispatchQueue.main.async {
            if let state = (ViewRegistry.get(rootId) as? StackStateProtocol), let item = SwiftFive.findItem(in: state.items, id: id) {
                item.fontSize = size > 0 ? Double(size) : nil
                item.isBold = isBold
            }
        }
    }

    public static func setItemRadius(rootId: String, id: String, radius: CGFloat) {
        DispatchQueue.main.async {
            if let state = (ViewRegistry.get(rootId) as? StackStateProtocol), let item = SwiftFive.findItem(in: state.items, id: id) {
                item.cornerRadius = Double(radius)
            }
        }
    }

    @objc(setItemLayout:id:w:h:s:)
    public static func setItemLayout(rootId: String, id: String, w: Double, h: Double, s: Double) {
         DispatchQueue.main.async {
             if let state = (ViewRegistry.get(rootId) as? StackStateProtocol), let item = SwiftFive.findItem(in: state.items, id: id) {
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
        guard let data = json.data(using: .utf8), let batchItems = try? decoder.decode([BatchInput].self, from: data) else { return "[]" }
        var newIds: [String] = []
        let block = {
            guard let state = (ViewRegistry.get(rootId) as? StackStateProtocol) else { return }
            let parentItem = (parentId != nil && !parentId!.isEmpty) ? findItem(in: state.items, id: parentId!) : nil
            for itemIn in batchItems {
                let newItemType = StackItem.ItemType(rawValue: itemIn.type) ?? .text
                let newItem = StackItem(type: newItemType, content: itemIn.content, secondaryContent: itemIn.secondaryContent)
                if let bg = itemIn.bg { newItem.bgColor = (bg.r, bg.g, bg.b, bg.a) }
                if let fg = itemIn.fg { newItem.fgColor = (fg.r, fg.g, fg.b, fg.a) }
                newIds.append(newItem.id)
                state.lastItem = newItem 
                if let p = parentItem { p.children.append(newItem) } else { state.items.append(newItem) }
            }
        }
        if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        if let encoded = try? JSONEncoder().encode(newIds), let res = String(data: encoded, encoding: .utf8) { return res }
        return "[]"
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourDirect
public func vstk_set_scroll(rootId: String, scrollable: Bool) {
    SwiftVStackLoader.setScrollable(rootId, scrollable: scrollable)
}

@HarbourDirect
public func vstk_set_bgcolor(rootId: String, color: Int, alpha: Int) {
    if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
        DispatchQueue.main.async { state.backgroundColor = Color(hbColor: color, alpha: alpha) }
    }
}

@HarbourDirect
public func vstk_set_fgcolor(rootId: String, color: Int, alpha: Int) {
    if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
        DispatchQueue.main.async { state.textColor = Color(hbColor: color, alpha: alpha) }
    }
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
public func vstk_set_item_color(rootId: String, id: String, color: Int, alpha: Int) {
    SwiftVStackLoader.setItemColor(rootId: rootId, id: id, color: color, alpha: alpha)
}

@HarbourDirect
public func vstk_set_item_bgcolor(rootId: String, id: String, color: Int, alpha: Int) {
    SwiftVStackLoader.setItemBgColor(rootId: rootId, id: id, color: color, alpha: alpha)
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
public func vstk_add_toggle(rootId: String, id: String, caption: String, initialValue: Bool, isSwitch: Bool, parentId: String?) -> String {
    return SwiftVStackLoader.addToggle(rootId, dummy: id, caption: caption, initialValue: initialValue, isSwitch: isSwitch, parentId: parentId)
}

@HarbourDirect
public func vstk_add_slider(rootId: String, id: String, value: Double, min: Double, max: Double, glass: Bool, parentId: String?) -> String {
    return SwiftVStackLoader.addSlider(rootId, id: id, value: value, min: min, max: max, glass: glass, parentId: parentId)
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
    return (ViewRegistry.get(rootId) as? StackStateProtocol)?.lastItem?.id ?? ""
}

@HarbourDirect
public func vstk_set_glass_effect(rootId: String, useGlass: Bool) {
    if let state = ViewRegistry.get(rootId) as? SwiftVStackState {
        DispatchQueue.main.async { state.useGlassEffect = useGlass }
    }
}

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
            SwiftBridge.onAction(finalId, itemId)
        }
        
        SwiftVStackLoader.setActionCallback(rootId: finalId, callback: callback)
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            applySwiftViewLayout(swiftView: vStackView, parent: parentObj, top: top, left: left, w: width, h: height)
            let viewPtr = Unmanaged.passRetained(vStackView).toOpaque()
            viewAddress = Int64(Int(bitPattern: viewPtr))
        }
        return viewAddress
    }

    return Thread.isMainThread ? executeCreation() : DispatchQueue.main.sync { executeCreation() }
}

@HarbourDirect
public func vstk_destroy(id: String, viewPtr: Int64) {
    ViewRegistry.clean(id: id)
    if viewPtr != 0 {
        if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
            _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
        }
    }
}
