import SwiftUI
import Observation

// MARK: - Label State
@Observable
public class LabelState: SwApplyable {
    public let id: String
    public var text: String
    
    public init(id: String, text: String) {
        self.id = id
        self.text = text
    }
    
    @MainActor
    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "text", "caption":
            if let sVal = value as? String { self.text = sVal }
        default:
            break
        }
    }
}

// MARK: - Label Initialization (Codable)
public struct LabelInit: Codable {
    public let text: String?
    public let width: Double?
    public let height: Double?
    public let top: Double?
    public let left: Double?
    public let resizemask: Int?
}

// MARK: - Native Bridge
@_cdecl("HB_FUN_SW_LABEL_CREATE")
public func sw_label_create_hb(_ p: UnsafeMutableRawPointer?) {
    let id = hb_parc(1).map { String(cString: $0) } ?? UUID().uuidString
    let jsonStr = hb_parc(2).map { String(cString: $0) } ?? "{}"
    
    let decoder = JSONDecoder()
    let initial = (try? decoder.decode(LabelInit.self, from: jsonStr.data(using: .utf8) ?? Data()))
                ?? LabelInit(text: "Label", width: 200, height: 20, top: 0, left: 0, resizemask: 0)
    
    if ViewRegistry.getState(for: id) == nil {
        let state = LabelState(id: id, text: initial.text ?? "")
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .text, id: id)
        item.itemWidth = initial.width ?? 200
        item.itemHeight = initial.height ?? 20
        item.x = initial.left ?? 0
        item.y = initial.top ?? 0
        item.resizemask = initial.resizemask ?? 0
        ViewRegistry.register(item, for: id)
    }
}

// MARK: - Label View
public struct SwiftLabelView: View {
    @Bindable var state: LabelState
    
    public var body: some View {
        Text(state.text)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
