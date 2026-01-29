import SwiftUI
import AppKit

@available(OSX 10.15, *)
struct GridItemSpec: Codable {
    let type: String // "fixed", "flexible", "adaptive"
    let size: Double?
    let min: Double?
    let max: Double?
    let spacing: Double?
}

@available(OSX 10.15, *)
struct ColorRGBA: Codable {
    let r: Double
    let g: Double
    let b: Double
    let a: Double
}

@available(OSX 10.15, *)
func mapSpecsToGridItems(_ specs: [GridItemSpec]) -> [GridItem] {
    return specs.map { spec in
        let spacing = spec.spacing.map { CGFloat($0) }
        switch spec.type {
        case "fixed":
            return GridItem(.fixed(CGFloat(spec.size ?? 100)), spacing: spacing)
        case "flexible":
            return GridItem(.flexible(minimum: CGFloat(spec.min ?? 10), maximum: CGFloat(spec.max ?? .infinity)), spacing: spacing)
        case "adaptive":
            return GridItem(.adaptive(minimum: CGFloat(spec.min ?? 50), maximum: CGFloat(spec.max ?? .infinity)), spacing: spacing)
        default:
            return GridItem(.flexible())
        }
    }
}

@available(OSX 10.15, *)
class VStackItem: Identifiable, ObservableObject {
    var id: String
    let type: ItemType
    let content: String
    let secondaryContent: String?
    @Published var children: [VStackItem] = []

    // Grid Props
    var gridColumns: [GridItemSpec]? = nil

    // Background & Foreground Color
    @Published var bgColor: (r: Double, g: Double, b: Double, a: Double)? = nil
    @Published var fgColor: (r: Double, g: Double, b: Double, a: Double)? = nil

    init(type: ItemType, content: String, secondaryContent: String? = nil, id: String? = nil) {
        self.id = id ?? UUID().uuidString
        self.type = type
        self.content = content
        self.secondaryContent = secondaryContent
    }

    enum ItemType: Int, Codable {
        case text = 0
        case systemImage = 1
        case hstack = 2
        case imageFile = 3
        case vstack = 4
        case hstackContainer = 5
        case spacer = 6
        case lazyVGrid = 7
        case list = 8
        case button = 9
        case divider = 10
    }
}

@available(OSX 10.15, *)
func findVStackItem(in items: [VStackItem], id: String) -> VStackItem? {
    for item in items {
        if item.id == id {
            return item
        }
        if let found = findVStackItem(in: item.children, id: id) {
            return found
        }
    }
    return nil
}


@available(OSX 10.15, *)
class SwiftVStackState: ObservableObject {
    @Published var items: [VStackItem] = []
    @Published var scrollable: Bool = false
    @Published var red: Double = 0.5
    @Published var green: Double = 0.5
    @Published var blue: Double = 0.5
    @Published var alpha: Double = 0.5
    @Published var useInvertedColor: Bool = false
    @Published var fgRed: Double = 0.0
    @Published var fgGreen: Double = 0.0
    @Published var fgBlue: Double = 0.0
    @Published var fgAlpha: Double = 1.0
    @Published var spacing: Double = 12.0
    @Published var alignment: Int = 0
    // To track last item for property setting context (bg color etc) -> Should be safe if single-threaded main queue
    weak var lastItem: VStackItem? = nil
    
    @Published var gridColumns: [GridItemSpec]? = nil
    var onClick: ((Int) -> Void)?
    var onAction: ((String) -> Void)?
    
    @Published var selectedIndex: Int? = nil
    @Published var selectedId: String? = nil
}

@available(OSX 10.15, *)
struct RecursiveItemView: View {
    @ObservedObject var item: VStackItem
    var onClick: ((Int) -> Void)?
    var onAction: ((String) -> Void)?
    var index: Int
    var remoteIndex: Int? = nil // Propagate parent index (Row Index)
    var selectedIndex: Int? = nil // Propagate selection state

    private func getBackground() -> some View {
        Group {
            if let bg = item.bgColor {
                Color(red: bg.r, green: bg.g, blue: bg.b, opacity: bg.a)
            } else {
                Color.clear
            }
        }
    }

