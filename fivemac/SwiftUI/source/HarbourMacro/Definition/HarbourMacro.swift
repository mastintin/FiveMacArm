import Foundation

/// Macro que genera automáticamente un puente (wrapper) @_cdecl para Harbour.
/// Ejemplo: @HarbourBridge func setUsername(name: String) 
/// Genera: @_cdecl("HB_SETUSERNAME") public func _bridge_setUsername(ptr: UnsafePointer<Int8>) { ... }
@attached(peer, names: prefixed(_bridge_))
public macro HarbourBridge() = #externalMacro(module: "HarbourMacroImpl", type: "HarbourBridgeMacro")
