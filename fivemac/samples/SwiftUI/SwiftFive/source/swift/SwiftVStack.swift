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
    @Published var gridColumns: [GridItemSpec]? = nil
    var onClick: ((Int) -> Void)?
    var onAction: ((String) -> Void)?
}

@available(OSX 10.15, *)
struct RecursiveItemView: View {
    @ObservedObject var item: VStackItem
    var onClick: ((Int) -> Void)?
    var onAction: ((String) -> Void)?
    var index: Int

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
                        RecursiveItemView(item: child, onClick: onClick, onAction: onAction, index: childIndex)
                    }
                }
                .background(getBackground())
                .cornerRadius(8)
            } else if item.type == .hstackContainer {
                HStack {
                    ForEach(Array(item.children.enumerated()), id: \.element.id) { childIndex, child in
                        RecursiveItemView(item: child, onClick: onClick, onAction: onAction, index: childIndex)
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
                        ForEach(Array(item.children.enumerated()), id: \.element.id) { childIndex, child in
                             RecursiveItemView(item: child, onClick: onClick, onAction: onAction, index: childIndex)
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
                        RecursiveItemView(item: child, onClick: onClick, onAction: onAction, index: childIndex)
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
        // Only apply onTapGesture to PASSIVE LEAF items.
        // Exclude containers (.vstack, .hstack, .hstackContainer) and interactive items (.button, .list, .lazyVGrid)
        // Use simultaneousGesture to ensure clicks work inside ScrollViews/Lists
        .simultaneousGesture(TapGesture().onEnded {
            let type = item.type
            if type == .text || type == .systemImage || type == .imageFile || type == .spacer {
                if onAction == nil { }
                onClick?(index + 1)
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

    static var lastCreatedState: Any? = nil
    static weak var lastCreatedItem: VStackItem? = nil

    @objc(makeVStackWithIndex:callback:)
    public static func makeVStack(index: Int, callback: @escaping (Int) -> Void) -> NSView {
         if #available(OSX 10.15, *) {
             let state = SwiftVStackState()
             state.onClick = callback
             lastCreatedState = state
             lastCreatedItem = nil

             let view = SwiftVStackView(state: state)

             // Register
             ViewRegistry.register(view, for: index)

             let hostingView = NSHostingView(rootView: view)
             return hostingView
         } else {
             return NSView()
         }
    }



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
    public static func addSystemImage(_ systemName: String) {
        addSystemImageItem(systemName, parentId: nil)
    }

    @objc(addSystemImageItem:parentId:)
    public static func addSystemImageItem(_ systemName: String, parentId: String?) {
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
    public static func addHStackItem(_ text: String, systemName: String) {
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
    public static func setScrollable(_ scrollable: Bool) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                    state.scrollable = scrollable
                }
            }
        }
    }

    @objc(setBackgroundColorRed:green:blue:alpha:)
    public static func setBackgroundColor(red: Double, green: Double, blue: Double, alpha: Double) {
         if #available(OSX 10.15, *) {
             DispatchQueue.main.async {
                 // If we have a last item, set ITS background color
                  if let item = lastCreatedItem {
                      item.bgColor = (r: red, g: green, b: blue, a: alpha)
                      if let state = lastCreatedState as? SwiftZStackState { state.objectWillChange.send() }
                  } else if lastCreatedState is SwiftVStackState {
                     // Check if items empty, maybe set VStack bg? Or item bg?
                     // Previous logic: if state.items not empty ...
                     // Assuming this sets the LAST ITEM color if exists, else invalid?
                     // Or maybe it sets the VStack background?
                     // Currently sticking to Item modification for consistency with Harbour API usually targeting "last item" context.
                  }
             }
         }
    }

    @objc(setSpacing:)
    public static func setSpacing(_ spacing: Double) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                    state.spacing = spacing
                }
            }
        }
    }

    @objc(setAlignment:)
    public static func setAlignment(_ alignment: Int) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                    state.alignment = alignment
                }
            }
        }
    }

    @objc(setInvertedColor:)
    public static func setInvertedColor(_ useInverted: Bool) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = SwiftVStackLoader.lastCreatedState as? SwiftVStackState {
                    state.useInvertedColor = useInverted
                }
            }
        }
    }
    
    @objc(setLastItemId:)
    public static func setLastItemId(_ id: String) {
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

    @objc(addVStackItem:parentId:)
    public static func addVStackItem(_ dummy: String, parentId: String?) -> String {
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
    public static func addHStackContainer(_ dummy: String, parentId: String?) -> String {
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
    public static func addLazyVGrid(parentId: String?, columnsJson: String) -> String {
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
    public static func addList(_ dummy: String, parentId: String?) -> String {
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
    public static func addTextItem(_ text: String, parentId: String?) -> String {
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
    public static func addSpacer(_ dummy: String, parentId: String?) {
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
    public static func addDivider(_ dummy: String, parentId: String?) {
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
    public static func addButtonItem(_ text: String, parentId: String?) -> String {
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
    public static func setItemBackgroundColor(id: String, red: Double, green: Double, blue: Double, alpha: Double) {
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
    public static func addBatch(parentId: String?, json: String) -> String {
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
        
        var createdIds: [String] = []
        
        let block = {
            if let state = lastCreatedState as? SwiftVStackState {
                // If parentId is provided and NOT "nil" / empty, find the parent
                if let pid = parentId, !pid.isEmpty, pid != "nil" {
                    if let parent = findItem(id: pid, in: state.items) {
                        for item in batchItems {
                            let newItem = VStackItem(type: VStackItem.ItemType(rawValue: item.type) ?? .text,
                                                   content: item.content,
                                                   secondaryContent: item.secondaryContent)
                            if let b = item.bg { newItem.bgColor = (b.r, b.g, b.b, b.a) }
                            if let f = item.fg { newItem.fgColor = (f.r, f.g, f.b, f.a) }
                            parent.children.append(newItem)
                            createdIds.append(newItem.id)
                        }
                        state.objectWillChange.send()
                    }
                } else {
                    // Add to root
                    for item in batchItems {
                        let newItem = VStackItem(type: VStackItem.ItemType(rawValue: item.type) ?? .text,
                                               content: item.content,
                                               secondaryContent: item.secondaryContent)
                        if let b = item.bg { newItem.bgColor = (b.r, b.g, b.b, b.a) }
                        if let f = item.fg { newItem.fgColor = (f.r, f.g, f.b, f.a) }
                        state.items.append(newItem)
                        createdIds.append(newItem.id)
                    }
                    state.objectWillChange.send()
                }
            } else if let state = SwiftZStackLoader.lastCreatedState as? SwiftZStackState {
                 // Support adding to ZStack from here if needed (fallback)
                 if let pid = parentId, !pid.isEmpty, pid != "nil" {
                    if let parent = findItem(id: pid, in: state.items) {
                        for item in batchItems {
                            let newItem = VStackItem(type: VStackItem.ItemType(rawValue: item.type) ?? .text,
                                                   content: item.content,
                                                   secondaryContent: item.secondaryContent)
                            if let b = item.bg { newItem.bgColor = (b.r, b.g, b.b, b.a) }
                            if let f = item.fg { newItem.fgColor = (f.r, f.g, f.b, f.a) }
                            parent.children.append(newItem)
                            createdIds.append(newItem.id)
                        }
                        state.objectWillChange.send()
                    }
                } else {
                    for item in batchItems {
                        let newItem = VStackItem(type: VStackItem.ItemType(rawValue: item.type) ?? .text,
                                               content: item.content,
                                               secondaryContent: item.secondaryContent)
                        if let b = item.bg { newItem.bgColor = (b.r, b.g, b.b, b.a) }
                        if let f = item.fg { newItem.fgColor = (f.r, f.g, f.b, f.a) }
                        state.items.append(newItem)
                        createdIds.append(newItem.id)
                    }
                    state.objectWillChange.send()
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
        
        let encoder = JSONEncoder()
        if let idData = try? encoder.encode(createdIds),
           let idString = String(data: idData, encoding: .utf8) {
            return idString
        }
        
        return "[]"
    }
}




