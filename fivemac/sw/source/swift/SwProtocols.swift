import SwiftUI
import AppKit
import Observation
import Foundation

/// Protocolo que permite a cualquier objeto recibir comandos dinámicos desde el Pipeline.
public protocol SwApplyable: AnyObject {
    /// Punto de entrada único para actualizaciones de propiedades.
    /// @MainActor asegura que los cambios en @Observable ocurran en el hilo de UI.
    @MainActor func apply(property: String, value: Any)
}

/// (Opcional) Protocolo para objetos que necesitan reportar su estado inicial.
public protocol SwReportable: AnyObject {
    func getCurrentState() -> [String: Any]
}

// MARK: - List Selection Environment bus
struct ListSelectionKey: EnvironmentKey {
    static let defaultValue: ((String) -> Void)? = nil
}

extension EnvironmentValues {
    public var onListSelect: ((String) -> Void)? {
        get { self[ListSelectionKey.self] }
        set { self[ListSelectionKey.self] = newValue }
    }
}
