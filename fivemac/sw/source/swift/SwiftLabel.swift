import SwiftUI
import Observation

// MARK: - Label State (Reactive)
@Observable
public class LabelState: SwApplyable {
    public var id: String
    public var text: String
    
    public init(id: String, text: String) {
        self.id = id
        self.text = text
    }

    @MainActor
    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "text", "caption":
            self.text = String(describing: value)
        default:
            print("SwLabel [\(id)]: Propiedad '\(property)' no reconocida.")
        }
    }
}

// MARK: - Native Bridge
@_cdecl("HB_FUN_SW_LABEL_CREATE")
public func sw_label_create_hb(_ p: UnsafeMutableRawPointer?) {
    let id = hb_parc(1).map { String(cString: $0) } ?? UUID().uuidString
    let text = hb_parc(2).map { String(cString: $0) } ?? ""
    
    if ViewRegistry.getState(for: id) == nil {
        let state = LabelState(id: id, text: text)
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .text, content: text, id: id)
        ViewRegistry.register(item, for: id)
    }
    
    // AUTORREGISTRACIÓN DE CAPACIDADES
    SwCapabilities.shared.register(
        control: "text", // El tipo en StackItem es .text
        commands: [
            "SWTEXT": "text", 
            "SWCAPTION": "text"
        ],
        fields: [
            "text": "Caption"
        ]
    )
}
