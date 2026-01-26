import SwiftUI
import AppKit

@available(OSX 10.15, *)
@available(OSX 10.15, *)
class PickerState: ObservableObject {
    @Published var items: [String]
    @Published var selection: String
    @Published var isGlass: Bool
    @Published var showLabel: Bool
    @Published var title: String
    
    init(items: [String] = [], selection: String = "", isGlass: Bool = false, showLabel: Bool = true, title: String = "") {
        self.items = items
        self.selection = selection
        self.isGlass = isGlass
        self.showLabel = showLabel
        self.title = title
    }
}

@available(OSX 10.15, *)
struct SwiftPickerView: View {
    @ObservedObject var state: PickerState
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
        if #available(macOS 26.2, *) {
             Button(action: {
                 isPopoverPresented.toggle()
             }) {
                 HStack {
                     if state.showLabel {
                        Text(!state.title.isEmpty ? state.title : state.selection)
                             .foregroundColor(state.selection.isEmpty ? .secondary : .primary)
                     } else {
                         Text(state.selection)
                             .foregroundColor(.primary)
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
                                         .foregroundColor(.blue)
                                 }
                             }
                             .contentShape(Rectangle())
                         }
                         .buttonStyle(.plain)
                         .padding(.vertical, 4)
                     }
                     .listStyle(.plain)
                     .frame(height: 200) // Fixed height to ensure scrolling
                 }
                 .frame(width: 250)
                 .modify { view in
                    if state.isGlass {
                        view.glassEffect()
                    } else {
                        view
                    }
                 }
             }
             .modify { view in
                 if state.isGlass {
                     view
                         .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 8))
                 } else {
                     view
                 }
             }
        } else {
             // Fallback for older macOS
             Picker(state.title, selection: $state.selection) {
                ForEach(state.items, id: \.self) { item in
                    Text(item).tag(item)
                }
            }
            .pickerStyle(PopUpButtonPickerStyle())
        }
    }
}

extension View {
    func modify<Content: View>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}

@objc(SwiftPickerLoader)
public class SwiftPickerLoader: NSObject {
    
    static var states: [String: PickerState] = [:]

    @objc(makePickerWithTitle:items:index:callback:)
    public static func makePicker(title: String, items: [String], index: Int, callback: ((String) -> Void)?) -> NSView {
         if #available(OSX 10.15, *) {
             let state = PickerState(items: items, selection: items.first ?? "", title: title)
             let key = String(index)
             states[key] = state
             
             let action: (String) -> Void = { newValue in
                 _ = callback?(newValue)
             }
             
             let view = SwiftPickerView(state: state, callback: action)
             ViewRegistry.register(view, for: index)
             
             let hostingView = NSHostingView(rootView: view)
             hostingView.translatesAutoresizingMaskIntoConstraints = true
             return hostingView
         } else {
             return NSView()
         }
    }
    
    @objc(setPickerSelection:index:)
    public static func setPickerSelection(_ value: String, index: Int) {
        if #available(OSX 10.15, *) {
             let key = String(index)
             DispatchQueue.main.async {
                 if let state = states[key] {
                     state.selection = value
                 }
             }
        }
    }
    
    @objc(setPickerItems:index:)
    public static func setPickerItems(_ items: [String], index: Int) {
        if #available(OSX 10.15, *) {
             let key = String(index)
             DispatchQueue.main.async {
                 if let state = states[key] {
                     state.items = items
                     if !items.contains(state.selection) {
                         state.selection = items.first ?? ""
                     }
                 }
             }
        }
    }

    @objc(setPickerGlass:index:)
    public static func setPickerGlass(_ isGlass: Bool, index: Int) {
        if #available(OSX 10.15, *) {
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.isGlass = isGlass
                }
            }
        }
    }
    
    @objc(setPickerShowLabel:index:)
    public static func setPickerShowLabel(_ showLabel: Bool, index: Int) {
        if #available(OSX 10.15, *) {
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.showLabel = showLabel
                }
            }
        }
    }

    @objc(setPickerTitle:index:)
    public static func setPickerTitle(_ title: String, index: Int) {
        if #available(OSX 10.15, *) {
            let key = String(index)
            DispatchQueue.main.async {
                if let state = states[key] {
                    state.title = title
                }
            }
        }
    }
}
