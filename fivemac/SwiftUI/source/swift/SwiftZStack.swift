
import SwiftUI
import AppKit

@available(OSX 10.15, *)
class SwiftZStackState: ObservableObject {
    @Published var items: [VStackItem] = [] // Reusing VStackItem for simplicity (Text, SystemImage, HStack)
    @Published var alignment: Int = 0 
    // Alignment mapping: 
    // 0: center (default)
    // 1: topLeading
    // 2: top
    // 3: topTrailing
    // 4: leading
    // 5: trailing
    // 6: bottomLeading
    // 7: bottom
    // 8: bottomTrailing
    
    // Background Color
    @Published var red: Double = 0.5
    @Published var green: Double = 0.5
    @Published var blue: Double = 0.5
    @Published var alpha: Double = 0.5
    
    // Foreground Color
    @Published var fgRed: Double = 0.0
    @Published var fgGreen: Double = 0.0
    @Published var fgBlue: Double = 0.0
    @Published var fgAlpha: Double = 1.0

    var onAction: ((String) -> Void)? = nil
}

@available(OSX 10.15, *)
struct SwiftZStackView: View {
    @ObservedObject var state: SwiftZStackState
    
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
              ForEach(Array(state.items.enumerated()), id: \.element.id) { index, item in
                   RecursiveItemView(item: item, onAction: state.onAction, index: index)
              }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill container
        .background(
            Color(red: state.red, green: state.green, blue: state.blue, opacity: state.alpha)
        )
        .cornerRadius(10)
    }
}

@objc(SwiftZStackLoader)
public class SwiftZStackLoader: NSObject {
    
    static var states: [String: SwiftZStackState] = [:]

    @objc(makeZStackWithIndex:actionCallback:)
    public static func makeZStack(index: String, actionCallback: @escaping (String) -> Void) -> NSView {
         if #available(OSX 10.15, *) {
             let state = SwiftZStackState()
             state.onAction = actionCallback
             states[index] = state
             
             let view = SwiftZStackView(state: state)
             
             let hostingView = NSHostingView(rootView: view)
             return hostingView
         } else {
             return NSView()
         }
    }
    
    @objc(addItem:content:)
    public static func addItem(_ rootId: String, text: String) -> String {
        var newItemId = ""
        if #available(OSX 10.15, *) {
             let block = {
                  if let state = states[rootId] {
                      let newItem = VStackItem(type: .text, content: text, secondaryContent: nil)
                      newItemId = newItem.id
                      state.items.append(newItem)
                      state.objectWillChange.send()
                  }
             }
             
            if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        }
        return newItemId
    }
    
    @objc(addSystemImage:systemName:)
    public static func addSystemImage(_ rootId: String, systemName: String) -> String {
        var newItemId = ""
        if #available(OSX 10.15, *) {
             let block = {
                  if let state = states[rootId] {
                     let newItem = VStackItem(type: .systemImage, content: systemName, secondaryContent: nil)
                     newItemId = newItem.id
                     state.items.append(newItem)
                     state.objectWillChange.send()
                  }
             }
             
            if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        }
        return newItemId
    }

    @objc(addFileImage:filePath:)
    public static func addFileImage(_ rootId: String, filePath: String) -> String {
        var newItemId = ""
        if #available(OSX 10.15, *) {
             let block = {
                  if let state = states[rootId] {
                     let newItem = VStackItem(type: .imageFile, content: filePath, secondaryContent: nil)
                     newItemId = newItem.id
                     state.items.append(newItem)
                     state.objectWillChange.send()
                  }
             }
             
            if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        }
        return newItemId
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
    
    @objc(setBackgroundColor:red:green:blue:alpha:)
    public static func setBackgroundColor(_ rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
         if #available(OSX 10.15, *) {
             DispatchQueue.main.async {
                 if let state = states[rootId] {
                     state.red = red
                     state.green = green
                     state.blue = blue
                     state.alpha = alpha
                 }
             }
         }
    }
    
    @objc(setForegroundColor:red:green:blue:alpha:)
    public static func setForegroundColor(_ rootId: String, red: Double, green: Double, blue: Double, alpha: Double) {
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
    
    @objc(removeAllItems:)
    public static func removeAllItems(_ rootId: String) {
        if #available(OSX 10.15, *) {
             let block = {
                  if let state = states[rootId] {
                      state.items.removeAll()
                  }
             }
             if Thread.isMainThread { block() } else { DispatchQueue.main.sync { block() } }
        }
    }

    @objc(addBatch:parentId:json:)
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
        
        var createdIds: [String] = []
        
        let block = {
            if let state = states[rootId] {
                if let pid = parentId, !pid.isEmpty, pid != "nil" {
                    if let parent = findVStackItem(in: state.items, id: pid) {
                        for item in batchItems {
                            let newItem = VStackItem(type: VStackItem.ItemType(rawValue: item.type) ?? .text,
                                                   content: item.content,
                                                   secondaryContent: item.secondaryContent)
                            if let bgColors = item.bg {
                                newItem.bgColor = (bgColors.r, bgColors.g, bgColors.b, bgColors.a)
                            }
                            if let fgColors = item.fg {
                                newItem.fgColor = (fgColors.r, fgColors.g, fgColors.b, fgColors.a)
                            }
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
                        if let bgColors = item.bg {
                            newItem.bgColor = (bgColors.r, bgColors.g, bgColors.b, bgColors.a)
                        }
                        if let fgColors = item.fg {
                            newItem.fgColor = (fgColors.r, fgColors.g, fgColors.b, fgColors.a)
                        }
                        state.items.append(newItem)
                        createdIds.append(newItem.id)
                    }
                    state.objectWillChange.send()
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
}
