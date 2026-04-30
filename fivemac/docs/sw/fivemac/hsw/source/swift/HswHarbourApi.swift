import Foundation

// MARK: - Core Harbour VM Bridge (Linker level)
// Estas funciones mapean directamente a los símbolos internos de la VM de Harbour
@_silgen_name("hb_retc") public func hb_retc(_ value: UnsafePointer<Int8>?)
@_silgen_name("hb_retni") public func hb_retni(_ value: Int32)
@_silgen_name("hb_retl") public func hb_retl(_ value: Int32)
@_silgen_name("hb_retnd") public func hb_retnd(_ value: Double)
@_silgen_name("hb_retnl") public func hb_retnl(_ value: Int)
@_silgen_name("hb_retnll") public func hb_retnll(_ value: Int64)

// MARK: - Native Harbour Functions Overwrites
@_cdecl("HB_FUN_HB_UUID")
public func hb_uuid_hb(_ p: UnsafeMutableRawPointer?) {
    // Usamos el generador nativo de Apple: rápido, seguro y ya en minúsculas
    let uuid = UUID().uuidString.lowercased()
    uuid.withCString { hb_retc($0) }
}
