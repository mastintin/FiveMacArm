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
    public let hasscroll: Bool?
 }


// MARK: - Label View
public struct SwiftLabelView: View {
    @Bindable var state: LabelState
    
    public var body: some View {
        Text(state.text)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
