import Foundation
import AppKit

// MARK: - Core Harbour VM Bridge (Linker level)
@_silgen_name("hb_parc") public func hb_parc(_ index: Int32) -> UnsafePointer<Int8>?
@_silgen_name("hb_parni") public func hb_parni(_ index: Int32) -> Int32
@_silgen_name("hb_parl") public func hb_parl(_ index: Int32) -> Int32
@_silgen_name("hb_parnd") public func hb_parnd(_ index: Int32) -> Double
@_silgen_name("hb_parnl") public func hb_parnl(_ index: Int32) -> Int
@_silgen_name("hb_parnll") public func hb_parnll(_ index: Int32) -> Int64
@_silgen_name("hb_retc") public func hb_retc(_ value: UnsafePointer<Int8>?)
@_silgen_name("hb_retni") public func hb_retni(_ value: Int32)
@_silgen_name("hb_retl") public func hb_retl(_ value: Int32)
@_silgen_name("hb_retnd") public func hb_retnd(_ value: Double)
@_silgen_name("hb_retnl") public func hb_retnl(_ value: Int)
@_silgen_name("hb_retnll") public func hb_retnll(_ value: Int64)

@_silgen_name("hb_arrayLen") public func hb_arrayLen(_ pArray: UnsafeMutableRawPointer?) -> Int
@_silgen_name("hb_arrayGetCPtr") public func hb_arrayGetCPtr(_ pArray: UnsafeMutableRawPointer?, _ index: Int) -> UnsafePointer<Int8>?
@_silgen_name("hb_param") public func hb_param(_ index: Int32, _ type: Int32) -> UnsafeMutableRawPointer?

@_silgen_name("hb_dynsymFindName") public func hb_dynsymFindName(_ name: UnsafePointer<Int8>?) -> UnsafeMutableRawPointer?
@_silgen_name("hb_dynsymSymbol") public func hb_dynsymSymbol(_ dynsym: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?
@_silgen_name("hb_vmPushSymbol") public func hb_vmPushSymbol(_ symbol: UnsafeMutableRawPointer?)
@_silgen_name("hb_vmPushNil") public func hb_vmPushNil()
@_silgen_name("hb_vmPushString") public func hb_vmPushString(_ value: UnsafePointer<Int8>?, _ length: Int)
@_silgen_name("hb_vmPushLong") public func hb_vmPushLong(_ value: Int)
@_silgen_name("hb_vmPushNumber") public func hb_vmPushNumber(_ value: Double, _ dec: Int32)
@_silgen_name("hb_vmPushLogical") public func hb_vmPushLogical(_ value: Int32)
@_silgen_name("hb_vmDo") public func hb_vmDo(_ count: Int32)

@_cdecl("HB_FUN_HB_UUID")
public func hb_uuid_hb(_ p: UnsafeMutableRawPointer?) {
    let uuid = UUID().uuidString.lowercased()
    uuid.withCString { hb_retc($0) }
}

@_cdecl("HB_FUN_ERRORLINK")
public func hb_errorlink_hb(_ p: UnsafeMutableRawPointer?) {
    // No-Op por ahora para independencia de build
}

// MARK: - Intelligent Harbour Bridge
public struct Harbour {
    public static func ret(_ value: Int64) { hb_retnll(value) }
    public static func ret(_ value: Int) { hb_retnl(value) }
    public static func ret(_ value: Double) { hb_retnd(value) }
    public static func ret(_ value: String) { value.withCString { hb_retc($0) } }
    public static func ret(_ value: Bool) { hb_retl(value ? 1 : 0) }
    public static func ret() { hb_vmPushNil() }

    /// Calls a Harbour function intelligently (Asynchronous in HSW)
    public static func call(_ funcName: String, _ args: Any...) {
        var data: [String: Any] = [:]
        for (index, arg) in args.enumerated() {
            data["p\(index+1)"] = arg
        }
        SwDispatcher.shared.enqueueEvent(id: funcName, type: "call", data: data)
    }
}

