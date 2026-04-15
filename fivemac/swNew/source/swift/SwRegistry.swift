import SwiftUI
import AppKit
import Observation

@Observable
public class SwFormState {
    public var items: [SwStackItem] = []
    public init() {}
}

public struct SwRegistry {
    private static var registry: [String: Any] = [:]
    
    public static func register(_ value: Any, for id: String) {
        registry[id] = value
    }
    
    public static func get(_ id: String) -> Any? {
        return registry[id]
    }
    
    public static func unregister(_ id: String) {
        registry.removeValue(forKey: id)
    }
}

// Alias para compatibilidad si el código antiguo usa SwFormRegistry o ViewRegistry
public typealias SwFormRegistry = SwRegistry
public typealias ViewRegistry = SwRegistry
