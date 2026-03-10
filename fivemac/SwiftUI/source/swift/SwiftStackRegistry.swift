import Foundation
import Observation

protocol StackStateProtocol: AnyObject {
    var items: [VStackItem] { get set }
    var onAction: ((String) -> Void)? { get set }
    var lastItem: VStackItem? { get set }
}


class SwiftStackRegistry {
    static var sharedStates: [String: StackStateProtocol] = [:]
    
    static func register(_ state: StackStateProtocol, for id: String) {
        sharedStates[id] = state
    }
    
    static func getState(for id: String) -> StackStateProtocol? {
        return sharedStates[id]
    }
}
