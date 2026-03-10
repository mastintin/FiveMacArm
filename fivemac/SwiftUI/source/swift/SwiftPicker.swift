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
    var title: String
    var accentColor: Color = .blue
    var textColor: Color = .primary
    
    init(items: [String] = [], selection: String = "", isGlass: Bool = false, showLabel: Bool = true, title: String = "") {
        self.items = items
        self.selection = selection
        self.isGlass = isGlass
        self.showLabel = showLabel
        self.title = title
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
                     if state.showLabel {
                        Text(!state.title.isEmpty ? state.title : state.selection)
                             .foregroundColor(state.selection.isEmpty ? .secondary : state.textColor)
                     } else {
                          Text(state.selection)
                             .foregroundColor(state.textColor)
                     }
                     
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

    @objc(makePickerWithTitle:items:id:index:callback:)
    public static func makePicker(title: String, items: [String], id: String, index: Int, callback: ((String) -> Void)?) -> NSView {
         let state = PickerState(items: items, selection: items.first ?? "", title: title)
         let key = id.isEmpty ? String(index) : id
         SwiftPickerLoader.states[key] = state
         
         let action: (String) -> Void = { newValue in
             _ = callback?(newValue)
         }
         
         let view = SwiftPickerView(state: state, callback: action)
         ViewRegistry.register(view, for: index)
         
         let hostingView = NSHostingView(rootView: view)
         hostingView.translatesAutoresizingMaskIntoConstraints = false
         return hostingView
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourBridge
public func pkr_set_selection(id: String, selection: String) {
    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.selection = selection
        }
    }
}

@HarbourBridge
public func pkr_set_glass(id: String, isGlass: String) {
    let glass = (isGlass == "1" || isGlass.lowercased() == "true")
    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.isGlass = glass
        }
    }
}

@HarbourBridge
public func pkr_set_show_label(id: String, show: String) {
    let showLabel = (show == "1" || show.lowercased() == "true")
    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.showLabel = showLabel
        }
    }
}

@HarbourBridge
public func pkr_set_title(id: String, title: String) {
    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.title = title
        }
    }
}

@HarbourBridge
public func pkr_set_colors(id: String, accentHex: String, textHex: String) {
    DispatchQueue.main.async {
        if let state = SwiftPickerLoader.states[id] {
            state.accentColor = Color(hex: accentHex)
            state.textColor = Color(hex: textHex)
        }
    }
}

@HarbourBridge
@discardableResult
public func pkr_get_selection(id: String) -> String {
    return SwiftPickerLoader.states[id]?.selection ?? ""
}

// Special case for items as it's an array
@objc(SwiftPickerActions)
public class SwiftPickerActions: NSObject {
    @objc public static func setItems(id: String, items: [String]) {
         DispatchQueue.main.async {
             if let state = SwiftPickerLoader.states[id] {
                 state.items = items
                 if !items.contains(state.selection) {
                     state.selection = items.first ?? ""
                 }
             }
         }
    }
    
    @objc public static func getSelection(id: String) -> String {
        return SwiftPickerLoader.states[id]?.selection ?? ""
    }
}