    var body: some View {
        Group {
            if item.type == .text {
                Text(item.content)
                    .padding(8)
                    .background(getBackground())
            } else if item.type == .systemImage {
                if #available(OSX 11.0, *) {
                    Image(systemName: item.content)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        // .padding(5) // Removed default padding
                        .background(getBackground())
                } else {
                    Text("Img: " + item.content)
                }
            } else if item.type == .imageFile {
                 if #available(OSX 10.15, *) {
                     if let nsImage = NSImage(contentsOfFile: item.content) {
                         Image(nsImage: nsImage)
                             .resizable()
                             .scaledToFit()
                             // .padding() // Removed default padding
                             .background(getBackground())
                     } else {
                         Text("Img error")
                     }
                 }
            } else if item.type == .hstack {
                HStack {
                    if #available(OSX 11.0, *) {
                        Image(systemName: item.secondaryContent ?? "")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    } else {
                        Text("I")
                    }
                    Text(item.content)
                        .font(.body)
                    Spacer()
                }
                .padding(8)
                .background(getBackground()) // Note: overwrites blue opacity from original if set?
                // .background(Color.blue.opacity(0.1)) // Keeping original logic or replacing?
                // Replacing with dynamic background if set
                .cornerRadius(8)
            } else if item.type == .vstack {
                VStack(alignment: .leading) {
                    ForEach(Array(item.children.enumerated()), id: \.element.id) { childIndex, child in
                        RecursiveItemView(item: child, onClick: onClick, onAction: onAction, index: childIndex, remoteIndex: remoteIndex ?? (index+1), selectedIndex: selectedIndex)
                    }
                }
                .background(getBackground())
                .cornerRadius(8)
            } else if item.type == .hstackContainer {
                HStack {
                    ForEach(Array(item.children.enumerated()), id: \.element.id) { childIndex, child in
                        RecursiveItemView(item: child, onClick: onClick, onAction: onAction, index: childIndex, remoteIndex: remoteIndex ?? (index+1), selectedIndex: selectedIndex)
                    }
                }
                .padding()
                .background(getBackground())
                .cornerRadius(10)
            } else if item.type == .spacer {
                Spacer()
            } else if item.type == .divider {
                // Force a visible block
                Rectangle().fill(Color.blue).frame(width: 5, height: 30)
            } else if item.type == .lazyVGrid {
                if #available(OSX 11.0, *) {
                    let columns = mapSpecsToGridItems(item.gridColumns ?? [])
                    LazyVGrid(columns: columns, spacing: 20) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(Array(item.children.enumerated()), id: \.element.id) { childIndex, child in
                             RecursiveItemView(item: child, onClick: onClick, onAction: onAction, index: childIndex, remoteIndex: remoteIndex ?? (index+1), selectedIndex: selectedIndex)
                        }
                    }
                    }
                    .padding()
                    .background(getBackground())
                } else {
                    Text("LazyVGrid req OSX 11+")
                }
            } else if item.type == .list {
                List {
                    ForEach(Array(item.children.enumerated()), id: \.element.id) { childIndex, child in
                        RecursiveItemView(item: child, onClick: onClick, onAction: onAction, index: childIndex, remoteIndex: remoteIndex ?? (index+1), selectedIndex: selectedIndex)
                    }
                }
            } else if item.type == .button {
                Text(item.content)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .foregroundColor(
                        item.fgColor.map { Color(red: $0.r, green: $0.g, blue: $0.b, opacity: $0.a) } ?? .white
                    )
                    .background(
                        Group {
                            if let bg = item.bgColor {
                                Color(red: bg.r, green: bg.g, blue: bg.b, opacity: bg.a)
                            } else {
                                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]), 
                                               startPoint: .top, endPoint: .bottom)
                            }
                        }
                    )
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    .simultaneousGesture(TapGesture().onEnded {
                        // print("DEBUG: [Swift] Button Tapped! ID: \(item.id)")
                        onAction?(item.id)
                    })
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded {
            let type = item.type
            if type == .text || type == .systemImage || type == .imageFile || type == .spacer || type == .hstack || type == .hstackContainer {
                if onAction == nil { }
                let effectiveIndex = remoteIndex ?? (index + 1)
                // print("DEBUG TAP: ...")
                onClick?(effectiveIndex)
                onAction?(item.id)
            }
        })
    }
}

