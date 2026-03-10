import Foundation
 

// Lectura de parámetros (Getters de C)
@_silgen_name("hb_parc") func hb_parc(_ i: Int32) -> UnsafePointer<Int8>?
@_silgen_name("hb_parl") func hb_parl(_ i: Int32) -> Int32
@_silgen_name("hb_parni") func hb_parni(_ i: Int32) -> Int32
@_silgen_name("hb_parnd") func hb_parnd(_ i: Int32) -> Double

@_silgen_name("hb_parnll") func hb_parnll(_ i: Int32) -> Int64
@_silgen_name("hb_retnll") func hb_retnll(_ n: Int64)


// Devolución de valores (Setters de C para Harbour)
@_silgen_name("hb_retc") func hb_retc(_ s: UnsafePointer<Int8>?)
@_silgen_name("hb_retl") func hb_retl(_ l: Int32)
@_silgen_name("hb_retni") func hb_retni(_ i: Int32)
@_silgen_name("hb_retnd") func hb_retnd(_ d: Double)

@_silgen_name("hb_param")
func hb_param(_ iParam: Int32, _ iMask: Int32) -> UnsafeMutableRawPointer?

@_silgen_name("hb_itemType")
func hb_itemType(_ pItem: UnsafeMutableRawPointer?) -> Int32

@_silgen_name("hb_dynsymFindName") func hb_dynsymFindName(_ name: UnsafePointer<Int8>) -> UnsafeMutableRawPointer?
@_silgen_name("hb_dynsymSymbol") func hb_dynsymSymbol(_ p: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?
@_silgen_name("hb_vmPushSymbol") func hb_vmPushSymbol(_ s: UnsafeMutableRawPointer?)
@_silgen_name("hb_vmPushNil") func hb_vmPushNil()
@_silgen_name("hb_vmPushNLL") func hb_vmPushNLL(_ n: Int64)
@_silgen_name("hb_vmPushLogical") func hb_vmPushLogical(_ b: Int32)
@_silgen_name("hb_vmDo") func hb_vmDo(_ nArgs: Int32)
@_silgen_name("hb_vmPushNumber") func hb_vmPushNumber(_ n: Double, _ dec: Int32)



// Máscaras de tipos de ítems de Harbour (HB_IT_...)
public let HB_IT_NIL:      Int32 = 0x00000000
public let HB_IT_ANY:      Int32 = 0x0000FFFF
public let HB_IT_STRING:   Int32 = 0x00000001
public let HB_IT_LOGICAL:  Int32 = 0x00000002
public let HB_IT_INTEGER:  Int32 = 0x00000004
public let HB_IT_DOUBLE:   Int32 = 0x00000008
public let HB_IT_DATE:     Int32 = 0x00000010
public let HB_IT_ARRAY:    Int32 = 0x00000040
public let HB_IT_BLOCK:    Int32 = 0x00000080
public let HB_IT_SYMBOL:   Int32 = 0x00000100
public let HB_IT_OBJECT:   Int32 = 0x00000200
public let HB_IT_POINTER:  Int32 = 0x00000400
public let HB_IT_LONG:     Int32 = 0x00000800
public let HB_IT_HASH:     Int32 = 0x00001000


public struct Harbour {
    // Para devolver Strings
    public static func ret(_ value: String) {
        hb_retc((value as NSString).utf8String)
    }
    
    // Para devolver Int64 (Punteros)
    public static func ret(_ value: Int64) {
        hb_retnll(value)
    }
    
  // Para Double (Coordenadas, Opacidad, Sliders)
    public static func ret(_ value: Double) {
        hb_retnd(value)
    }

    // Para devolver Bools
    public static func ret(_ value: Bool) {
        hb_retl(value ? 1 : 0)
    }
    
    // Para devolver Ints
    public static func ret(_ value: Int) {
        hb_retni(Int32(value))
    }

    // Caso de seguridad: Si no es nada de lo anterior, no hacemos nada
    public static func ret(_ value: Any) {
        print("Aviso: Tipo de retorno no soportado por Harbour")
    }
}

public struct HarbourBridgeSupport {
    // Convierte String de Swift a puntero para C
    public static func toC(_ value: String) -> UnsafePointer<Int8>? {
        return (value as NSString).utf8String
    }
    
    public static func toC(_ value: String?) -> UnsafePointer<Int8>? {
        guard let value = value else { return nil }
        return (value as NSString).utf8String
    }

    // Convierte Bool de Swift a Int32 de C
    public static func toC(_ value: Bool) -> Int32 {
        return value ? 1 : 0
    }

    // Convierte Int de Swift a Int32 de C
    public static func toC(_ value: Int) -> Int32 {
        return Int32(value)
    }
    
    // Convierte Double de Swift a Double de C
    public static func toC(_ value: Double) -> Double {
        return value
    }
}


