import Foundation
import Darwin 

// --- 1. DECLARACIONES DE BAJO NIVEL (Harbour C API) ---

public typealias PHB_ITEM = UnsafeMutableRawPointer
public typealias HB_SIZE = CUnsignedLong

// Lectura de parámetros
@_silgen_name("hb_parc") public func hb_parc(_ i: Int32) -> UnsafePointer<Int8>?
@_silgen_name("hb_parl") public func hb_parl(_ i: Int32) -> Int32
@_silgen_name("hb_parni") public func hb_parni(_ i: Int32) -> Int32
@_silgen_name("hb_parnl") public func hb_parnl(_ i: Int32) -> Int
@_silgen_name("hb_parnd") public func hb_parnd(_ i: Int32) -> Double
@_silgen_name("hb_parnll") public func hb_parnll(_ i: Int32) -> Int64
@_silgen_name("hb_parptr") public func hb_parptr(_ i: Int32) -> UnsafeMutableRawPointer?
@_silgen_name("hb_pcount") public func hb_pcount() -> Int32
@_silgen_name("hb_param") public func hb_param(_ iParam: Int32, _ iMask: Int32) -> PHB_ITEM?

// Devolución de valores
@_silgen_name("hb_retc") public func hb_retc(_ s: UnsafePointer<Int8>?)
@_silgen_name("hb_retl") public func hb_retl(_ l: Int32)
@_silgen_name("hb_retni") public func hb_retni(_ i: Int32)
@_silgen_name("hb_retnd") public func hb_retnd(_ d: Double)
@_silgen_name("hb_retnll") public func hb_retnll(_ n: Int64)
@_silgen_name("hb_retptr") public func hb_retptr(_ p: UnsafeMutableRawPointer?)

// Gestión de ítems
@_silgen_name("hb_itemNew") public func hb_itemNew(_ pItem: PHB_ITEM?) -> PHB_ITEM?
@_silgen_name("hb_itemRelease") public func hb_itemRelease(_ pItem: PHB_ITEM?) -> Void
@_silgen_name("hb_itemReturn") public func hb_itemReturn(_ pItem: PHB_ITEM?) -> Void
@_silgen_name("hb_itemType") public func hb_itemType(_ pItem: PHB_ITEM?) -> Int32
@_silgen_name("hb_itemPutPtr") public func hb_itemPutPtr(_ pItem: PHB_ITEM?, _ ptr: UnsafeMutableRawPointer?) -> PHB_ITEM?
@_silgen_name("hb_itemReturnRelease") public func hb_itemReturnRelease(_ pItem: PHB_ITEM?) -> Void
@_silgen_name("hb_itemGetCPtr") public func _hb_itemGetCPtr(_ pItem: PHB_ITEM?) -> UnsafePointer<Int8>?

// Arrays y Hashes
@_silgen_name("hb_arrayNew") public func hb_arrayNew(_ pItem: PHB_ITEM?, _ nLen: Int32) -> Void
@_silgen_name("hb_arrayLen") public func hb_arrayLen(_ pArray: PHB_ITEM?) -> HB_SIZE
@_silgen_name("hb_arrayGetItemPtr") public func hb_arrayGetItemPtr(_ pArray: PHB_ITEM?, _ index: HB_SIZE) -> PHB_ITEM?
@_silgen_name("hb_arraySet") public func hb_arraySet(_ pArray: PHB_ITEM?, _ index: HB_SIZE, _ pItem: PHB_ITEM?) -> Void
@_silgen_name("hb_hashLen") public func hb_hashLen(_ pHash: PHB_ITEM?) -> HB_SIZE
@_silgen_name("hb_jsonDecode") public func hb_jsonDecode(_ szJSON: UnsafePointer<Int8>?, _ pItem: PHB_ITEM?) -> Void

// Máquina Virtual
@_silgen_name("hb_dynsymFindName") public func hb_dynsymFindName(_ name: UnsafePointer<Int8>) -> UnsafeMutableRawPointer?
@_silgen_name("hb_dynsymSymbol") public func hb_dynsymSymbol(_ p: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?
@_silgen_name("hb_vmPushSymbol") public func hb_vmPushSymbol(_ s: UnsafeMutableRawPointer?)
@_silgen_name("hb_vmPushNil") public func hb_vmPushNil()
@_silgen_name("hb_vmPushNLL") public func hb_vmPushNLL(_ n: Int64)
@_silgen_name("hb_vmPushNumber") public func hb_vmPushNumber(_ n: Double, _ d: Int32)
@_silgen_name("hb_vmPushString") public func _hb_vmPushString(_ s: UnsafePointer<Int8>?, _ l: HB_SIZE)
@_silgen_name("hb_vmPushLogical") public func hb_vmPushLogical(_ b: Int32)
@_silgen_name("hb_vmDo") public func hb_vmDo(_ n: Int32)

// --- 2. CONSTANTES DE TIPOS ---
public let HB_IT_STRING:    Int32 = 0x00400
public let HB_IT_ARRAY:     Int32 = 0x08000  

// --- 3. ESTRUCTURA HARBOUR (Para Macros @HarbourDirect) ---
public struct Harbour {
    public static func ret(_ value: String) { value.withCString { ptr in hb_retc(ptr) } }
    public static func ret(_ value: String?) { if let v = value { v.withCString { ptr in hb_retc(ptr) } } else { hb_retc(nil) } }
    public static func ret(_ value: Int64) { hb_retnll(value) }
    public static func ret(_ value: Double) { hb_retnd(value) }
    public static func ret(_ value: Bool) { hb_retl(value ? 1 : 0) }
    public static func ret(_ value: Int) { hb_retni(Int32(value)) }

    public static func ret(_ value: Any) {
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: [])
                if let jsonString = String(data: data, encoding: .utf8) {
                    let pItem = hb_itemNew(nil)
                    jsonString.withCString { ptr in hb_jsonDecode(ptr, pItem) }
                    hb_itemReturn(pItem); hb_itemRelease(pItem); return
                }
            } catch { print("Error: \(error)") }
        }
        hb_retc(nil) 
    }
}

// --- 4. HELPERS DE SWIFT ---
public func hb_vmPushString(_ s: String) {
    s.withCString { cStr in
        _hb_vmPushString(cStr, HB_SIZE(s.utf8.count))
    }
}

public struct HarbourBridgeSupport {
    public static func toC(_ value: String) -> UnsafePointer<Int8>? { return (value as NSString).utf8String }
    public static func toC(_ value: String?) -> UnsafePointer<Int8>? {
        guard let value = value else { return nil }
        return (value as NSString).utf8String
    }
    public static func toC(_ value: Bool) -> Int32 { return value ? 1 : 0 }
    public static func toC(_ value: Int) -> Int32 { return Int32(value) }
    public static func toC(_ value: Double) -> Double { return value }
}
