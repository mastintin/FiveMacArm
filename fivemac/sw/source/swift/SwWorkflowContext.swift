import Foundation

/// Almacén de datos compartido para los flujos de trabajo (Workflows).
/// Permite que un paso (ej: Red) guarde resultados que el siguiente paso (ej: Disco) pueda usar.
public class SwWorkflowContext {
    public static let shared = SwWorkflowContext()
    
    private var storage: [String: Any] = [:]
    private let queue = DispatchQueue(label: "com.fivemac.workflow.context", attributes: .concurrent)
    
    private init() {}
    
    /// Guarda un valor asociado a una clave (ej: "last_response")
    public func set(_ value: Any, for key: String) {
        queue.sync(flags: .barrier) {
            self.storage[key] = value
        }
    }
    
    /// Recupera un valor por su clave
    public func get(_ key: String) -> Any? {
        var result: Any?
        queue.sync {
            result = storage[key]
        }
        return result
    }
    
    /// Limpia la memoria del contexto
    public func clear() {
        queue.async(flags: .barrier) {
            self.storage.removeAll()
        }
    }
}