@available(OSX 10.15, *)
struct SwiftVStackView: View {
    @ObservedObject var state: SwiftVStackState

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
    }

    var content: some View {
        let align: HorizontalAlignment
        switch state.alignment {
        case 1: align = .leading
        case 2: align = .trailing
        default: align = .center
        }

        return VStack(alignment: align, spacing: CGFloat(state.spacing)) {
            ForEach(Array(state.items.enumerated()), id: \.element.id) { index, item in
                 RecursiveItemView(item: item, onClick: state.onClick, onAction: state.onAction, index: index)
            }
        }
        .padding()
        // Forces the VStack to fill the available width, responding to alignment
        .frame(maxWidth: .infinity, alignment: Alignment(horizontal: align, vertical: .center))
    }
}

@objc(SwiftVStackLoader)
public class SwiftVStackLoader: NSObject {

    // Dictionary to store states by ID
    static var states: [String: SwiftVStackState] = [:]
    
    // Legacy support for older controls (SwiftGrid, SwiftZStack)
    public static var lastCreatedState: Any? = nil
    static weak var lastCreatedItem: VStackItem? = nil
    
    @objc(makeVStackWithIndex:callback:)
    public static func makeVStack(index: String, callback: @escaping (Int) -> Void) -> NSView {
         if #available(OSX 10.15, *) {
             let state = SwiftVStackState()
             state.onClick = callback
             
             // Register in dictionary
             states[index] = state 
             
             // Restore legacy global state for compatibility
             lastCreatedState = state
             lastCreatedItem = nil

             let view = SwiftVStackView(state: state)

             // Register
             if let intIndex = Int(index) {
                 ViewRegistry.register(view, for: intIndex)
             }

             let hostingView = NSHostingView(rootView: view)
             hostingView.translatesAutoresizingMaskIntoConstraints = false
             return hostingView
         } else {
             return NSView()
         }
    }

    // --- NEW METHODS (With RootID) ---

    @objc(setActionCallback:callback:)
    public static func setActionCallback(rootId: String, callback: @escaping (String) -> Void) {
        if #available(OSX 10.15, *) {
             if let state = states[rootId] {
                 state.onAction = callback
                 state.objectWillChange.send()
             }
        }
    }

    @objc(addItem:content:)
    public static func addItem(_ rootId: String, content: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = states[rootId] {
                    let newItem = VStackItem(type: .text, content: content)
                    state.items.append(newItem)
                    state.lastItem = newItem
                    state.objectWillChange.send()
                }
            }
        }
    }
    
    @objc(addTextItem:content:parentId:)
    public static func addTextItem(_ rootId: String, content: String, parentId: String?) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = states[rootId] {
                    let newItem = VStackItem(type: .text, content: content)
                    
                    if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                        parent.children.append(newItem)
                    } else {
                        state.items.append(newItem)
                    }
                    
                    state.lastItem = newItem
                    state.objectWillChange.send()
                }
            }
        }
    }

    @objc(addSpacerItem:parentId:)
    public static func addSpacerItem(_ rootId: String, parentId: String?) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = states[rootId] {
                    let newItem = VStackItem(type: .spacer, content: "")
                    
                    if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                        parent.children.append(newItem)
                    } else {
                        state.items.append(newItem)
                    }
                    
                    state.lastItem = newItem
                    state.objectWillChange.send()
                }
            }
        }
    }

    @objc(addSystemImage:systemName:)
    public static func addSystemImage(_ rootId: String, systemName: String) {
        addSystemImageItem(rootId, systemName: systemName, parentId: nil)
    }

    @objc(addSystemImageItem:systemName:parentId:)
    public static func addSystemImageItem(_ rootId: String, systemName: String, parentId: String?) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                let newItem = VStackItem(type: .systemImage, content: systemName, secondaryContent: nil)
                
                if let state = states[rootId] {
                     if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                         parent.children.append(newItem)
                     } else {
                         state.items.append(newItem)
                     }
                     state.lastItem = newItem
                     state.objectWillChange.send()
                }
            }
        }
    }

    @objc(addHStackItem:text:systemName:)
    public static func addHStackItem(_ rootId: String, text: String, systemName: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = states[rootId] {
                    let newItem = VStackItem(type: .hstack, content: text, secondaryContent: systemName)
                    state.items.append(newItem)
                    state.lastItem = newItem
                    state.objectWillChange.send()
                }
            }
        }
    }

    @objc(setScrollable:scrollable:)
    public static func setScrollable(_ rootId: String, scrollable: Bool) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = states[rootId] {
                    state.scrollable = scrollable
                }
            }
        }
    }

    @objc(setBackgroundColorRed:red:green:blue:alpha:)
    public static func setBackgroundColor(rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
         if #available(OSX 10.15, *) {
             DispatchQueue.main.async {
                  // If we have a last item, set ITS background color
                  if let state = states[rootId], let item = state.lastItem {
                      item.bgColor = (r: red, g: green, b: blue, a: alpha)
                      state.objectWillChange.send()
                  }
             }
         }
    }
    
    @objc(setForegroundColorRed:red:green:blue:alpha:)
    public static func setForegroundColor(rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
         if #available(OSX 10.15, *) {
             DispatchQueue.main.async {
                 if let state = states[rootId] {
                     state.fgRed = red
                     state.fgGreen = green
                     state.fgBlue = blue
                     state.fgAlpha = alpha
                 }
             }
         }
    }

    @objc(setSpacing:spacing:)
    public static func setSpacing(_ rootId: String, spacing: Double) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = states[rootId] {
                    state.spacing = spacing
                }
            }
        }
    }

    @objc(setAlignment:alignment:)
    public static func setAlignment(_ rootId: String, alignment: Int) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = states[rootId] {
                    state.alignment = alignment
                }
            }
        }
    }

    @objc(setInvertedColor:useInverted:)
    public static func setInvertedColor(_ rootId: String, useInverted: Bool) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = states[rootId] {
                    state.useInvertedColor = useInverted
                }
            }
        }
    }
    
    @objc(setLastItemId:id:)
    public static func setLastItemId(_ rootId: String, id: String) {
         if #available(OSX 10.15, *) {
             DispatchQueue.main.async {
                 if let state = states[rootId], let item = state.lastItem {
                     item.id = id
                     state.objectWillChange.send()
                 }
             }
         }
    }

    // Recursive Find
    private static func findItem(id: String, in items: [VStackItem]) -> VStackItem? {
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

    @objc(addVStackItem:dummy:parentId:)
    public static func addVStackItem(_ rootId: String, dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = VStackItem(type: .vstack, content: "")
             newItemId = newItem.id
             
             if let state = states[rootId] {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }

        if #available(OSX 10.15, *) {
            if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        }
        return newItemId
    }

    @objc(addHStackContainer:dummy:parentId:)
    public static func addHStackContainer(_ rootId: String, dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = VStackItem(type: .hstackContainer, content: "")
             newItemId = newItem.id
             
             if let state = states[rootId] {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }

        if #available(OSX 10.15, *) {
            if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        }
        return newItemId
    }

    @objc(addLazyVGrid:parentId:columnsJson:)
    public static func addLazyVGrid(_ rootId: String, parentId: String?, columnsJson: String) -> String {
        var newItemId = ""
        let block = {
             let newItem = VStackItem(type: .lazyVGrid, content: "")
             // Decode Columns
             if let data = columnsJson.data(using: .utf8),
                let specs = try? JSONDecoder().decode([GridItemSpec].self, from: data) {
                 newItem.gridColumns = specs
             }
             newItemId = newItem.id

             if let state = states[rootId] {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
                  state.objectWillChange.send()
             }
        }

        if #available(OSX 10.15, *) {
            if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        }
        return newItemId
    }

    @objc(addList:dummy:parentId:)
    public static func addList(_ rootId: String, dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = VStackItem(type: .list, content: "")
             newItemId = newItem.id
             
             if let state = states[rootId] {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }
        
        if #available(OSX 10.15, *) {
            if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        }
        return newItemId
    }

    @objc(addTextItem:text:parentId:)
    public static func addTextItem(_ rootId: String, text: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = VStackItem(type: .text, content: text)
             newItemId = newItem.id
             
             if let state = states[rootId] {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
                  state.objectWillChange.send()
             }
        }
        
        if #available(OSX 10.15, *) {
            if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        }
        return newItemId
    }
    
    @objc(addSpacer:dummy:parentId:)
    public static func addSpacer(_ rootId: String, dummy: String, parentId: String?) {
        if #available(OSX 10.15, *) {
             let block = {
                  let newItem = VStackItem(type: .spacer, content: "")
                  
                  if let state = states[rootId] {
                       state.lastItem = newItem
                       if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                           parent.children.append(newItem)
                       } else {
                           state.items.append(newItem)
                       }
                  }
             }
             if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        }
    }

    @objc(addDivider:dummy:parentId:)
    public static func addDivider(_ rootId: String, dummy: String, parentId: String?) {
        if #available(OSX 10.15, *) {
             let block = {
                 let newItem = VStackItem(type: .divider, content: "")
                 if let state = states[rootId] {
                     if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                         parent.children.append(newItem)
                     } else {
                         state.items.append(newItem)
                     }
                 }
             }
             if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        }
    }

    @objc(addButtonItem:text:parentId:)
    public static func addButtonItem(_ rootId: String, text: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = VStackItem(type: .button, content: text)
             newItemId = newItem.id
             
             if let state = states[rootId] {
                  state.lastItem = newItem
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }

        if #available(OSX 10.15, *) {
             if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        }
        return newItemId
    }

    @objc(setItem:id:red:green:blue:alpha:)
    public static func setItemBackgroundColor(rootId: String, id: String, red: Double, green: Double, blue: Double, alpha: Double) {
         if #available(OSX 10.15, *) {
             DispatchQueue.main.async {
                 if let state = states[rootId] {
                     if let item = findItem(id: id, in: state.items) {
                         item.bgColor = (red, green, blue, alpha)
                         state.objectWillChange.send()
                     }
                 }
             }
         }
    }

    @objc(addBatchToParent:parentId:json:)
    public static func addBatch(_ rootId: String, parentId: String?, json: String) -> String {
        guard #available(OSX 10.15, *) else { return "[]" }
        
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
            guard let state = states[rootId] else { return }
            

            
            let parentItem = (parentId != nil) ? findItem(id: parentId!, in: state.items) : nil
            
            for itemIn in batchItems {
                let newItemType = VStackItem.ItemType(rawValue: itemIn.type) ?? .text
                let newItem = VStackItem(type: newItemType, content: itemIn.content, secondaryContent: itemIn.secondaryContent)
                
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
            state.objectWillChange.send()
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
        if #available(OSX 10.15, *) {
             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                 state.onAction = callback
                 state.objectWillChange.send()
             }
        }
    }

    @objc(addItem:)
    public static func addItem(_ text: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                    state.items.append(VStackItem(type: .text, content: text, secondaryContent: nil))
                }
            }
        }
    }

    @objc(addSystemImage:)
    public static func addSystemImageLegacy(_ systemName: String) {
        // Renamed to avoid selector conflict? No, selector is addSystemImage: vs addSystemImage:systemName:
        // C function calls 'addSystemImage:' for Legacy, 'addSystemImage:systemName:' for New.
        // Wait, C function SWIFTVSTACKADDSYSTEMIMAGE calls `addSystemImage:` with name in Legacy.
        // In my new SwiftVStack.m, it calls `addSystemImage:systemName:`.
        // So this Legacy method is ONLY for OLD C functions if any exist.
        addSystemImageItemLegacy(systemName, parentId: nil)
    }

    @objc(addSystemImageItem:parentId:)
    public static func addSystemImageItemLegacy(_ systemName: String, parentId: String?) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                let newItem = VStackItem(type: .systemImage, content: systemName, secondaryContent: nil)
                
                if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                     if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                         parent.children.append(newItem)
                     } else {
                         state.items.append(newItem)
                     }
                } else if let state = SwiftZStackLoader.lastCreatedState as? SwiftZStackState {
                     if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                         parent.children.append(newItem)
                         state.objectWillChange.send()
                     } else {
                         state.items.append(newItem)
                     }
                }
            }
        }
    }

    @objc(addHStackItem:systemName:)
    public static func addHStackItemLegacy(_ text: String, systemName: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                    let newItem = VStackItem(type: .hstack, content: text, secondaryContent: systemName)
                    state.items.append(newItem)
                    lastCreatedItem = newItem
                }
            }
        }
    }

    @objc(setScrollable:)
    public static func setScrollableLegacy(_ scrollable: Bool) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                    state.scrollable = scrollable
                }
            }
        }
    }

    @objc(setBackgroundColorRed:green:blue:alpha:)
    public static func setBackgroundColorLegacy(red: Double, green: Double, blue: Double, alpha: Double) {
         if #available(OSX 10.15, *) {
             DispatchQueue.main.async {
                  // If we have a last item, set ITS background color
                  if let item = lastCreatedItem {
                      item.bgColor = (r: red, g: green, b: blue, a: alpha)
                      if let state = lastCreatedState as? SwiftZStackState { state.objectWillChange.send() }
                  } 
             }
         }
    }

    @objc(setSpacing:)
    public static func setSpacingLegacy(_ spacing: Double) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                    state.spacing = spacing
                }
            }
        }
    }

    @objc(setAlignment:)
    public static func setAlignmentLegacy(_ alignment: Int) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                    state.alignment = alignment
                }
            }
        }
    }

    @objc(setInvertedColor:)
    public static func setInvertedColorLegacy(_ useInverted: Bool) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                    state.useInvertedColor = useInverted
                }
            }
        }
    }
    
    @objc(setLastItemId:)
    public static func setLastItemIdLegacy(_ id: String) {
         if #available(OSX 10.15, *) {
             DispatchQueue.main.async {
                 if let item = lastCreatedItem {
                     item.id = id
                     // Force update
                     if let state = lastCreatedState as? SwiftZStackState {
                         state.objectWillChange.send()
                     } else if let state = lastCreatedState as? SwiftVStackState {
                         state.objectWillChange.send()
                     }
                 }
             }
         }
    }

    @objc(addVStackItem:parentId:)
    public static func addVStackItemLegacy(_ dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = VStackItem(type: .vstack, content: "")
             newItemId = newItem.id
             lastCreatedItem = newItem

             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             } else if let state = SwiftZStackLoader.lastCreatedState as? SwiftZStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }

        if #available(OSX 10.15, *) {
            if Thread.isMainThread {
                block()
            } else {
                DispatchQueue.main.sync {
                    block()
                }
            }
        }
        return newItemId
    }

    @objc(addHStackContainer:parentId:)
    public static func addHStackContainerLegacy(_ dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = VStackItem(type: .hstackContainer, content: "")
             newItemId = newItem.id
             lastCreatedItem = newItem

             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             } else if let state = SwiftZStackLoader.lastCreatedState as? SwiftZStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }

        if #available(OSX 10.15, *) {
            if Thread.isMainThread {
                block()
            } else {
                DispatchQueue.main.sync {
                    block()
                }
            }
        }
        return newItemId
    }

    @objc(addLazyVGrid:columnsJson:)
    public static func addLazyVGridLegacy(parentId: String?, columnsJson: String) -> String {
        var newItemId = ""
        let block = {
             let newItem = VStackItem(type: .lazyVGrid, content: "")
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
                  state.objectWillChange.send()
             } else if let state = SwiftZStackLoader.lastCreatedState as? SwiftZStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
                  state.objectWillChange.send()
             }
        }

        if #available(OSX 10.15, *) {
            if Thread.isMainThread {
                block()
            } else {
                DispatchQueue.main.sync {
                    block()
                }
            }
        }
        return newItemId
    }

    @objc(addList:parentId:)
    public static func addListLegacy(_ dummy: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = VStackItem(type: .list, content: "")
             newItemId = newItem.id
             lastCreatedItem = newItem
             
             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             } else if let state = SwiftZStackLoader.lastCreatedState as? SwiftZStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             }
        }
        
        if #available(OSX 10.15, *) {
            if Thread.isMainThread {
                block()
            } else {
                DispatchQueue.main.sync {
                    block()
                }
            }
        }
        return newItemId
    }

    @objc(addTextItem:parentId:)
    public static func addTextItemLegacy(_ text: String, parentId: String?) -> String {
        var newItemId = ""
        let block = {
             let newItem = VStackItem(type: .text, content: text)
             newItemId = newItem.id
             lastCreatedItem = newItem

             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
                  state.objectWillChange.send()
             } else if let state = SwiftZStackLoader.lastCreatedState as? SwiftZStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
                  state.objectWillChange.send()
             }
        }
        
        if #available(OSX 10.15, *) {
            if Thread.isMainThread {
                block()
            } else {
                DispatchQueue.main.sync {
                    block()
                }
            }
        }
        return newItemId
    }
    
    @objc(addSpacer:parentId:)
    public static func addSpacerLegacy(_ dummy: String, parentId: String?) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                 let newItem = VStackItem(type: .spacer, content: "")
                 lastCreatedItem = newItem
                 
                 if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                      if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                          parent.children.append(newItem)
                      } else {
                          state.items.append(newItem)
                      }
                 } else if let state = SwiftZStackLoader.lastCreatedState as? SwiftZStackState {
                      if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                          parent.children.append(newItem)
                          state.objectWillChange.send()
                      } else {
                          state.items.append(newItem)
                      }
                 }
            }
        }
    }

    @objc(addDivider:parentId:)
    public static func addDividerLegacy(_ dummy: String, parentId: String?) {
        // print("DEBUG: [Swift] addDivider called. Parent: \(parentId ?? "nil")")
        if #available(OSX 10.15, *) {
             let block = {
                 let newItem = VStackItem(type: .divider, content: "")
                 if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                     if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                         print("DEBUG: [Swift] Parent found. Appending divider.")
                         parent.children.append(newItem)
                     } else {
                         print("DEBUG: [Swift] Parent NOT found. Appending to root.")
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
    }

    @objc(addButtonItem:parentId:)
    public static func addButtonItemLegacy(_ text: String, parentId: String?) -> String {
        // print("DEBUG: [Swift] addButtonItem called for '\(text)'")
        var newItemId = ""
        let block = {
             let newItem = VStackItem(type: .button, content: text)
             newItemId = newItem.id
             lastCreatedItem = newItem
             // print("DEBUG: [Swift] Created button with ID: \(newItemId)")
             
             if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                  } else {
                      state.items.append(newItem)
                  }
             } else if let state = SwiftZStackLoader.lastCreatedState as? SwiftZStackState {
                  if let pId = parentId, let parent = findItem(id: pId, in: state.items) {
                      parent.children.append(newItem)
                      state.objectWillChange.send()
                  } else {
                      state.items.append(newItem)
                  }
             }
        }

        if #available(OSX 10.15, *) {
             if Thread.isMainThread {
                 block()
             } else {
                 DispatchQueue.main.sync {
                     block()
                 }
             }
        }
        return newItemId
    }

    @objc(setItem:backgroundColorRed:green:blue:alpha:)
    public static func setItemBackgroundColorLegacy(id: String, red: Double, green: Double, blue: Double, alpha: Double) {
         if #available(OSX 10.15, *) {
             DispatchQueue.main.async {
                 if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                     if let item = findItem(id: id, in: state.items) {
                         item.bgColor = (red, green, blue, alpha)
                     }
                 } else if let state = SwiftZStackLoader.lastCreatedState as? SwiftZStackState {
                     if let item = findItem(id: id, in: state.items) {
                         item.bgColor = (red, green, blue, alpha)
                         state.objectWillChange.send() 
                     }
                 }
             }
         }
    }

    @objc(addBatchToParent:json:)
    public static func addBatchLegacy(parentId: String?, json: String) -> String {
        guard #available(OSX 10.15, *) else { return "[]" }
        
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
                let newItemType = VStackItem.ItemType(rawValue: itemIn.type) ?? .text
                let newItem = VStackItem(type: newItemType, content: itemIn.content, secondaryContent: itemIn.secondaryContent)
                
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
            state.objectWillChange.send()
        }
        
        if let encoded = try? JSONEncoder().encode(newIds), let jsonString = String(data: encoded, encoding: .utf8) {
            return jsonString
        }
        return "[]"
    }

}
