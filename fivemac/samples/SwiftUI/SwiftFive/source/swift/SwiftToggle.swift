import SwiftUI
import AppKit

// State for the Toggle
@available(OSX 10.15, *)
@available(OSX 10.15, *)
class ToggleState: ObservableObject {
    @Published var isOn: Bool
    var caption: String
    var isSwitch: Bool
    var callback: ((Bool) -> Void)?
    
    init(isOn: Bool, caption: String, isSwitch: Bool, callback: ((Bool) -> Void)?) {
        self.isOn = isOn
        self.caption = caption
        self.isSwitch = isSwitch
        self.callback = callback
    }
}

// SwiftUI View for the Toggle
@available(OSX 10.15, *)
struct SwiftToggleView: View {
    @ObservedObject var state: ToggleState

    var body: some View {
        let toggleBinding = Binding(
            get: { self.state.isOn },
            set: { newValue in
                self.state.isOn = newValue
                self.state.callback?(newValue)
            }
        )

        Group {
            if state.isSwitch {
                Toggle(isOn: toggleBinding) {
                    Text(state.caption)
                }
                .toggleStyle(.switch)
            } else {
                Toggle(isOn: toggleBinding) {
                    Text(state.caption)
                }
            }
        }
        .padding()
    }
}

@objc(SwiftToggleLoader)
public class SwiftToggleLoader: NSObject {
    
    // Dictionary to store states by ID
    static var states: [String: ToggleState] = [:]
    
    @objc(makeToggleWithCaption:isOn:id:isSwitch:index:callback:)
    public static func makeToggle(caption: String, isOn: Bool, id: String, isSwitch: Bool, index: Int, callback: @escaping ((Bool) -> Void)) -> NSView {
        if #available(OSX 10.15, *) {
            
            let state = ToggleState(isOn: isOn, caption: caption, isSwitch: isSwitch, callback: callback)
            
            // Use ID if provided, otherwise fallback to String(index)
            let key = id.isEmpty ? String(index) : id
            
            states[key] = state
            
            let view = SwiftToggleView(state: state)
            
            // Register view in global registry
            ViewRegistry.register(view, for: index)
            
            let hostingView = NSHostingView(rootView: view)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            return hostingView
        } else {
            return NSView()
        }
    }
    
    @objc(setToggle:id:)
    public static func setToggle(_ isOn: Bool, id: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = states[id] {
                    state.objectWillChange.send()
                    state.isOn = isOn
                }
            }
        }
    }
    
    @objc(getToggleFromIndex:)
    public static func getToggle(fromIndex index: Int) -> Bool {
        if #available(OSX 10.15, *) {
            let key = String(index)
            if let state = states[key] {
                return state.isOn
            }
        }
        return false
    }
}
