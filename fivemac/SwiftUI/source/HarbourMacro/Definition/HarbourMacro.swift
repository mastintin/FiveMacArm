import Foundation

/// Opción 1: Genera un puente que requiere un archivo .c intermedio (usa punteros)
@attached(peer, names: prefixed(_bridge_))
public macro HarbourBridge() = #externalMacro(module: "HarbourMacroImpl", type: "HarbourBridgeMacro")

/// Opción 2: Genera un puente DIRECTO (HB_FUN_...) para llamar desde Harbour (.prg)
/// No requiere archivo .c. Soporta String, Bool e Int.
@attached(peer, names: prefixed(_bridge_))
public macro HarbourDirect() = #externalMacro(module: "HarbourMacroImpl", type: "HarbourDirectMacro")
