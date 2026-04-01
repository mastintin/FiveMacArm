import SwiftUI
import AppKit
import Observation
import HarbourMacro

@Observable
public class PickerState {
    var items: [String]
    var selection: String
    var isGlass: Bool
    var showLabel: Bool
    var placeholder: String
    var title: String
    var accentColor: Color = .blue
    var textColor: Color = .primary
    
    init(items: [String] = [], selection: String = "", isGlass: Bool = false, showLabel: Bool = true, title: String = "", placeholder: String = "Seleccionar...") {
        self.items = items
        self.selection = selection
        self.isGlass = isGlass
        self.showLabel = showLabel
        self.title = title
        self.placeholder = placeholder
    }
}

struct SwiftPickerView: View {
    var state: PickerState
    var callback: ((String) -> Void)?
    
    @State private var isPopoverPresented = false
    @State private var searchText = ""

    var filteredItems: [String] {
        if searchText.isEmpty {
            return state.items
        } else {
            return state.items.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        let selectionBinding = Binding(
            get: { state.selection },
            set: { state.selection = $0 }
        )
        
        if #available(macOS 14.0, *) {
             Button(action: {
                 isPopoverPresented.toggle()
             }) {
                  HStack {
                      if state.showLabel && !state.title.isEmpty {
                          Text(state.title + ":")
                              .font(.subheadline)
                              .foregroundColor(.secondary)
                      }
                      
                      Text(state.selection.isEmpty ? state.placeholder : state.selection)
                          .foregroundColor(state.selection.isEmpty ? .secondary : state.textColor)
                      
                      Spacer()
                     Image(systemName: "chevron.up.chevron.down")
                         .font(.caption)
                         .foregroundColor(.secondary)
                 }
                 .padding(.horizontal, 10)
                 .padding(.vertical, 5)
                 .background(Color(NSColor.controlBackgroundColor))
                 .cornerRadius(5)
                 .overlay(
                     RoundedRectangle(cornerRadius: 5)
                         .stroke(Color(NSColor.controlColor), lineWidth: 1)
                 )
             }
             .buttonStyle(.plain)
             .popover(isPresented: $isPopoverPresented, arrowEdge: .bottom) {
                 VStack(spacing: 0) {
                     TextField("Buscar...", text: $searchText)
                         .textFieldStyle(.plain)
                         .padding(8)
                         .background(Color(NSColor.controlBackgroundColor))
                     
                     Divider()
                     
                     List(filteredItems, id: \.self) { item in
                         Button(action: {
                             state.selection = item
                             callback?(item)
                             isPopoverPresented = false
                         }) {
                             HStack {
                                 Text(item)
                                 Spacer()
                                 if state.selection == item {
                                     Image(systemName: "checkmark")
                                         .foregroundColor(state.accentColor)
                                 }
                             }
                             .contentShape(Rectangle())
                         }
                         .buttonStyle(.plain)
                         .padding(.vertical, 4)
                     }
                     .listStyle(.plain)
                     .frame(height: 200) 
                 }
                 .frame(width: 250)
                 .modify { view in
                    if state.isGlass {
                        if #available(macOS 26.0, *) {
                            view.glassEffect()
                        } else {
                            view
                        }
                    } else {
                        view
                    }
                 }
             }
             .modify { view in
                 if state.isGlass {
                     if #available(macOS 26.0, *) {
                         view.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 8))
                     } else {
                         view
                     }
                 } else {
                     view
                 }
             }
        } else {
             Picker(state.title, selection: selectionBinding) {
                ForEach(state.items, id: \.self) { item in
                    Text(item).tag(item)
                }
            }
            .pickerStyle(PopUpButtonPickerStyle())
        }
    }
}

@objc(SwiftPickerLoader)
public class SwiftPickerLoader: NSObject {
    
    public static var states: [String: PickerState] = [:]

    public static func makePicker(title: String, items: [String], id: String, callback: ((String) -> Void)?) -> NSView {
         let state = PickerState(items: items, selection: items.first ?? "", title: title)
         states[id] = state
         
         let view = SwiftPickerView(state: state, callback: callback)
         ViewRegistry.register(view, for: id)
         
         let hostingView = NSHostingView(rootView: view)
         hostingView.sizingOptions = []
         hostingView.translatesAutoresizingMaskIntoConstraints = false
         return hostingView
    }

    public static func destroyPicker(id: String, viewPtr: Int64) {
        states.removeValue(forKey: id)
        ViewRegistry.clean(id: id)
        
        if viewPtr != 0 {
            if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
                _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }
}

// --- HARBOUR DIRECT BRIDGES ---

@HarbourDirect
public func pkr_set_selection(id: String, selection: String) {
    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.selection = selection
        }
    }
}

@HarbourDirect
public func pkr_set_glass(id: String, isGlass: Bool) {
    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.isGlass = isGlass
        }
    }
}

@HarbourDirect
public func pkr_set_show_label(id: String, show: Bool) {
    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.showLabel = show
        }
    }
}

@HarbourDirect
public func pkr_set_title(id: String, title: String) {
    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.title = title
        }
    }
}

@HarbourDirect
public func pkr_set_colors(id: String, accentHex: String, textHex: String) {
    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.accentColor = Color(hex: accentHex)
            state.textColor = Color(hex: textHex)
        }
    }
}

@HarbourDirect
public func pkr_get_selection(id: String) -> String {
    return SwiftPickerLoader.states[id]?.selection ?? ""
}

@HarbourDirect
public func pkr_set_placeholder(id: String, placeholder: String) {
    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.placeholder = placeholder
        }
    }
}

@HarbourDirect
public func pkr_set_array(id: String, items: [String]) {
    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.items = items
            if !items.contains(state.selection) {
                state.selection = items.first ?? ""
            }
        }
    }
}

@HarbourDirect
public func pkr_set_array(id: String, items: [String]) {
    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.items = items
            if !items.contains(state.selection) {
                state.selection = items.first ?? ""
            }
        }
    }
}

@HarbourDirect
public func pkr_set_items(id: String, json: String) {
    var items: [String] = []

    if let data = json.data(using: .utf8) {
        if let decoded = try? JSONDecoder().decode([String].self, from: data) {
            items = decoded
        }
    }

    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.items = items
            if !items.contains(state.selection) {
                state.selection = items.first ?? ""
            }
        }
    }
}

@HarbourDirect
public func pkr_destroy(id: String, viewPtr: Int64) {
    SwiftPickerLoader.destroyPicker(id: id, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_picker_create(
    top: Double,
    left: Double,
    width: Double,
    height: Double,
    itemsJson: String,
    parentPtr: Int64,
    title: String,
    id: String
) -> Int64 {
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        
        var items: [String] = []
        if let data = itemsJson.data(using: .utf8) {
            items = (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }

        let callback: (String) -> Void = { newValue in
            let sendToHarbour = {
                if let pDynSym = hb_dynsymFindName("SWIFTPICKERONCHANGE") {
                    hb_vmPushSymbol(hb_dynsymSymbol(pDynSym))
                    hb_vmPushNil()
                    hb_vmPushString(id)
                    hb_vmPushString(newValue)
                    hb_vmDo(2)
                }
            }
            
            if Thread.isMainThread {
                sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }

        let pickerView = SwiftPickerLoader.makePicker(
            title: title,
            items: items,
            id: id,
            callback: callback
        )
        
        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: pickerView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(pickerView).toOpaque()
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
